<%@page contentType="text/html; charset=euc-kr"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>판매하기</title>
    <link rel="stylesheet" href="insertItem.css" />
</head>
<body>
<div id="header-placeholder"></div>

<!-- ========================== -->
<!--          본문              -->
<!-- ========================== -->

<h2 class="title">판매하기</h2>

<div class="sell-container">

    <!-- 상품 이미지 -->
    <div class="image-section">
        <label for="itemImageInput" class="image-box">
            <img id="previewImage" src="" alt="상품 사진" />
            <span class="placeholder">상품 사진</span>
        </label>
        <input type="file" id="itemImageInput" accept="image/*" style="display:none;">
    </div>

    <!-- 상품 정보 입력 -->
    <div class="form-section">

        <label class="form-label">제목</label>
        <input type="text" class="input-field" placeholder="제목을 입력하세요.">

        <label class="form-label">가격</label>
        <div class="price-row">
            <input type="text" class="input-field price" placeholder="가격을 입력하세요.">
            <span class="won">원</span>

            <label class="form-label ship-label">배송비</label>
            <select class="ship-select">
                <option selected>없음</option>
                <option>1,000원</option>
                <option>2,000원</option>
                <option>3,000원</option>
            </select>
        </div>

        <label class="form-label">상품정보</label>
        <textarea class="textarea" placeholder="상품정보를 입력하세요."></textarea>

    </div>
</div>

<!-- 버튼 -->
<div class="btn-row">
    <button class="cancel-btn">취소</button>
    <button class="submit-btn">등록하기</button>
</div>
<script>
// 상품 이미지 미리보기
document.getElementById("itemImageInput").addEventListener("change", function (e) {
const file = e.target.files[0];
if (!file) return;

const reader = new FileReader();
reader.onload = function (event) {
const img = document.getElementById("previewImage");
img.src = event.target.result;
img.style.display = "block";

document.querySelector(".placeholder").style.display = "none";
};
reader.readAsDataURL(file);
});
</script>
<script src="include.js"></script>

</body>
</html>
