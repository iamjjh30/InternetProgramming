<%@ page contentType="text/html;charset=euc-kr" %>
<html>
<head><title>상품등록</title></head>
<body>
<center>
<font size="6"><b>상품 등록</b></font>
<form method="post" action="insertItemResult.jsp" >
<table border="2">
		<tr>
			<td colspan='2'><a href="uploadForm.jsp">이미지 첨부</td>
		</tr>
		<tr>
			<td colspan='2'>상품번호:	  
			<input type="text" name="cat_id"></td>
		</tr>
		<tr>
			<td colspan='2'>상품명:
			<input type="text" name="title"></td>
		</tr>
		<tr>
			<td colspan='2'>상품가격: 
			<input type="text" name="price"> 원</td>
		</tr>
</table><p>
<input type="submit" value="상품등록">
<input type="reset" value="취 소">
</form>
</center>
</body>
</html>

