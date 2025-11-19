<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // 이 파일은 AJAX 요청의 응답으로 사용되므로, HTML 태그를 일절 출력하지 않습니다.
    request.setCharacterEncoding("UTF-8");
    String memId = request.getParameter("memId");

    // 아이디가 비어있는 경우
    if (memId == null || memId.trim().isEmpty()) {
        out.print("false");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    boolean isAvailable = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/internetProgramming?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul",
                "multi", "abcd"
        );

        String sql = "SELECT COUNT(*) FROM member WHERE memId = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, memId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            int count = rs.getInt(1);
            if (count == 0) {
                isAvailable = true; // 중복 아이디 없음
            }
        }

        // 최종 결과 출력 (이것만 메인 JSP로 전송됩니다)
        out.print(isAvailable ? "true" : "false");

    } catch (Exception e) {
        // 오류 발생 시 오류 메시지를 보내거나, 안전하게 "error"를 출력하여 클라이언트에서 처리
        // out.print("DB_ERROR"); // 디버깅용
        out.print("false"); // 오류 시 사용 불가능으로 처리
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) { }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) { }
        if (conn != null) try { conn.close(); } catch (SQLException ignored) { }
    }
%>