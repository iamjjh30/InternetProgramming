<%@ page contentType="text/html;charset=euc-kr" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>판매하기</title>
    <link rel="stylesheet" href="insertItem.css" />
</head>
<body>
<div id="header-placeholder"></div>
<div class="container">
    <h2>판매하기</h2>
    <form class="sell-form" enctype="multipart/form-data">
        <div class="form-left">
            <label for="productImage" class="image-label">
                <img id="previewImage" src="https://via.placeholder.com/250?text=상품+사진" alt="상품 사진" />
            </label>
            <input type="file" id="productImage" accept="image/*" style="display: none;" />
        </div>

        <div class="form-right">
            <label for="title">제목</label>
            <input type="text" id="title" placeholder="제목을 입력하세요." />

            <label for="price">가격</label>
            <div class="price-row">
                <input type="number" id="price" placeholder="가격을 입력하세요." />
                <span>원</span>
                <select id="delivery">
                    <option>없음</option>
                    <option>배송비 포함</option>
                    <option>배송비 별도</option>
                </select>
            </div>

            <label for="description">상품정보</label>
            <textarea id="description" rows="5" placeholder="상품정보를 입력하세요."></textarea>
        </div>
    </form>

    <div class="button-group">
        <button type="button" class="cancel-btn">취소</button>
        <button type="submit" class="submit-btn">등록하기</button>
    </div>
</div>
<script>
    document.getElementById('productImage').addEventListener('change', function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (event) {
            document.getElementById('previewImage').src = event.target.result;
        };
        reader.readAsDataURL(file);
    });
</script>
<script src="include.js"></script>
</body>
</html>
