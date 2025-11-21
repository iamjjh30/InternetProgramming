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
        <form action="loginOK.jsp" method="post" id="loginForm">
            <p>아이디</p>
            <input type="text" placeholder="아이디" name="memId" required />
            <p>비밀번호</p>
            <input type="password" placeholder="비밀번호" name="memPasswd" required />
            <button type="submit" onclick="validateAndSubmit()">Log in</button>
        </form>
        <div class="signup-link">
            회원이 아니신가요? <a href="register.jsp">회원가입</a>
        </div>
        <div class="find-links">
            <a href="findId.jsp">아이디 찾기</a>
            <a href="findPw.jsp">비밀번호 찾기</a>
        </div>
    </div>
</div>
<script>
    // ... (include.js 호출 전에 추가)

    function validateAndSubmit() {
        const form = document.getElementById('loginForm');
        const memId = form.elements['memId'].value.trim();
        const memPasswd = form.elements['memPasswd'].value.trim();

        if (memId === "") {
            alert("아이디를 입력해 주세요.");
            form.elements['memId'].focus();
            return false;
        }

        if (memPasswd === "") {
            alert("비밀번호를 입력해 주세요.");
            form.elements['memPasswd'].focus();
            return false;
        }

        // 모든 검증 통과 후, loginAction.jsp로 데이터를 전송합니다.
        form.submit();
    }
</script>
<script src="include.js"></script>
</body>
</html>
