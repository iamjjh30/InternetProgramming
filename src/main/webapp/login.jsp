<%@ page contentType="text/html;charset=euc-kr" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="stylesheet" href="login.css">
</head>
<body>
<div id="header-placeholder"></div>
<!-- ? 로그인 카드 -->
<div class="login-container">
    <div class="login-box">
        <h2>로그인</h2>
        <form>
            <input type="text" placeholder="아이디" required />
            <input type="password" placeholder="비밀번호" required />
            <button type="submit">Log in</button>
        </form>
        <div class="signup-link">
            회원이 아니신가요? <a href="register.jsp">회원가입</a>
        </div>
        <div class="find-links">
            <a href="#">아이디 찾기</a>
            <a href="#">비밀번호 찾기</a>
        </div>
    </div>
</div>
<script src="include.js"></script>
</body>
</html>
