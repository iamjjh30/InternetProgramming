<%@ page contentType="text/html; charset=euc-kr" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <title>검색결과</title>
    <link rel="stylesheet" href="itemSearch.css">
</head>

<body>
<div id="header-placeholder"></div>

<div class="container">

    <h2 class="page-title">검색결과</h2>

    <!-- ? 가격 / 옵션 / 카테고리 필터 -->
    <table class="filter-table">
        <tr>
            <th>가격</th>
            <td>
                <input type="number" placeholder="최소가격" class="price-input">
                ~
                <input type="number" placeholder="최대가격" class="price-input">
                <button class="search-btn">검색</button>
            </td>
        </tr>

        <tr>
            <th>옵션</th>
            <td class="option-row">
                <label><input type="checkbox"> 무료배송</label>
                <label><input type="checkbox"> 판매중</label>
                <label><input type="checkbox"> 판매완료</label>
            </td>
        </tr>

        <tr>
            <th>카테고리</th>
            <td class="category-row">
                <input type="radio" name="category" value="fashion">패션의류</button>
                <input type="radio" name="category" value="beauty">뷰티</input>
                <input type="radio" name="category" value="mobile">모바일/태블릿</button>
                <input type="radio" name="category" value="appliances">가전제품</button>
            </td>
        </tr>
    </table>

    <!-- ? 정렬 메뉴 -->
    <div class="sort-box">
        <a href="#" class="sort-item active">최신순</a>
        <a href="#" class="sort-item">낮은가격순</a>
        <a href="#" class="sort-item">높은가격순</a>
    </div>

    <!-- ? 상품 리스트 -->
    <div class="item-list">
        <a href="itemDetail.jsp" class="item-card">
            <div class="item-img">상품 사진</div>
            <div class="item-status">판매중</div>
            <div class="item-title">제목</div>
            <div class="item-cate">카테고리</div>
            <div class="item-price">15,000원</div>
        </a>
        <a href="itemDetail.jsp" class="item-card">
            <div class="item-img">상품 사진</div>
            <div class="item-status">판매중</div>
            <div class="item-title">제목</div>
            <div class="item-cate">카테고리</div>
            <div class="item-price">50,000원</div>
        </a>
        <a href="itemDetail.jsp" class="item-card">
            <div class="item-img">상품 사진</div>
            <div class="item-status">판매중</div>
            <div class="item-title">제목</div>
            <div class="item-cate">카테고리</div>
            <div class="item-price">125,000원</div>
        </a>
        <a href="itemDetail.jsp" class="item-card">
            <div class="item-img">상품 사진</div>
            <div class="item-status">판매중</div>
            <div class="item-title">제목</div>
            <div class="item-cate">카테고리</div>
            <div class="item-price">11,000원</div>
        </a>

    </div>
</div>

<script src="include.js"></script>

</body>
</html>
