<%@ page import="java.io.*" %>
<%@ page import="java.security.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.Part" %>

<%@ page contentType="text/html; charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 업로드 경로
    String uploadPath = application.getRealPath("/uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    // ---- multipart에서 텍스트 값 꺼내기 ----
    String memId     = request.getPart("memId").getInputStream().readAllBytes().length > 0
            ? new String(request.getPart("memId").getInputStream().readAllBytes(), "UTF-8")
            : null;

    String memName   = request.getPart("memName").getInputStream().readAllBytes().length > 0
            ? new String(request.getPart("memName").getInputStream().readAllBytes(), "UTF-8")
            : null;

    String memPasswd = request.getPart("memPasswd").getInputStream().readAllBytes().length > 0
            ? new String(request.getPart("memPasswd").getInputStream().readAllBytes(), "UTF-8")
            : null;

    String emailId = request.getPart("emailId").getInputStream().readAllBytes().length > 0
            ? new String(request.getPart("emailId").getInputStream().readAllBytes(), "UTF-8")
            : "";

    String emailDomain = request.getPart("emailDomain").getInputStream().readAllBytes().length > 0
            ? new String(request.getPart("emailDomain").getInputStream().readAllBytes(), "UTF-8")
            : "";

    String email = emailId + "@" + emailDomain;

    String phone1 = new String(request.getPart("phone1").getInputStream().readAllBytes(), "UTF-8");
    String phone2 = new String(request.getPart("phone2").getInputStream().readAllBytes(), "UTF-8");
    String phone3 = new String(request.getPart("phone3").getInputStream().readAllBytes(), "UTF-8");

    String phone = phone1 + "-" + phone2 + "-" + phone3;

    // ---- 프로필 이미지 저장 ----
    Part filePart = request.getPart("profileImg");
    String profileImg = "";

    if (filePart != null && filePart.getSize() > 0) {
        String header = filePart.getHeader("content-disposition");
        String fileName = header.substring(header.indexOf("filename=") + 10, header.length() - 1);

        if (!fileName.equals("")) {
            String newName = memId + "_" + System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + "/" + newName);
            profileImg = "uploads/" + newName;
        }
    }

    // ---- DB 저장 ----
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/internetProgramming?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul",
                "multi", "abcd"
        );

        String sql = "INSERT INTO member (memId, memPasswd, memName, memPhone, memAddress, profileImg) VALUES (?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, memId);
        pstmt.setString(2, memPasswd);
        pstmt.setString(3, memName);
        pstmt.setString(4, phone);
        pstmt.setString(5, email);
        pstmt.setString(6, profileImg);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.print("<script>alert('회원가입 성공!'); location.href='login.jsp';</script>");
        } else {
            out.print("<script>alert('회원가입 실패'); history.back();</script>");
        }

    } catch (Exception e) {
        out.print("오류: " + e.getMessage());
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
