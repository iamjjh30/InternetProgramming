<%@ page contentType="text/html;charset=euc-kr" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
</head>
<body>
    <h2>회원가입</h2>
    <form action="registerAction.jsp" method="post">
        <input type="email" name="email" placeholder="이메일" required><br>
		<input type="text" name="id" placeholder="아이디" required><br>
        <input type="password" name="pw" placeholder="비밀번호" required><br>
        <input type="text" name="name" placeholder="이름" required><br>
        <input type="text" name="nick" placeholder="닉네임"><br>
        <input type="text" name="phone" placeholder="전화번호"><br>
        <input type="text" name="addr" placeholder="주소"><br>
        <input type="submit" value="회원가입">
    </form>
</body>
</html>