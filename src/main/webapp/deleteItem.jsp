<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. 상품 번호(prdNo) 가져오기
    String prdNo = request.getParameter("prdNo");

    // 2. 로그인된 사용자 ID 가져오기 (권한 확인용)
    String memId = (String) session.getAttribute("userId");

    if (prdNo == null || prdNo.trim().isEmpty() || memId == null) {
%>
<script>
    alert("잘못된 접근이거나 세션이 만료되었습니다.");
    history.back();
</script>
<%
        return;
    }

    // DB 관련 변수 및 상품 정보 저장 변수
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming";
    String dbUser = "multi";
    String dbPass = "abcd";

    // 상품 정보를 저장할 변수
    String prdName = "정보 없음";
    String prdDescription = "정보 없음";
    int prdPrice = 0;
    String goodsImg = null;
    boolean isOwner = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 3. 상품 정보 조회 (sellerId도 함께 조회하여 현재 사용자가 판매자인지 확인)
        String sql = "SELECT prdName, prdPrice, prdDescription, goodsImg, sellerId FROM goods WHERE prdNo = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, prdNo);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            prdName = rs.getString("prdName");
            prdPrice = rs.getInt("prdPrice");
            prdDescription = rs.getString("prdDescription");
            goodsImg = rs.getString("goodsImg");

            // 4. 권한 확인: 현재 로그인 ID와 상품의 sellerId가 일치하는지 확인
            if (memId.equals(rs.getString("sellerId"))) {
                isOwner = true;
            }
        }

    } catch (SQLException e) {
        System.out.println("DB 오류: " + e.getMessage());
        // 필요하다면 사용자에게 오류 알림
    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    // 5. 권한 및 상품 존재 여부 확인
    if (!isOwner) {
%>
<script>
    alert("삭제 권한이 없거나 상품을 찾을 수 없습니다.");
    location.href = "myPage.jsp";
</script>
<%
        return;
    }

    // 가격 포맷팅 (예: 300000 -> 300,000)
    java.text.NumberFormat nf = java.text.NumberFormat.getInstance();
    String formattedPrice = nf.format(prdPrice);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>상품 삭제 확인</title>
    <link rel="stylesheet" href="deleteItem.css">
</head>
<body>
<div id="header-placeholder"></div>
<div class="delete-container">
    <h2>다음의 글을 <span style="color: #ff4757;">삭제</span>합니다.</h2>

    <div class="content-area">
        <div class="item-image-box">
            <% if (goodsImg != null && !goodsImg.isEmpty()) { %>
            <img src="<%= goodsImg %>" alt="<%= prdName %> 이미지">
            <% } else { %>
            상품 사진 <% } %>
        </div>

        <div class="item-details">
            <p><span class="label">제목</span><%= prdName %></p>
            <p><span class="label">가격</span><span class="price-text"><%= formattedPrice %></span> 원</p>

            <p style="margin-top: 30px;">
                <span class="label" style="display: block;">상품정보</span>
                <%= prdDescription.replace("\n", "<br>") %>
            </p>
        </div>
    </div>

    <div class="button-group">
        <button class="btn-cancel" onclick="history.back()">취소</button>

        <button class="btn-delete" onclick="location.href='deleteItemAction.jsp?prdNo=<%= prdNo %>'">삭제하기</button>
    </div>
</div>
<script src="include.js"></script>
</body>
</html>