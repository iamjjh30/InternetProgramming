<%@ page contentType="text/html;charset=euc-kr" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="stylesheet" href="findId.css">
</head>
<body>
<div id="header-placeholder"></div>
<!-- ? 로그인 카드 -->
<div class="login-container">
    <div class="login-box">
        <h2>비밀번호 찾기</h2>
        <form>
            <p>아이디</p>
            <input type="text" placeholder="아이디를 입력하세요" required />
            <p>이메일</p>
            <input type="text" placeholder="이메일을 입력하세요" required />
            <button type="submit">비밀번호 찾기</button>
        </form>
    </div>
</div>
<script src="include.js"></script>
</body>
</html>
