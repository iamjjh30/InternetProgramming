<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>

<%
    // 이 파일은 AJAX 요청을 처리하며, HTML <head>, <body> 태그 없이 데이터 출력 부분만 포함합니다.

    // 1. DB 접속 정보 설정
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // ⭐️ 인코딩 문제 해결을 위해 characterEncoding 설정 추가 ⭐️
    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    // 2. 파라미터 받기 및 SQL 조건 설정
    String categoryFilter = request.getParameter("category");
    String minPriceStr = request.getParameter("minPrice");
    String maxPriceStr = request.getParameter("maxPrice");
    String freeDeliveryFilter = request.getParameter("freeDelivery");
    String sellingFilter = request.getParameter("selling"); // "onSale" 값 기대
    String soldoutFilter = request.getParameter("soldout"); // "SoldOut" 값 기대

    // SQL WHERE 절의 조건 문자열과 바인딩할 파라미터 값을 저장할 리스트
    List<String> conditions = new ArrayList<>();
    List<Object> params = new ArrayList<>();

    // A. 카테고리 필터링 조건
    if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
        conditions.add("ctgType = ?");
        params.add(categoryFilter);
    }

    // B. 가격 필터링 조건
    try {
        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            int minPrice = Integer.parseInt(minPriceStr);
            conditions.add("prdPrice >= ?");
            params.add(minPrice);
        }
        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            int maxPrice = Integer.parseInt(maxPriceStr);
            conditions.add("prdPrice <= ?");
            params.add(maxPrice);
        }
    } catch (NumberFormatException e) {
        // 가격 입력이 숫자가 아닐 경우 오류 무시
    }

    if (freeDeliveryFilter != null) { // "true"가 전송된 경우 (체크된 경우)
        // prdDeliver 컬럼 값이 0인 상품만 조회
        conditions.add("prdDeliver = 0");
        // '0'은 고정된 숫자이므로 params.add()는 필요 없음
    }

    // C. 옵션 (판매 상태) 필터링 조건
    if (sellingFilter != null || soldoutFilter != null) {
        List<String> statusConditions = new ArrayList<>();

        // sellingFilter가 null이 아니면 (체크됨)
        if (sellingFilter != null) {
            statusConditions.add("status = ?");
            params.add(sellingFilter); // "onSale"
        }
        // soldoutFilter가 null이 아니면 (체크됨)
        if (soldoutFilter != null) {
            statusConditions.add("status = ?");
            params.add(soldoutFilter); // "SoldOut"
        }

        // (status = 'onSale' OR status = 'SoldOut') 형태의 OR 조건을 AND 조건 리스트에 추가
        if (!statusConditions.isEmpty()) {
            conditions.add("(" + String.join(" OR ", statusConditions) + ")");
        }
    }

    // 최종 WHERE 절 구성
    String whereClause = "";
    if (!conditions.isEmpty()) {
        whereClause = " WHERE " + String.join(" AND ", conditions);
    }

    // 3. 상품 정보 저장을 위한 리스트
    // [0:prdNo, 1:prdName, 2:prdPrice, 3:ctgType, 4:goodsImg, 5:status]
    List<Object[]> productList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 4. 상품 조회 SQL (동적으로 WHERE 절 추가)
        String goodsSql = "SELECT prdNo, prdName, prdPrice, ctgType, goodsImg, status FROM goods" + whereClause + " ORDER BY regDate DESC";

        pstmt = conn.prepareStatement(goodsSql);

        // ⭐️ PreparedStatement 값 바인딩 (동적) ⭐️
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof String) {
                pstmt.setString(i + 1, (String) param);
            } else if (param instanceof Integer) {
                pstmt.setInt(i + 1, (Integer) param);
            }
        }

        rs = pstmt.executeQuery();

        // 5. 상품 목록 데이터를 List에 저장
        while(rs.next()) {
            Object[] product = new Object[6];
            product[0] = rs.getString("prdNo");
            product[1] = rs.getString("prdName");
            product[2] = rs.getInt("prdPrice");
            product[3] = rs.getString("ctgType");
            product[4] = rs.getString("goodsImg");
            product[5] = rs.getString("status");
            productList.add(product);
        }

    } catch (SQLException e) {
        System.out.println("DB 오류: " + e.getMessage());
        // ⭐️ 디버깅을 위해 SQL 오류를 응답으로 출력할 수도 있습니다 (배포 시에는 제거)
        // out.println("<p style='color:red;'>DB 조회 오류 발생: " + e.getMessage() + "</p>");
    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        // 6. 리소스 해제
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>

<%
    // 7. 상품 목록 HTML 조각만 출력
    NumberFormat nf = NumberFormat.getInstance();
    if (productList.isEmpty()) {
%>
<p style="text-align: center; width: 100%; color: #777;">검색 결과가 없습니다.</p>
<%
} else {
    for (Object[] product : productList) {
        String prdNo = (String) product[0];
        String prdName = (String) product[1];
        int prdPrice = (Integer) product[2];
        String ctgType = (String) product[3];
        String goodsImgPath = (String) product[4];
        String prdStatus = (String) product[5];

        String statusDisplay = "판매중";
        String statusClass = "";

        // ⭐️ 이미지 경로 유효성 검사 추가 ⭐️
        boolean isImageAvailable = goodsImgPath != null && !goodsImgPath.isEmpty() && !goodsImgPath.trim().equals("uploads/null");

        // 판매 상태에 따른 텍스트 및 CSS 클래스 설정
        if ("SoldOut".equals(prdStatus)) {
            statusDisplay = "판매 완료";
            statusClass = "soldout";
        }
%>
<a href="itemDetail.jsp?prdNo=<%= prdNo %>" class="item-card">
    <div class="item-img">
        <% if (isImageAvailable) { %>
        <img src="<%= goodsImgPath %>" alt="<%= prdName %> 이미지" style="width: 100%; height: 100%; object-fit: cover;">
        <% } else { %>
        상품 사진
        <% } %>
    </div>
    <div class="item-status <%= statusClass %>"><%= statusDisplay %></div>
    <div class="item-title"><%= prdName %></div>
    <div class="item-cate"><%= ctgType %></div>
    <div class="item-price"><%= nf.format(prdPrice) %>원</div>
</a>
<%
        }
    }
%>