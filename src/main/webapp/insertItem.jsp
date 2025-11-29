<%@ page contentType="text/html;charset=euc-kr" %>
<html>
<head><title>상품등록</title></head>
<body>
<b>상품 등록</b>
<form method="post" action="insertItemResult.jsp" >
<table>
		<tr>
			<td colspan='2'>상품 카테고리:
			<input type="text" name="ctgType"></td>
		</tr>
		<tr>
			<td colspan='2'>상품번호:
			<input type="text" name="prdNo"></td>
		</tr>
		<tr>
			<td colspan='2'>판매자 ID:
			<input type="text" name="sellerId"></td>
		</tr>
    <tr>
        <td colspan='2'>상품명:
            <input type="text" name="prdName"></td>
    </tr>
    <tr>
        <td colspan='2'>가격:
            <input type="text" name="prdPrice">원</td>
    </tr>
    <tr>
        <td colspan='2'>배송비:
            <input type="text" name="prdDeliver">원</td>
    </tr>
    <tr>
        <td colspan='2'>상품 설명:
            <input type="text" name="prdDescription"></td>
    </tr>
    <tr>
        <td colspan='2'>상품 등록일:
            <input type="text" name="regDate"></td>
    </tr>
</table><p>
<input type="submit" value="상품등록">
<input type="reset" value="취 소">
</form>
</center>
</body>
</html>

