<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // ⭐️ JSP에서 Context Root를 가져와 JavaScript 변수로 저장 ⭐️
    String contextPath = request.getContextPath();
%>
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

    <form name="filterForm" id="filterForm" method="GET" action="itemSearch.jsp">
        <table class="filter-table">
            <tr>
                <th>가격</th>
                <td>
                    <input type="number" placeholder="최소가격" class="price-input" name="minPrice">
                    ~
                    <input type="number" placeholder="최대가격" class="price-input" name="maxPrice">
                    <button type="button" class="search-btn">검색</button>
                </td>
            </tr>

            <tr>
                <th>옵션</th>
                <td class="option-row">
                    <label><input type="checkbox" name="freeDelivery" value="true"> 무료배송</label>
                    <label><input type="checkbox" name="selling" value="onSale"> 판매중</label>
                    <label><input type="checkbox" name="soldout" value="SoldOut"> 판매완료</label>
                </td>
            </tr>

            <tr>
                <th>카테고리</th>
                <td class="category-row">
                    <select name="category" id="categorySelect" class="category-select">

                        <option value="" <%= request.getParameter("category") == null || request.getParameter("category").trim().isEmpty() ? "selected" : "" %>>
                            전체 보기
                        </option>

                        <option value="패션의류" <%= "패션의류".equals(request.getParameter("category")) ? "selected" : "" %>>
                            패션의류
                        </option>
                        <option value="뷰티" <%= "뷰티".equals(request.getParameter("category")) ? "selected" : "" %>>
                            뷰티
                        </option>
                        <option value="가전제품" <%= "가전제품".equals(request.getParameter("category")) ? "selected" : "" %>>
                            가전제품
                        </option>
                        <option value="모바일/태블릿" <%= "모바일/태블릿".equals(request.getParameter("category")) ? "selected" : "" %>>
                            모바일/태블릿
                        </option>

                    </select>
                </td>
            </tr>
        </table>
    </form>

    <div class="sort-box">
        <a href="#" class="sort-item active">최신순</a>
        <a href="#" class="sort-item">낮은가격순</a>
        <a href="#" class="sort-item">높은가격순</a>
    </div>

    <div class="item-list" id="productListContainer">
        <p style="text-align: center; width: 100%; color: #777;">상품을 불러오는 중입니다...</p>
    </div>
</div>

<script src="include.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    var contextRoot = '<%= contextPath %>';
    $(document).ready(function() {

        // 페이지 로드 시 또는 카테고리/검색 이벤트 발생 시 호출될 함수
        function filterProducts() {
            // 1. 현재 선택된 필터 값을 가져옵니다.
            var category = $('#categorySelect').val();
            var minPrice = $('input[name="minPrice"]').val();
            var maxPrice = $('input[name="maxPrice"]').val();
            var selling = $('input[name="selling"]:checked').val(); // 판매중 체크 여부
            var soldout = $('input[name="soldout"]:checked').val(); // 판매완료 체크 여부
            var freeDelivery = $('input[name="freeDelivery"]:checked').val();

            // 2. 서버로 보낼 데이터 객체 생성
            var dataToSend = {
                category: category,
                minPrice: minPrice,
                maxPrice: maxPrice,
                freeDelivery: freeDelivery,
                selling: selling,
                soldout: soldout
            };


            // 3. AJAX 요청 전송
            $.ajax({
                type: "GET",
                url: contextRoot + "itemSearchData.jsp", // 데이터 조회를 담당하는 파일
                data: dataToSend,
                beforeSend: function() {
                    // 요청 시작 전 로딩 메시지 표시
                    $('#productListContainer').html('<p style="text-align: center; width: 100%; color: #333;">상품을 검색 중입니다...</p>');
                },
                success: function(response) {
                    // 4. 성공 시, 서버가 반환한 HTML로 목록 영역을 업데이트
                    $('#productListContainer').html(response);

                    // URL 상태 유지 (선택 사항)
                    var newUrl = 'itemSearch.jsp?category=' + category;
                    history.pushState(dataToSend, '', newUrl);
                },
                error: function(xhr, status, error) {
                    // 5. 오류 발생 시 메시지 표시
                    $('#productListContainer').html('<p style="text-align: center; width: 100%; color: red;">상품 검색에 실패했습니다. 서버 오류(' + xhr.status + ')가 발생했습니다.</p>');
                    console.error("AJAX Error:", status, error);
                }
            });
        }

        // 1. 초기 로드 시 상품 목록을 한 번 불러옵니다.
        filterProducts();

        // 2. 카테고리 드롭다운 메뉴 변경 이벤트
        $('#categorySelect').on('change', function() {
            filterProducts();
        });

        // 3. 가격 검색 버튼 클릭 이벤트
        $('.search-btn').on('click', function(e) {
            filterProducts();
        });

        $('.option-row input[type="checkbox"]').on('change', function() {
            filterProducts();
        });
    });
</script>

</body>
</html>