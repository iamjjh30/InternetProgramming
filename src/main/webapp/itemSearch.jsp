<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %> <%-- 가격 콤마 표시를 위해 추가 --%>

<html>
<head>
    <title>상품 검색</title>
</head>
<body>

<center>
    <h2>상품 검색</h2>
    
    <%-- 1. 상품 검색 폼 --%>
    <form name="search" method="post" action="itemSearch.jsp">
        <input type="text" name="searchKeyword" size="30" 
               value="<%-- 검색어 유지 --%><%=(request.getParameter("searchKeyword") != null ? request.getParameter("searchKeyword") : "")%>">
        <input type="submit" value="검색">
    </form>
    <br><hr><br>

    <%-- 2. 상품 검색 결과 처리 --%>
    <%
       
        request.setCharacterEncoding("euc-kr");
        String keyword = request.getParameter("searchKeyword");

        // 검색어가 있을 경우에만 DB 검색 수행
        if (keyword != null && !keyword.trim().isEmpty()) {
            
            
            String DB_URL = "jdbc:mysql://localhost:3306/final";
            String DB_ID = "multi";
            String DB_PASSWORD = "abcd";
            
            Connection con = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            // 가격 포맷 (1000 -> 1,000)
            NumberFormat nf = NumberFormat.getInstance();

            try {
                Class.forName("org.gjt.mm.mysql.Driver");
                con = DriverManager.getConnection(DB_URL, DB_ID, DB_PASSWORD);

               
                String sql = "SELECT id, user_id, cat_id, title FROM item WHERE title  LIKE ?";
                
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, "%" + keyword + "%"); // 예: "컴퓨터" -> "%컴퓨터%"
                
                rs = pstmt.executeQuery();
    %>
                <h3>'<%= keyword %>' 검색 결과</h3>
                <table border="1" width="700">
                    <tr align="center" bgcolor="#DDDDDD">
                        <th>상품 이미지</th>
                        <th>상품명</th>
                        <th>상품 가격</th>
                        <th>상세보기</th>
                    </tr>
    <%
                if (!rs.isBeforeFirst()) { // rs.isBeforeFirst() : 결과가 있는지 확인
                    // 검색 결과가 없는 경우
                    out.println("<tr><td colspan='4' align='center'>");
                    out.println("'" + keyword + "'에 대한 검색 결과가 없습니다.");
                    out.println("</td></tr>");
                } else {
                    // 검색 결과가 있는 경우, 반복문으로 출력
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        int user_id = rs.getInt("user_id");
                        int cat_id = rs.getInt("cat_id");
                        String title = rs.getString("title");
    %>
                        <tr align="center">
                            <td>
                                <%=title%>
                            </td>
                            <td align="left"><%= id%></td>
                            
                            <td>
                                <a href="itemDetail.jsp?prdNo=<%= cat_id %>">[상세보기]</a>
                            </td>
                        </tr>
    <%
                    } // while문 끝
                } // else문 끝
    %>
                </table>
    <%
            } catch (Exception e) {
                out.println("상품 검색 중 오류가 발생했습니다: " + e.getMessage());
            } finally {
                // 자원 해제
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (con != null) con.close();
            }
        } // if(keyword != null) 끝
    %>
</center>

</body>
</html>