<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    // 1. 로그인 확인
    String memId = (String) session.getAttribute("userId"); // 세션 ID (sellerId)
    if (memId == null || memId.trim().isEmpty()) {
%>
<script>
    alert("로그인이 필요합니다.");
    location.href = "login.jsp";
</script>
<%
        return;
    }
    String userProfileImg = null;

    // 2. 탭 상태 파라미터 가져오기 및 SQL 조건 설정
    String currentStatus = request.getParameter("status");
    String statusFilter = "";
    String statusValue = "";

    // '판매중' 탭 클릭 시 (status=selling)
    if ("selling".equals(currentStatus)) {
        statusFilter = " AND status = ?";
        statusValue = "onSale"; // DB의 '판매중' 값 (image_c628f7.png에서 확인됨)
    }
    // '판매완료' 탭 클릭 시 (status=soldout)
    else if ("soldout".equals(currentStatus)) {
        statusFilter = " AND status = ?";
        statusValue = "SoldOut"; // DB의 '판매완료' 값 (DB에 저장된 실제 '판매완료' 값으로 사용)
    }

    String memName = ""; // 사용자 이름 변수 초기화

    // DB 관련 변수 및 접속 정보
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming";
    String dbUser = "multi";
    String dbPass = "abcd";

    // 3. 상품 정보 저장을 위한 리스트
    // [0:prdNo, 1:prdName, 2:prdPrice, 3:ctgType, 4:prdDescription, 5:goodsImg, 6:status]
    List<Object[]> productList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 4. 사용자 이름 조회
        // member 테이블에서 memId를 기준으로 memName 조회
        String nameSql = "SELECT memName, profileImg FROM member WHERE memId = ?";
        pstmt = conn.prepareStatement(nameSql);
        pstmt.setString(1, memId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            memName = rs.getString("memName");
            userProfileImg = rs.getString("profileImg");
        } else {
            memName = memId + " 님";
        }

        // 이전 pstmt와 rs는 닫고 새로 생성
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();

        // 5. 사용자가 등록한 상품 전체 조회
        // ----------------------------------------------------
        // SQL 쿼리: goodsImg와 status 컬럼을 포함하여 조회
        String goodsSql = "SELECT prdNo, prdName, prdPrice, ctgType, prdDescription, goodsImg, status FROM goods WHERE sellerId = ?" + statusFilter + " ORDER BY prdNo DESC";

        pstmt = conn.prepareStatement(goodsSql);

        // PreparedStatement에 값 설정
        pstmt.setString(1, memId); // 1. sellerId 바인딩

        int paramIndex = 2;
        if (!statusFilter.isEmpty()) {
            pstmt.setString(paramIndex, statusValue); // 2. status 값 바인딩 (필터링 조건)
        }

        rs = pstmt.executeQuery();

        // 상품 목록 데이터를 List에 저장
        while(rs.next()) {
            Object[] product = new Object[7];
            product[0] = rs.getString("prdNo");
            product[1] = rs.getString("prdName");
            product[2] = rs.getInt("prdPrice");
            product[3] = rs.getString("ctgType");
            product[4] = rs.getString("prdDescription");
            product[5] = rs.getString("goodsImg"); // goodsImg 컬럼
            product[6] = rs.getString("status");    // status 컬럼
            productList.add(product);
        }

    } catch (SQLException e) {
        System.out.println("DB 오류: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        // 6. 리소스 해제
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 내 게시글</title>
    <link rel="stylesheet" href="myPage.css">
</head>
<body>
<div id="header-placeholder"></div>

<div class="container">

    <div class="user-profile-section">
        <div class="profile-image-box">
            <%
                String contextPath = request.getContextPath();
                if (userProfileImg != null && !userProfileImg.isEmpty()) {
                    // ⭐️ 프로필 이미지가 있을 경우 <img> 태그 출력 ⭐️
                    // 절대 경로를 보장하여 이미지 로딩 오류를 방지합니다.
                    String absolutePath = contextPath + (userProfileImg.startsWith("/") ? userProfileImg : "/" + userProfileImg);
            %>
            <img src="<%= absolutePath %>" alt="<%= memName %> 프로필">
            <%
            } else {
                // 이미지가 없을 경우 기본 아이콘 출력
            %>
            <img src="./images/free-icon-profile-3106773.png">
            <%
                }
            %>
        </div>
        <div class="user-info">
            <h1><%= memName %></h1>
        </div>
    </div>

    <h2 style="margin-top: 30px; font-size: 24px; color: #222;">내 게시글</h2>

    <div class="post-tabs">
        <div class="tab-menu">
            <%
                boolean isSelling = "selling".equals(currentStatus);
                boolean isSoldout = "soldout".equals(currentStatus);
                boolean isAll = !isSelling && !isSoldout;
            %>
            <a href="myPage.jsp" class="<%= isAll ? "active" : "" %>">전체</a>

            <a href="myPage.jsp?status=selling" class="<%= isSelling ? "active" : "" %>">판매중</a>

            <a href="myPage.jsp?status=soldout" class="<%= isSoldout ? "active" : "" %>">판매완료</a>

            <a href="#">찜</a>
        </div>
    </div>

    <div class="item-list">
        <%
            if (productList.isEmpty()) {
        %>
        <p style="text-align: center; color: #777;">등록된 상품이 없습니다.</p>
        <%
        } else {
            for (Object[] product : productList) {
                String prdNo = (String) product[0];
                String prdName = (String) product[1];
                int prdPrice = (Integer) product[2];
                String ctgType = (String) product[3];
                String goodsImgPath = (String) product[5];
                String prdStatus = (String) product[6];    // DB에서 조회된 status 값

                String statusDisplay = "";
                String statusClass = "";

                // DB 값에 따라 표시 텍스트 및 클래스 설정
                if ("onSale".equals(prdStatus)) {
                    statusDisplay = "판매중";
                    statusClass = "status-onSale";
                } else if ("soldOut".equals(prdStatus)) {
                    statusDisplay = "판매 완료";
                    statusClass = "status-SoldOut";
                } else {
                    statusDisplay = prdStatus;
                    statusClass = "status-default";
                }

                java.text.NumberFormat nf = java.text.NumberFormat.getInstance();
                String formattedPrice = nf.format(prdPrice);
        %>
        <div class="item-card">
            <div class="item-image" onclick="location.href='viewItem.jsp?prdNo=<%= prdNo %>'">
                <% if (goodsImgPath != null && !goodsImgPath.isEmpty()) { %>
                <img src="<%= goodsImgPath %>" alt="<%= prdName %> 이미지">
                <% } else { %>
                <div style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background-color: #ddd;">제품 사진</div>
                <% } %>
            </div>
            <div class="item-details">
                <h3><%= prdName %></h3>
                <p style="margin-bottom: 0;"><%= ctgType %></p>
                <p class="item-price"><%= formattedPrice %>원</p>
            </div>
            <div class="item-status-group">
                <span class="status-badge <%= statusClass %>"><%= statusDisplay %></span>
                <button class="btn-modify" onclick="location.href='modifyItem.jsp?prdNo=<%= prdNo %>'">수정</button>
                <button class="btn-delete" onclick="location.href='deleteItem.jsp?prdNo=<%= prdNo %>'">삭제</button>
            </div>
        </div>
        <%
                }
            }
        %>
    </div>
</div>
<script src="include.js"></script>
</body>
</html>