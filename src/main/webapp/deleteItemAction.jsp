<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. 상품 번호(prdNo) 및 로그인 ID 가져오기
    String prdNo = request.getParameter("prdNo");
    String memId = (String) session.getAttribute("userId");

    // 2. 유효성 검사
    if (prdNo == null || prdNo.trim().isEmpty() || memId == null || memId.trim().isEmpty()) {
%>
<script>
    alert("잘못된 접근입니다.");
    location.href = "myPage.jsp";
</script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    int result = 0;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming";
    String dbUser = "multi";
    String dbPass = "abcd";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 3. 상품 삭제 SQL
        // 주의: prdNo와 sellerId를 모두 조건으로 사용하여, 로그인한 사용자가 본인 상품만 삭제하도록 보안 강화
        String sql = "DELETE FROM goods WHERE prdNo = ? AND sellerId = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, prdNo);
        pstmt.setString(2, memId); // 로그인 ID로 권한 확인

        result = pstmt.executeUpdate();

        if (result > 0) {
%>
<script>
    alert("상품이 성공적으로 삭제되었습니다.");
    location.href = "myPage.jsp"; // 삭제 후 마이페이지로 이동
</script>
<%
} else {
%>
<script>
    alert("상품 삭제에 실패했거나, 삭제 권한이 없습니다.");
    history.back();
</script>
<%
    }

} catch (SQLException e) {
%>
<script>
    alert("데이터베이스 오류가 발생했습니다: <%= e.getMessage() %>");
    history.back();
</script>
<%
        System.out.println("상품 삭제 DB 오류: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        // 드라이버 로드 오류 처리
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>