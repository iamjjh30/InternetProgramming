<%@page contentType="text/html; charset=utf-8"%>
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

<form action="insertItemAction.jsp" method="post" enctype="multipart/form-data">

    <div class="sell-container">

        <div class="image-section">
            <label for="itemImageInput" class="image-box">
                <img id="previewImage" src="" alt="상품 사진" />
                <span class="placeholder">상품 사진</span>
            </label>
            <input type="file" name="goodsImg" id="itemImageInput" accept="image/*" style="display:none;">
        </div>

        <div class="form-section">

            <label class="form-label">제목</label>
            <input type="text" name="itemName" class="input-field" placeholder="제목을 입력하세요.">

            <label class="form-label">카테고리</label>
            <select name="ctgType" class="input-field">
                <option value="none" disabled selected>카테고리를 선택하세요</option>
                <option value="패션의류">패션의류</option>
                <option value="뷰티">뷰티</option>
                <option value="모바일/태블릿">모바일/태블릿</option>
                <option value="가전제품">가전제품</option>
            </select>

            <label class="form-label">가격</label>
            <div class="price-row">
                <input type="text" name="itemPrice" class="input-field price" placeholder="가격을 입력하세요.">
                <span class="won">원</span>

                <label class="form-label ship-label">배송비</label>
                <select name="shippingFee" class="ship-select">
                    <option selected value="0">없음</option>
                    <option value="1000">1,000원</option>
                    <option value="2000">2,000원</option>
                    <option value="3000">3,000원</option>
                </select>
            </div>

            <label class="form-label">상품정보</label>
            <textarea name="itemInfo" class="textarea" placeholder="상품정보를 입력하세요."></textarea>

        </div>
    </div>

    <div class="btn-row">
        <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
        <button type="submit" class="submit-btn">등록하기</button>
    </div>
</form>
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
