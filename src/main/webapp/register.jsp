<%@ page contentType="text/html; charset=euc-kr"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>회원가입</title>
    <link rel="stylesheet" href="register.css">
</head>
<body>
<div id="header-placeholder"></div>
<h2 class="title">회원가입</h2>

<form class="signup-form" enctype="multipart/form-data">
    <!-- 프로필 사진 업로드 -->
    <div class="form-row profile-row">
        <label>프로필</label>
        <div class="profile-section">
            <label for="profileImageInput">
                <img id="profilePreview" src="https://via.placeholder.com/80" alt="프로필 사진" class="profile-image" />
            </label>
            <input type="file" id="profileImageInput" accept="image/*" style="display:none;" />
        </div>
    </div>

    <div class="form-row">
        <label for="userId">아이디</label>
        <input type="text" id="userId" placeholder="아이디" />
        <button type="button" class="small-btn">아이디 중복확인</button>
    </div>

    <div class="form-row">
        <label for="name">이름</label>
        <input type="text" id="name" placeholder="이름" />
    </div>

    <div class="form-row">
        <label for="password">비밀번호</label>
        <input type="password" id="password" placeholder="비밀번호를 입력하세요" />
    </div>

    <div class="form-row">
        <label for="passwordConfirm">비밀번호 확인</label>
        <input type="password" id="passwordConfirm" placeholder="비밀번호를 입력하세요" />
        <button type="button" class="small-btn">확인</button>
    </div>

    <div class="form-row email-row">
        <label>Email</label>
        <input type="text" class="email-input" /> @
        <select class="email-domain">
            <option>직접입력</option>
            <option>naver.com</option>
            <option>gmail.com</option>
            <option>daum.net</option>
        </select>
    </div>

    <div class="form-row phone-row">
        <label>휴대폰번호</label>
        <select>
            <option>010</option>
            <option>011</option>
            <option>016</option>
        </select>
        -
        <input type="text" maxlength="4" />
        -
        <input type="text" maxlength="4" />
    </div>

    <button type="submit" class="submit-btn">회원가입</button>
</form>
<script>
    // 프로필 이미지 미리보기
    document.getElementById('profileImageInput').addEventListener('change', function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (event) {
            document.getElementById('profilePreview').src = event.target.result;
        };
        reader.readAsDataURL(file);
    });

    // 이메일 도메인 선택 시 자동입력
    document.querySelector('.email-domain').addEventListener('change', function () {
        const input = document.querySelector('.email-input');
        if (this.value !== '직접입력') {
            input.value = input.value.split('@')[0]; // @ 이하 제거
        }
    });

</script>
<script src="include.js"></script>
</body>
</html>
