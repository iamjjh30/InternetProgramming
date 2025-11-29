<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.sql.*" %>
<html><head><title>상품 삭제 처리</title></head>
<body>

<%
    request.setCharacterEncoding("euc-kr");

    // 삭제할 상품 번호를 파라미터로 받습니다.
    // 예: product_delete.jsp?prdNo=A001 형태로 요청이 들어옵니다.
    String prdNo = request.getParameter("prdNo");

    // prdNo가 제대로 넘어왔는지 확인
    if (prdNo == null || prdNo.equals("")) {
        out.println("<script>alert('삭제할 상품 번호가 없습니다.'); history.back();</script>");
        return;
    }

    Connection con = null;
    PreparedStatement pstmt = null;

    try {
        String DB_URL="jdbc:mysql://localhost:3306/final";
        String DB_ID="multi";
        String DB_PASSWORD="abcd";

        // [요청사항 반영] 드라이버 업데이트 하지 않음 (구버전 유지)
        Class.forName("org.gjt.mm.mysql.Driver");
        con = DriverManager.getConnection(DB_URL, DB_ID, DB_PASSWORD);

        // SQL문 작성 : 특정 prdNo를 가진 행을 삭제
        String jsql = "DELETE FROM goods WHERE prdNo = ?";

        pstmt = con.prepareStatement(jsql);
        pstmt.setString(1, prdNo);

        // 실행 결과 확인 (result가 1이면 성공, 0이면 삭제할 대상 없음)
        int result = pstmt.executeUpdate();

        if (result > 0) {
%>
<script>
    alert("<%=prdNo%>번 상품이 성공적으로 삭제되었습니다.");
    // 삭제 후 목록 페이지 등으로 이동하려면 아래 주소를 변경하세요.
    // location.href = "product_list.jsp";
    history.back(); // 일단은 이전 페이지로 돌려보냅니다.
</script>
<%
} else {
%>
<script>
    alert("삭제 실패: 해당 상품 번호가 존재하지 않습니다.");
    history.back();
</script>
<%
        }

    } catch(Exception e) {
        out.println("<h3>에러 발생</h3>");
        out.println(e.getMessage());
    } finally {
        // 자원 해제 (DB 연결 끊기) - 과제라도 이 부분은 꼭 넣어주는 것이 좋습니다.
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(con != null) try { con.close(); } catch(SQLException ex) {}
    }
%>

</body>
</html>