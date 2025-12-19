<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>커뮤니티 마켓</title>
    <link rel="stylesheet" href="style.css" />
    <style>
        /* 상품 목록 섹션에 필요한 최소한의 스타일 */
        .product-section {
            max-width: 1200px;
            margin: 50px auto;
            padding: 0 20px;
        }
        .product-section h3 {
            font-size: 1.8em;
            margin-bottom: 25px;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }

        /* ⭐️ 변경된 CSS: 가로 스크롤 활성화 ⭐️ */
        .item-list {
            display: flex;
            flex-wrap: nowrap; /* 줄 바꿈 방지 */
            gap: 20px;
            overflow-x: auto; /* 가로 스크롤 활성화 */
            padding-bottom: 15px; /* 스크롤바가 콘텐츠를 가리지 않도록 여백 추가 */
            justify-content: flex-start;
        }

        /* ⭐️ 변경된 CSS: 아이템 카드 너비를 고정 값으로 설정 ⭐️ */
        .item-card {
            flex-shrink: 0; /* 컨테이너가 줄어들 때 아이템이 줄어들지 않도록 설정 */
            width: 250px; /* 고정 너비 설정 (원래 4개였으므로 적당한 크기로 지정) */
            height: auto;
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
            text-decoration: none;
            color: #333;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s;
            position: relative;
        }
        .item-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }
        .item-image {
            width: 100%;
            height: 180px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f8f8;
        }
        .item-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .item-details {
            padding: 15px;
        }
        .item-details h4 {
            font-size: 1.1em;
            margin: 0 0 5px 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .item-price {
            font-size: 1.2em;
            font-weight: bold;
            color: #333;
            margin: 0;
        }
        .item-status {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: green;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: bold;
        }
        .item-status.soldout {
            background-color: red;
        }
    </style>
</head>
<body>

<%
    // 1. DB 접속 및 조회 설정
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 상품 정보 저장을 위한 리스트 [prdNo, prdName, prdPrice, goodsImg, status]
    List<Object[]> recentProducts = new ArrayList<>();
    NumberFormat nf = NumberFormat.getInstance();

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 2. 최근 등록된 상품 8개 조회 SQL
        String goodsSql = "SELECT prdNo, prdName, prdPrice, goodsImg, status FROM goods where status = 'onSale' ORDER BY regDate DESC LIMIT 8";

        pstmt = conn.prepareStatement(goodsSql);
        rs = pstmt.executeQuery();

        // 3. 상품 목록 데이터 저장
        while(rs.next()) {
            Object[] product = new Object[5];
            product[0] = rs.getString("prdNo");
            product[1] = rs.getString("prdName");
            product[2] = rs.getInt("prdPrice");
            product[3] = rs.getString("goodsImg");
            product[4] = rs.getString("status");
            recentProducts.add(product);
        }

    } catch (SQLException e) {
        System.out.println("메인 상품 조회 DB 오류: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        // 4. 리소스 해제
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>


<div id="header-placeholder"></div>
<main class="main-container">
    <section class="hero">
        <div class="hero-text">
            <h2>
                당신의 취향이 만나는 곳, 모두의 중고생활<br />
                거래를 넘어, 사람과 취향이 연결되는 커뮤니티 마켓
            </h2>
            <a href="register.jsp"><button class="start-btn">지금 시작하기 →</button></a>
        </div>
        <div class="hero-img">
        </div>
    </section>

    <section class="product-section">
        <h3>✨ 최근 등록된 상품</h3>
        <div class="item-list">
            <%
                if (recentProducts.isEmpty()) {
            %>
            <p style="text-align: center; width: 100%; color: #777;">아직 등록된 상품이 없습니다.</p>
            <%
            } else {
                for (Object[] product : recentProducts) {
                    String prdNo = (String) product[0];
                    String prdName = (String) product[1];
                    int prdPrice = (Integer) product[2];
                    String goodsImgPath = (String) product[3];
                    String prdStatus = (String) product[4];

                    String statusDisplay = "판매중";
                    String statusClass = "";

                    if ("SoldOut".equals(prdStatus)) {
                        statusDisplay = "판매 완료";
                        statusClass = "soldout";
                    }

                    boolean isImageAvailable = goodsImgPath != null && !goodsImgPath.isEmpty();
            %>
            <a href="itemDetail.jsp?prdNo=<%= prdNo %>" class="item-card">
                <div class="item-image">
                    <% if (isImageAvailable) { %>
                    <img src="<%= goodsImgPath %>" alt="<%= prdName %> 이미지">
                    <% } else { %>
                    <div style="text-align: center; color: #999;">이미지 없음</div>
                    <% } %>
                </div>
                <div class="item-details">
                    <span class="item-status <%= statusClass %>"><%= statusDisplay %></span>
                    <h4><%= prdName %></h4>
                    <p class="item-price"><%= nf.format(prdPrice) %>원</p>
                </div>
            </a>
            <%
                    }
                }
            %>
        </div>
    </section>
</main>
<script src="include.js"></script>
</body>
</html>