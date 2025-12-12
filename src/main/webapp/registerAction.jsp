<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ page import="java.util.UUID" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // 1. 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 2. 업로드 경로 설정 (프로필 이미지 저장)
    // 업로드 경로를 uploads/profile로 세분화하여 다른 상품 이미지 등과 구분하는 것이 좋습니다.
    String uploadPath = application.getRealPath("/uploads/profile");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    // ---- 3. 텍스트 값 꺼내기 (request.getParameter 사용 권장) ----
    // Multipart 요청이므로 getParameter 대신 request.getPart().getInputStream() 방식이 원본 코드의 의도이나,
    // 해당 방식은 복잡하고 스트림 처리가 불안정하므로, 표준적인 getParameter 방식을 사용하도록 코드를 수정합니다.
    // (서버 환경에 따라 getParameter가 작동하지 않을 경우, 별도의 텍스트 파트 처리 로직이 필요합니다.)

    String memId = request.getParameter("memId");
    String memName = request.getParameter("memName");
    String memPasswd = request.getParameter("memPasswd");
    String memAddress = request.getParameter("address");

    String emailId = request.getParameter("emailId");
    String emailDomain = request.getParameter("emailDomain");
    String email = (emailId != null && emailDomain != null) ? emailId + "@" + emailDomain : "";

    String phone1 = request.getParameter("phone1");
    String phone2 = request.getParameter("phone2");
    String phone3 = request.getParameter("phone3");
    String phone = phone1 + "-" + phone2 + "-" + phone3;

    // 필수 필드 검증
    if (memId == null || memPasswd == null || memName == null || memId.trim().isEmpty() || memPasswd.trim().isEmpty() || memName.trim().isEmpty()) {
        out.println("<script>alert('필수 입력 항목이 누락되었습니다.'); history.back();</script>");
        return;
    }

    // ---- 4. 프로필 이미지 저장 ----
    Part filePart = request.getPart("profileImg");
    String profileImg = ""; // DB에 저장할 경로

    if (filePart != null && filePart.getSize() > 0) {
        String header = filePart.getHeader("content-disposition");
        // 파일 이름을 추출하는 더 안전한 방법 (RFC 6266)
        String fileName = null;
        for (String content : header.split(";")) {
            if (content.trim().startsWith("filename")) {
                fileName = content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
                break;
            }
        }

        if (fileName != null && !fileName.equals("")) {
            // 파일명 중복을 피하기 위해 memId와 UUID를 조합하여 새 이름 생성
            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
            String newName = memId + "_" + UUID.randomUUID().toString().substring(0, 8) + fileExtension;

            // 파일 저장 (uploads/profile/newName)
            filePart.write(uploadPath + File.separator + newName);
            profileImg = "uploads/profile/" + newName; // DB에 저장할 상대 경로
        }
    } else {
        // 업로드된 파일이 없을 경우 기본 이미지 경로 사용 (또는 NULL)
        profileImg = null; // DB에 NULL을 허용한다면 null로 설정
    }

    // ---- 5. DB 저장 ----
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/internetProgramming?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul",
                "multi", "abcd"
        );

        // ⭐️ 쿼리 수정: memEmail을 포함하여 7개의 필드와 7개의 ?를 맞춥니다. ⭐️
        String sql = "INSERT INTO member (memId, memPasswd, memName, memPhone, memAddress, profileImg, memEmail) VALUES (?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, memId);
        pstmt.setString(2, memPasswd); // ⚠️ 보안: 실제 서비스에서는 반드시 해시 처리해야 합니다.
        pstmt.setString(3, memName);
        pstmt.setString(4, phone);
        pstmt.setString(5, memAddress);
        pstmt.setString(6, profileImg);
        pstmt.setString(7, email);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.print("<script>alert('회원가입 성공!'); location.href='login.jsp';</script>");
        } else {
            out.print("<script>alert('회원가입 실패'); history.back();</script>");
        }

    } catch (Exception e) {
        // DB 또는 파일 처리 중 예외 발생 시 오류 출력
        out.print("<script>alert('처리 중 오류가 발생했습니다: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
    } finally {
        // 6. 자원 해제
        if (pstmt != null) { try { pstmt.close(); } catch(SQLException e) {} }
        if (conn != null) { try { conn.close(); } catch(SQLException e) {} }
    }
%>