<%@ page contentType="text/html; charset=UTF-8"%>
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

<form action="registerAction.jsp" method="post" class="signup-form" enctype="multipart/form-data">
    <!-- 프로필 사진 업로드 -->
    <div class="form-row profile-row">
        <label>프로필</label>
        <div class="profile-section">
            <label for="profileImageInput">
                <img id="profilePreview" alt="프로필 사진" class="profile-image" />
            </label>
            <input type="file" name="profileImg" id="profileImageInput" accept="image/*" style="display:none;" />
        </div>
    </div>

    <div class="form-row">
        <label for="userId">아이디</label>
        <input type="text" name="memId" id="memId" placeholder="아이디" required/>
        <button type="button" class="small-btn" onclick="checkIdDuplicate()">아이디 중복확인</button>
    </div>

    <div class="form-row">
        <label for="name">이름</label>
        <input type="text" name="memName" id="memName" placeholder="이름" required/>
    </div>

    <div class="form-row">
        <label for="password">비밀번호</label>
        <input type="password" name="memPasswd" id="memPasswd" placeholder="비밀번호를 입력하세요" required/>
    </div>

    <div class="form-row">
        <label for="passwordConfirm">비밀번호 확인</label>
        <input type="password" name="passwordConfirm" id="passwordConfirm" placeholder="비밀번호를 입력하세요" required/>
        <button type="button" class="small-btn" onclick="checkPasswordConfirm()">확인</button>
    </div>

    <div class="form-row email-row">
        <label>Email</label>
        <input type="text" name="emailId" id="emailId" class="email-input" required/> @
        <select class="email-domain" name="emailDomain" id="emailDomain">
            <option selected>naver.com</option>
            <option>gmail.com</option>
            <option>daum.net</option>
        </select>
    </div>

    <div class="form-row address-row">
        <label>주소</label>
        <input type="text" name="address" id="memAddress" required/>
    </div>

    <div class="form-row phone-row" >
        <label>휴대폰번호</label>
        <select name="phone1">
            <option>010</option>
            <option>011</option>
            <option>016</option>
        </select>
        -
        <input type="text" maxlength="4" name="phone2" required/>
        -
        <input type="text" maxlength="4" name="phone3" required/>
    </div>
    <div class="button-container">
        <button type="reset" class="cancel-btn">취소</button>
        <button type="submit" class="submit-btn" onclick="return validateRegistration()">회원가입</button>
    </div>
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

        // 이메일 도메인 값을 선택하면, '@' 기호와 이전 도메인 부분을 무조건 제거하고 ID만 남깁니다.
        // (선택된 값이 무엇이든 상관없이 동작합니다.)
        const currentEmailId = input.value.split('@')[0];
        input.value = currentEmailId;
    });

    // --- 0. 전역 상태 관리 변수 ---
    let isIdVerified = false;
    let verifiedIdValue = "";
    let isPasswdConfirmed = false;
    let confirmedPasswdValue = "";

    // --- 1. 아이디 중복 확인 (AJAX 통신) ---

    function checkIdDuplicate() {
        const memIdInput = document.getElementById('memId');
        const memId = memIdInput.value.trim();

        if (memId === "") {
            alert("아이디를 입력하세요.");
            memIdInput.focus();
            return;
        }

        isIdVerified = false;

        fetch('checkIdAction.jsp?memId=' + encodeURIComponent(memId), {
            method: 'GET'
        })
            .then(response => response.text())
            .then(result => {
                const trimmedResult = result.trim();

                if (trimmedResult === 'true') {
                    alert(` 사용 가능한 아이디입니다.`);
                    isIdVerified = true;
                    verifiedIdValue = memId;
                } else if (trimmedResult === 'false') {
                    alert(`이미 사용중인 아이디입니다.`);
                    isIdVerified = false;
                    memIdInput.focus();
                } else {
                    alert("서버 응답 오류 발생.");
                    isIdVerified = false;
                }
            })
            .catch(error => {
                alert("서버 통신 중 오류가 발생했습니다.");
                console.error('AJAX Error:', error);
                isIdVerified = false;
            });
    }

    document.getElementById('memId').addEventListener('input', function() {
        isIdVerified = false;
    });

    // --- 2. 비밀번호 확인 (클라이언트 측) ---

    function checkPasswordConfirm() {
        const passwordInput = document.getElementById('memPasswd');
        const confirmInput = document.getElementById('passwordConfirm');

        const password = passwordInput.value;
        const confirm = confirmInput.value;

        isPasswdConfirmed = false;

        if (password === "" || confirm === "") {
            alert("비밀번호와 비밀번호 확인란을 모두 입력해 주세요.");
            return;
        }

        if (password === confirm) {
            alert("비밀번호가 일치합니다.");
            isPasswdConfirmed = true;
            confirmedPasswdValue = password;
        } else {
            alert("비밀번호가 일치하지 않습니다. 다시 입력해 주세요.");
            isPasswdConfirmed = false;
            confirmInput.value = '';
            confirmInput.focus();
        }
    }

    document.getElementById('memPasswd').addEventListener('input', function() {
        isPasswdConfirmed = false;
    });

    document.getElementById('passwordConfirm').addEventListener('input', function() {
        isPasswdConfirmed = false;
    });


    // --- 3. 최종 제출 검증 (필수 필드 검사 로직 추가) ---

    function validateRegistration() {

        const currentMemId = document.getElementById('memId').value.trim();
        const currentPasswd = document.getElementById('memPasswd').value;

        // 1. 아이디 중복 확인 검증
        if (!isIdVerified) {
            alert("아이디 중복확인을 먼저 완료해 주세요.");
            document.getElementById('memId').focus();
            return false;
        }

        if (currentMemId !== verifiedIdValue) {
            alert("아이디 중복확인 후 값을 수정했습니다. 다시 확인해 주세요.");
            document.getElementById('memId').focus();
            return false;
        }

        // 2. 비밀번호 일치 확인 검증
        if (!isPasswdConfirmed) {
            alert("비밀번호 확인 버튼을 먼저 눌러 일치 여부를 확인해 주세요.");
            document.getElementById('passwordConfirm').focus();
            return false;
        }

        if (currentPasswd !== confirmedPasswdValue) {
            alert("비밀번호 확인 후 값을 수정했습니다. 다시 확인해 주세요.");
            document.getElementById('passwordConfirm').focus();
            return false;
        }

        // 모든 검증 통과
        return true;
    }
</script>
<script src="include.js"></script>
</body>
</html>
