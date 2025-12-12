<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 로그인 확인
    String memId = (String) session.getAttribute("userId"); // 세션 ID (sellerId/buyerId)
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
    boolean isWishTab = "wish".equals(currentStatus);

    // '판매중' 탭 클릭 시 (status=selling)
    if ("selling".equals(currentStatus)) {
        statusFilter = " AND status = ?";
        statusValue = "onSale"; // DB의 '판매중' 값
    }
    // '판매완료' 탭 클릭 시 (status=soldout)
    else if ("soldout".equals(currentStatus)) {
        statusFilter = " AND status = ?";
        statusValue = "SoldOut"; // DB의 '판매완료' 값
    }

    String memName = ""; // 사용자 이름 변수 초기화

    // DB 관련 변수 및 접속 정보
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    // 3. 상품 정보 저장을 위한 리스트
    // [0:prdNo, 1:prdName, 2:prdPrice, 3:ctgType, 4:prdDescription, 5:goodsImg, 6:status]
    List<Object[]> productList = new ArrayList<>();

    // ⭐️ 주문 내역 저장을 위한 리스트 ⭐️
    // [0:ordNo, 1:ordDate, 2:sellStatus, 3:prdNo, 4:prdName, 5:totalPrice, 6:goodsImg]
    List<Object[]> orderList = new ArrayList<>();

    int paramIndex = 1;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 4. 사용자 이름 조회
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

        // 5. 사용자가 등록한 상품 또는 찜 목록 조회
        // ----------------------------------------------------
        String goodsSql = "";
        if (isWishTab) {
            // 찜 목록 조회 SQL: wishlist 테이블과 goods 테이블을 memId로 조인
            goodsSql = "SELECT g.prdNo, g.prdName, g.prdPrice, g.ctgType, g.prdDescription, g.goodsImg, g.status " +
                    "FROM goods g JOIN wishlist w ON g.prdNo = w.prdNo " +
                    "WHERE w.memId = ? ORDER BY w.wishNo DESC";
            pstmt = conn.prepareStatement(goodsSql);
            pstmt.setString(paramIndex, memId);
        } else {
            goodsSql = "SELECT prdNo, prdName, prdPrice, ctgType, prdDescription, goodsImg, status " +
                    "FROM goods WHERE sellerId = ?" + statusFilter + " ORDER BY prdNo DESC";

            pstmt = conn.prepareStatement(goodsSql);
            pstmt.setString(paramIndex++, memId);

            if (!statusFilter.isEmpty()) {
                pstmt.setString(paramIndex, statusValue);
            }
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
            product[5] = rs.getString("goodsImg");
            product[6] = rs.getString("status");
            productList.add(product);
        }

        // 이전 pstmt와 rs는 닫고 새로 생성
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();

        // ⭐️ 6. 주문 내역 조회 로직 추가 ⭐️
        // ----------------------------------------------------
        String orderSql = "SELECT "
                + "    o.ordNo, o.ordDate, o.sellStatus, o.prdNo, "
                + "    g.prdName, g.prdPrice, g.prdDeliver, g.goodsImg "
                + "FROM "
                + "    orderinfo o "
                + "JOIN "
                + "    goods g ON o.prdNo = g.prdNo "
                + "WHERE "
                + "    o.memId = ? "
                + "ORDER BY "
                + "    o.ordDate DESC";

        pstmt = conn.prepareStatement(orderSql);
        pstmt.setString(1, memId);
        rs = pstmt.executeQuery();

        // 주문 내역 데이터를 List에 저장
        while(rs.next()) {
            Object[] order = new Object[7];
            order[0] = rs.getString("ordNo");
            order[1] = rs.getTimestamp("ordDate"); // Timestamp 타입으로 저장
            order[2] = rs.getString("sellStatus");
            order[3] = rs.getString("prdNo");
            order[4] = rs.getString("prdName");

            int prdPrice = rs.getInt("prdPrice");
            int prdDeliver = rs.getInt("prdDeliver");
            order[5] = prdPrice + prdDeliver; // 총 결제 금액

            order[6] = rs.getString("goodsImg");
            orderList.add(order);
        }

    } catch (SQLException e) {
        System.out.println("DB 오류: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        // 7. 리소스 해제
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지</title>
    <link rel="stylesheet" href="myPage.css">
    <style>
        /* 주문 내역 섹션에 필요한 추가 스타일 */
        .order-history-section {
            margin-top: 50px;
            padding-top: 30px;
            border-top: 2px solid #eee;
        }
        .order-history-section h2 {
            font-size: 24px;
            color: #222;
            margin-bottom: 20px;
        }
        .order-history-section table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
        }
        .order-history-section th, .order-history-section td {
            border: 1px solid #ddd;
            padding: 12px;
            vertical-align: middle;
        }
        .order-history-section th {
            background-color: #f8f8f8;
            font-weight: bold;
        }
        .product-info-cell {
            display: flex;
            align-items: center;
            gap: 10px;
            text-align: left;
        }
        .order-img {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 4px;
        }
        .no-data {
            text-align: center;
            color: #777;
            padding: 20px;
        }
    </style>
</head>
<body>
<div id="header-placeholder"></div>

<div class="container">

    <div class="user-profile-section">
        <div class="profile-image-box">
            <%
                String contextPath = request.getContextPath();
                if (userProfileImg != null && !userProfileImg.isEmpty()) {
                    String absolutePath = contextPath + (userProfileImg.startsWith("/") ? userProfileImg : "/" + userProfileImg);
            %>
            <img src="<%= absolutePath %>" alt="<%= memName %> 프로필">
            <%
            } else {
            %>
            <img src="./images/free-icon-profile-3106773.png" alt="기본 프로필">
            <%
                }
            %>
        </div>
        <div class="user-info">
            <h1><%= memName %></h1>
        </div>
    </div>

    <div class="order-history-section">
        <h2>내 주문 내역</h2>
        <table>
            <thead>
            <tr>
                <th>주문번호</th>
                <th>주문일자</th>
                <th>상품 정보</th>
                <th>결제 금액</th>
                <th>처리 상태</th>
            </tr>
            </thead>
            <tbody>
            <%
                if (orderList.isEmpty()) {
            %>
            <tr>
                <td colspan="5" class="no-data">주문 내역이 없습니다.</td>
            </tr>
            <%
            } else {
                NumberFormat nf = NumberFormat.getInstance();
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

                for (Object[] order : orderList) {
                    String ordNo = (String) order[0];
                    Timestamp ordDate = (Timestamp) order[1];
                    String sellStatus = (String) order[2];
                    String prdNo = (String) order[3];
                    String prdName = (String) order[4];
                    int totalPrice = (Integer) order[5];
                    String goodsImgPath = (String) order[6];
            %>
            <tr>
                <td><%= ordNo %></td>
                <td><%= sdf.format(ordDate) %></td>
                <td>
                    <div class="product-info-cell">
                        <% if (goodsImgPath != null && !goodsImgPath.isEmpty()) { %>
                        <img src="<%= goodsImgPath %>" alt="<%= prdName %> 이미지" class="order-img">
                        <% } else { %>
                        <div class="order-img" style="background-color: #f0f0f0; border: 1px solid #ddd;">No Image</div>
                        <% } %>
                        <a href="viewItem.jsp?prdNo=<%= prdNo %>"><%= prdName %></a>
                    </div>
                </td>
                <td><%= nf.format(totalPrice) %>원</td>
                <td><%= sellStatus %></td>
            </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>
    </div>

    <h2 style="margin-top: 50px; font-size: 24px; color: #222;">내 게시글 / 찜 목록</h2>

    <div class="post-tabs">
        <div class="tab-menu">
            <%
                boolean isSelling = "selling".equals(currentStatus);
                boolean isSoldout = "soldout".equals(currentStatus);
                boolean isAll = !isSelling && !isSoldout && !isWishTab; // '전체' 탭 로직 수정
            %>
            <a href="myPage.jsp" class="<%= isAll ? "active" : "" %>">전체</a>

            <a href="myPage.jsp?status=selling" class="<%= isSelling ? "active" : "" %>">판매중</a>

            <a href="myPage.jsp?status=soldout" class="<%= isSoldout ? "active" : "" %>">판매완료</a>

            <a href="myPage.jsp?status=wish" class="<%= isWishTab ? "active" : "" %>">찜</a>
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
                // ... (기존 상품 목록 출력 로직 유지) ...
                String prdNo = (String) product[0];
                String prdName = (String) product[1];
                int prdPrice = (Integer) product[2];
                String ctgType = (String) product[3];
                String goodsImgPath = (String) product[5];
                String prdStatus = (String) product[6];

                String statusDisplay = "";
                String statusClass = "";

                if ("onSale".equals(prdStatus)) {
                    statusDisplay = "판매중";
                    statusClass = "status-onSale";
                } else if ("SoldOut".equals(prdStatus)) {
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
                <% if (!isWishTab) { %>
                <button class="btn-modify" onclick="location.href='updateItem.jsp?prdNo=<%= prdNo %>'">수정</button>
                <button class="btn-delete" onclick="location.href='deleteItem.jsp?prdNo=<%= prdNo %>'">삭제</button>
                <% } %>
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