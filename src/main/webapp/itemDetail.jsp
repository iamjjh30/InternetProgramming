<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>

<%
    // 1. 파라미터 받기 (상품 번호)
    String prdNo = request.getParameter("prdNo");

    // 상품 정보 저장을 위한 변수 초기화
    String prdName = "상품 없음";
    int prdPrice = 0;
    int prdDeliver = 0;
    String goodsImgPath = "";
    String prdContent = "상품 상세 정보가 없습니다.";
    String sellerId = "판매자 정보 없음";
    String sellerProfileImg = "default_profile.png";

    // 가격 포맷 설정
    NumberFormat nf = NumberFormat.getInstance();

    // 2. DB 접속 및 조회 설정
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement pstmtMember = null;
    ResultSet rsMember = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    // 3. 상품 상세 조회 SQL
    // prdContent, prdDeliver 등을 포함하도록 SELECT 쿼리 작성
    String goodsSql = "SELECT prdName, prdPrice, prdDeliver, goodsImg, prdDescription, sellerId FROM goods WHERE prdNo = ?";

    String memberSql = "SELECT profileImg FROM member WHERE memId = ?";
    // 4. 상품 조회 및 데이터 저장
    if (prdNo != null && !prdNo.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            pstmt = conn.prepareStatement(goodsSql);
            pstmt.setString(1, prdNo);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                prdName = rs.getString("prdName");
                prdPrice = rs.getInt("prdPrice");
                prdDeliver = rs.getInt("prdDeliver");
                goodsImgPath = rs.getString("goodsImg");
                prdContent = rs.getString("prdDescription");
                sellerId = rs.getString("sellerId");

                if (sellerId != null && !sellerId.trim().isEmpty() && !"판매자 정보 없음".equals(sellerId)) {
                    pstmtMember = conn.prepareStatement(memberSql);
                    pstmtMember.setString(1, sellerId);
                    rsMember = pstmtMember.executeQuery();

                    if (rsMember.next()) {
                        String imgPathFromDb = rsMember.getString("profileImg");
                        if (imgPathFromDb != null && !imgPathFromDb.isEmpty()) {
                            sellerProfileImg = imgPathFromDb; // DB에서 가져온 프로필 이미지 경로 저장
                        }
                    }
                }
            } else {
                // 상품 번호가 유효하지 않을 경우
                prdName = "존재하지 않는 상품입니다.";
            }

        } catch (SQLException e) {
            System.out.println("DB 오류: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            System.out.println("드라이버 로드 오류: " + e.getMessage());
        } finally {
            // 5. 리소스 해제
            if (rs != null) try { rs.close(); } catch(SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
            if (conn != null) try { conn.close(); } catch(SQLException e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>상품 상세 - <%= prdName %></title>
    <link rel="stylesheet" href="itemDetail.css">
</head>

<body>

<div id="header-placeholder"></div>

<div class="detail-container">

    <div class="left-box">
        <div class="product-img">
            <%
                // 이미지 경로 유효성 검사 (uploads/null 처리 포함)
                boolean isImageAvailable = goodsImgPath != null && !goodsImgPath.isEmpty() && !goodsImgPath.trim().equals("uploads/null");
            %>
            <% if (isImageAvailable) { %>
            <img src="<%= goodsImgPath %>" alt="<%= prdName %> 이미지" style="width: 100%; height: 100%; object-fit: cover;">
            <% } else { %>
            상품 사진
            <% } %>
        </div>
    </div>

    <div class="right-box">
        <h2 class="title"><%= prdName %></h2>

        <div class="price"><%= nf.format(prdPrice) %>원</div>

        <div class="delivery">
            <% if (prdDeliver == 0) { %>
            배송비 무료
            <% } else { %>
            배송비 <%= nf.format(prdDeliver) %>원
            <% } %>
        </div>

        <div class="button-row">
            <button class="chat-btn">찜하기</button>
            <button class="buy-btn">구매하기</button>
        </div>
    </div>
</div>

<div class="bottom-section">

    <div class="bottom-left">
        <h3>상품 정보</h3>
        <p><%= prdContent.replace("\n", "<br>") %></p>
    </div>

    <div class="bottom-right">
        <h3>판매자 정보</h3>
        <div class="seller-box">
            <div class="seller-name"><%= sellerId %></div>
            <div class="seller-img">
                <%
                    // 프로필 이미지 경로 유효성 검사 (기본 이미지 포함)
                    // 실제 이미지가 uploads/profile/a.jpg 라면, 여기에 맞게 경로를 조정해야 합니다.
                    boolean isProfileImgAvailable = sellerProfileImg != null && !sellerProfileImg.isEmpty() && !sellerProfileImg.trim().equals("default_profile.png");
                %>
                <% if (isProfileImgAvailable) { %>
                <img src="<%= sellerProfileImg %>" alt="<%= sellerId %> 프로필" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                <% } else { %>
                <img src="./images/free-icon-profile-3106773.png" alt="기본 프로필" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                <% } %>
            </div>
        </div>

</div>


<script src="include.js"></script>

</body>
</html>