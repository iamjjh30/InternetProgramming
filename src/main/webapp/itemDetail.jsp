<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>상품 상세</title>
    <link rel="stylesheet" href="itemDetail.css">
</head>

<body>

<div id="header-placeholder"></div>

<!-- 전체 컨테이너 -->
<div class="detail-container">

    <!-- 왼쪽: 상품 사진 -->
    <div class="left-box">
        <div class="product-img">상품 사진</div>
    </div>

    <!-- 오른쪽: 상품 요약 정보 -->
    <div class="right-box">
        <h2 class="title">제목</h2>

        <div class="price">15,000원</div>
        <div class="delivery">배송비 2,000원</div>

        <!-- 버튼 영역 -->
        <div class="button-row">
            <button class="chat-btn">찜하기</button>
            <button class="buy-btn">구매하기</button>
        </div>
    </div>
</div>

<!-- 하단 2열 컨테이너 -->
<div class="bottom-section">

    <!-- 상품 정보 영역 -->
    <div class="bottom-left">
        <h3>상품 정보</h3>
        <p>상품 상세 정보 텍스트</p>
    </div>

    <!-- 판매자 정보 -->
    <div class="bottom-right">
        <h3>판매자 정보</h3>
        <div class="seller-box">
            <div class="seller-name">닉네임</div>
            <div class="seller-img">👤</div>
        </div>
    </div>

</div>


<script src="include.js"></script>

</body>
</html>
