<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // JSP에서 Context Root를 가져와 JavaScript 변수로 저장
    String contextPath = request.getContextPath();
    String initialKeyword = request.getParameter("keyword");
    if (initialKeyword == null) initialKeyword = "";
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
        <input type="hidden" name="keyword" id="keywordInput" value="<%= initialKeyword %>">
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
        <a href="javascript:void(0);" class="sort-item active" data-sort-field="prdNo" data-sort-order="DESC">최신순</a>
        <a href="javascript:void(0);" class="sort-item" data-sort-field="prdPrice" data-sort-order="ASC">낮은가격순</a>
        <a href="javascript:void(0);" class="sort-item" data-sort-field="prdPrice" data-sort-order="DESC">높은가격순</a>
    </div>

    <div class="item-list" id="productListContainer">
        <p style="text-align: center; width: 100%; color: #777;">상품을 불러오는 중입니다...</p>
    </div>
</div>

<script src="include.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    var contextRoot = '<%= contextPath %>';
    var initialKeyword = '<%= initialKeyword %>';

    $(document).ready(function() {
        // ⭐️ 중요: 현재 정렬 상태를 저장할 변수를 먼저 선언합니다.
        var currentSortField = 'prdNo';
        var currentSortOrder = 'DESC';

        function filterProducts(sortField, sortOrder) {
            var keyword = $('#keywordInput').val();
            var category = $('#categorySelect').val();
            var minPrice = $('input[name="minPrice"]').val();
            var maxPrice = $('input[name="maxPrice"]').val();
            var selling = $('input[name="selling"]:checked').val();
            var soldout = $('input[name="soldout"]:checked').val();
            var freeDelivery = $('input[name="freeDelivery"]:checked').val();

            // 파라미터로 넘어온 값이 없으면 현재 저장된 상태를 사용
            var fSortField = sortField || currentSortField;
            var fSortOrder = sortOrder || currentSortOrder;

            var dataToSend = {
                keyword: keyword,
                category: category,
                minPrice: minPrice,
                maxPrice: maxPrice,
                freeDelivery: freeDelivery,
                selling: selling,
                soldout: soldout,
                sortField: fSortField,
                sortOrder: fSortOrder
            };

            $.ajax({
                type: "GET",
                url: contextRoot + "/itemSearchData.jsp",
                data: dataToSend,
                beforeSend: function() {
                    $('#productListContainer').html('<p style="text-align: center; width: 100%; color: #333;">상품을 검색 중입니다...</p>');
                },
                success: function(response) {
                    $('#productListContainer').html(response);

                    // URL 상태 업데이트
                    var newUrl = 'itemSearch.jsp?category=' + category + '&sortField=' + fSortField;
                    history.pushState(dataToSend, '', newUrl);
                },
                error: function(xhr, status, error) {
                    $('#productListContainer').html('<p style="text-align: center; width: 100%; color: red;">오류가 발생했습니다.</p>');
                }
            });
        }

        // 1. 초기 로드
        filterProducts();

        // 2. 각종 필터 변경 이벤트
        $('#categorySelect, .option-row input[type="checkbox"]').on('change', function() {
            filterProducts();
        });

        $('.search-btn').on('click', function() {
            filterProducts();
        });

        // 3. 정렬 클릭 이벤트
        $('.sort-item').on('click', function(e) {
            e.preventDefault();

            var newSortField = $(this).data('sort-field');
            var newSortOrder = $(this).data('sort-order');

            $('.sort-item').removeClass('active');
            $(this).addClass('active');

            // ⭐️ 변수에 현재 정렬 상태 저장
            currentSortField = newSortField;
            currentSortOrder = newSortOrder;

            filterProducts(newSortField, newSortOrder);
        });
    });
</script>

</body>
</html>