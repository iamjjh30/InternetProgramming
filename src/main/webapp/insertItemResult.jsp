<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.sql.*" %> 
<html><head><title>상품 등록 결과</title></head>
<body>

<% 
	request.setCharacterEncoding("euc-kr");  // 입력폼에서 전송된 한글데이터 처리

	// 입력폼에서 받는 데이터는 모두 String형임
	String ctgType = request.getParameter("ctgType");
    String prdNo = request.getParameter("prdNo");
    String sellerId = request.getParameter("sellerId");
    String prdName = request.getParameter("prdName");
	int prdPrice = Integer.parseInt(request.getParameter("prdPrice"));
    int prdDeliver = Integer.parseInt(request.getParameter("prdDeliver"));
    String prdDescription = request.getParameter("prdDescription");
	String regDate = request.getParameter("regDate");
	


try {
 	 String DB_URL="jdbc:mysql://localhost:3306/final";  //  접속할 DB명
     String DB_ID="multi";  //  접속할 아이디
     String DB_PASSWORD="abcd"; // 접속할 패스워드
 	 
	 Class.forName("org.gjt.mm.mysql.Driver");  // JDBC 드라이버 로딩
 	 Connection con = DriverManager.getConnection(DB_URL, DB_ID, DB_PASSWORD);
     // DB에 접속           

	//SQL문 작성 : 테이블 필드명
    String jsql = "INSERT INTO goods (ctgType, prdNo, sellerId, prdName, prdPrice, prdDeliver, prdDescription, regDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
      
    //PreparedStatement 생성(SQL문의 형틀을 정의함)
	PreparedStatement pstmt = con.prepareStatement(jsql); 

	//위의 SQL문에서 ?에 해당되는 곳에 다음의 값들을 하나씩 할당함 (인수 전달)
	//정수형의 경우에는 setInt()를 사용함
    pstmt.setString(1, ctgType);
	pstmt.setString(2, prdNo);
    pstmt.setString(3, sellerId);
	pstmt.setString(4, prdName);
    pstmt.setInt(5, prdPrice);
    pstmt.setInt(6, prdDeliver);
    pstmt.setString(7, prdDescription);
    pstmt.setString(8, regDate);
	pstmt.executeUpdate(); // SQL문 실행
%>
<b>상품 정보</b><p>
<table>
    <tr>
        <td colspan='2'>상품 카테고리:
            <%=ctgType%></td>
    </tr>
    <tr>
        <td colspan='2'>상품번호:
            <%=prdNo%></td>
    </tr>
    <tr>
        <td colspan='2'>판매자 ID:
            <%=sellerId%></td>
    </tr>
    <tr>
        <td colspan='2'>상품명:
            <%=prdName%></td>
    </tr>
    <tr>
        <td colspan='2'>가격:
            <%=prdPrice%>원</td>
    </tr>
    <tr>
        <td colspan='2'>배송비:
            <%=prdDeliver%>원</td>
    </tr>
    <tr>
        <td colspan='2'>상품 설명:
            <%=prdDescription%></td>
    </tr>
    <tr>
        <td colspan='2'>상품 등록일:
            <%=regDate%></td>
    </tr>
    <tr>
    <td>
        <a href="deleteItem.jsp?prdNo=<%=prdNo%>" onclick="return confirm('정말 삭제하시겠습니까?');">
            삭제
        </a>
    </td>
    </tr>
</table>
<p>
<% 
  } catch(Exception e) { 
		out.println(e);
}
%>
<p>

</center>
</body>
</html>