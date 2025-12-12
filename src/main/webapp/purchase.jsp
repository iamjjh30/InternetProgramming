<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.UUID" %>

<%
    // 1. URL 파라미터에서 상품 번호 가져오기
    String prdNo = request.getParameter("prdNo");

    // 2. 로그인 여부 및 구매자 정보 확인 (세션)
    String buyerId = (String) session.getAttribute("userId");
    String buyerName = (String) session.getAttribute("userName"); // 세션에 이름이 저장되어 있다고 가정

    if (buyerId == null) {
        response.sendRedirect("login.jsp?redirectURL=purchase.jsp?prdNo=" + prdNo);
        return;
    }

    // 상품 및 구매자 정보 저장을 위한 변수 초기화
    String prdName = "";
    int prdPrice = 0;
    int prdDeliver = 0;
    String sellerId = "";
    String sellerNick = "";
    String goodsImgPath = "";
    int totalPrice = 0;

    // ⭐️ 추가: 판매자 프로필 이미지 변수 ⭐️
    String sellerProfileImg = "./images/free-icon-profile-3106773.png"; // 기본 이미지 경로

    // 구매자 연락처, 주소 (DB에서 조회할 값)
    String buyerPhone = "";
    String buyerAddress = "";
    String buyerDetailAddress = "";

    boolean isItemFound = false;

    // 3. DB 접속 정보
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement pstmtSeller = null;
    ResultSet rsSeller = null;
    PreparedStatement pstmtBuyer = null;
    ResultSet rsBuyer = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    NumberFormat nf = NumberFormat.getInstance();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // A. 상품 정보 조회 (goods 테이블)
        String goodsSql = "SELECT prdName, prdPrice, prdDeliver, sellerId, goodsImg FROM goods WHERE prdNo = ?";
        pstmt = conn.prepareStatement(goodsSql);
        pstmt.setString(1, prdNo);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            isItemFound = true;
            prdName = rs.getString("prdName");
            prdPrice = rs.getInt("prdPrice");
            prdDeliver = rs.getInt("prdDeliver");
            sellerId = rs.getString("sellerId");
            goodsImgPath = rs.getString("goodsImg");
            totalPrice = prdPrice + prdDeliver;

            // B. ⭐️ 수정: 판매자 이름 및 프로필 이미지 조회 (member 테이블) ⭐️
            String sellerNickSql = "SELECT memName, profileImg FROM member WHERE memId = ?";
            pstmtSeller = conn.prepareStatement(sellerNickSql);
            pstmtSeller.setString(1, sellerId);
            rsSeller = pstmtSeller.executeQuery();

            if (rsSeller.next()) {
                sellerNick = rsSeller.getString("memName");
                String imgPathFromDb = rsSeller.getString("profileImg");

                // 조회된 프로필 이미지가 있다면 변수에 저장
                if (imgPathFromDb != null && !imgPathFromDb.isEmpty()) {
                    sellerProfileImg = imgPathFromDb;
                }
            } else {
                sellerNick = "(판매자 정보 없음)";
            }

            // C. 구매자 정보 조회 (member 테이블)
            String buyerInfoSql = "SELECT memPhone, memAddress, memName FROM member WHERE memId = ?";
            pstmtBuyer = conn.prepareStatement(buyerInfoSql);
            pstmtBuyer.setString(1, buyerId);
            rsBuyer = pstmtBuyer.executeQuery();

            if (rsBuyer.next()) {
                buyerPhone = rsBuyer.getString("memPhone");
                buyerAddress = rsBuyer.getString("memAddress");
            }
        }

    } catch (SQLException e) {
        System.out.println("구매 페이지 DB 오류: " + e.getMessage());
        prdName = "상품 정보를 불러올 수 없습니다.";
        isItemFound = false;
    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        if (rsSeller != null) try { rsSeller.close(); } catch(SQLException e) {}
        if (pstmtSeller != null) try { pstmtSeller.close(); } catch(SQLException e) {}
        if (rsBuyer != null) try { rsBuyer.close(); } catch(SQLException e) {}
        if (pstmtBuyer != null) try { pstmtBuyer.close(); } catch(SQLException e) {}
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>구매하기 - <%= prdName %></title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* CSS 스타일링은 생략 (이전과 동일) */
        body { background-color: #f7f7f7; }
        .purchase-container {
            max-width: 900px;
            margin: 50px auto;
            padding: 30px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        .purchase-title { font-size: 2em; font-weight: bold; margin-bottom: 30px; }
        .content-wrapper { display: flex; gap: 40px; }
        .item-visual { flex-basis: 40%; }
        .item-visual .image-box {
            width: 100%;
            height: 350px;
            background-color: #f0f0f0;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #888;
            font-size: 1.2em;
            overflow: hidden;
            border-radius: 4px;
        }
        .item-visual img { width: 100%; height: 100%; object-fit: cover; }
        .item-details { flex-basis: 60%; }
        .detail-header { margin-bottom: 25px; }
        .detail-header h3 { font-size: 1.8em; margin: 0 0 10px 0; font-weight: bold; }
        .price-info {
            display: flex;
            align-items: flex-end;
            gap: 15px;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        .price-info label, .price-info span { font-size: 1.1em; color: #555; }
        .price-main { font-size: 1.8em; font-weight: bold; color: #333; }
        .delivery-fee { font-size: 1.2em; color: #777; }

        .total-price-box { margin-top: 15px; }
        .total-price-box h4 { font-size: 1.2em; font-weight: bold; color: #333; margin-bottom: 5px; }
        .total-price-box p { font-size: 2.2em; font-weight: bold; color: #ff4500; }

        .seller-info { margin-top: 30px; display: flex; align-items: center; gap: 15px; }
        .seller-info label { font-size: 1.1em; color: #555; }
        .seller-profile-icon { width: 45px; height: 45px; background-color: #ddd; border-radius: 50%; overflow: hidden; }
        .seller-profile-icon img { width: 100%; height: 100%; object-fit: cover; }
        .seller-name { font-size: 1.3em; font-weight: bold; }

        /* 주문자 정보 스타일 */
        .buyer-info-section {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .buyer-info-section h3 {
            font-size: 1.5em;
            font-weight: bold;
            margin-bottom: 15px;
        }
        .form-group { margin-bottom: 15px; }
        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
            color: #444;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .address-group { display: flex; gap: 10px; }
        .address-group input:first-child { flex-grow: 1; }
        .address-group button { flex-basis: 120px; }

        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 40px;
            justify-content: flex-end;
        }
        .btn-cancel {
            padding: 12px 25px;
            background-color: white;
            color: #555;
            border: 1px solid #ccc;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1em;
            text-decoration: none;
            text-align: center;
        }
        .btn-buy {
            padding: 12px 25px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1em;
        }
    </style>
</head>

<body>
<div class="purchase-container">

    <h2 class="purchase-title">구매하기</h2>

    <% if (!isItemFound || prdNo == null) { %>
    <p style="text-align: center; color: red;">유효한 상품 정보를 찾을 수 없거나 DB 오류가 발생했습니다.</p>
    <% } else if (sellerId.equals(buyerId)) { %>
    <p style="text-align: center; color: orange; font-size: 1.2em;">자신이 등록한 상품은 구매할 수 없습니다.</p>
    <div class="action-buttons" style="justify-content: center;">
        <a href="javascript:history.back()" class="btn-cancel">돌아가기</a>
    </div>
    <% } else { %>

    <form action="purchaseAction.jsp" method="post">
        <input type="hidden" name="prdNo" value="<%= prdNo %>">
        <input type="hidden" name="sellerId" value="<%= sellerId %>">

        <div class="content-wrapper">

            <div class="item-visual">
                <div class="image-box">
                    <% if (goodsImgPath != null && !goodsImgPath.isEmpty()) { %>
                    <img src="<%= goodsImgPath %>" alt="<%= prdName %> 이미지">
                    <% } else { %>
                    상품 사진
                    <% } %>
                </div>

                <div class="buyer-info-section">
                    <h3>주문자 및 배송지 정보</h3>

                    <div class="form-group">
                        <label for="buyerName">수령인</label>
                        <input type="text" id="buyerName" name="buyerName" value="<%= buyerName %>" required>
                    </div>

                    <div class="form-group">
                        <label for="buyerPhone">연락처</label>
                        <input type="text" id="buyerPhone" name="buyerPhone" value="<%= buyerPhone %>" placeholder="하이픈 포함 입력" required>
                    </div>

                    <div class="form-group">
                        <label>주소</label>
                        <div class="address-group">
                            <input type="text" name="address" value="<%= buyerAddress %>" placeholder="기본 주소" required>
                            <button type="button" class="btn-cancel">주소 검색</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <input type="text" name="detailAddress" value="<%= buyerDetailAddress %>" placeholder="상세 주소" required>
                    </div>

                    <div class="form-group">
                        <label for="requestMemo">배송 요청 사항 (선택)</label>
                        <input type="text" id="requestMemo" name="requestMemo" placeholder="예: 문 앞에 놓아주세요.">
                    </div>

                </div>
            </div>

            <div class="item-details">
                <div class="detail-header">
                    <h3><%= prdName %></h3>
                </div>

                <div class="price-info">
                    <label>가격</label>
                    <span class="price-main"><%= nf.format(prdPrice) %>원</span>
                    <span>+</span>
                    <label>배송비</label>
                    <span class="delivery-fee"><%= nf.format(prdDeliver) %>원</span>
                </div>

                <div class="total-price-box">
                    <h4>= 총합</h4>
                    <p><%= nf.format(totalPrice) %>원</p>
                </div>

                <div class="seller-info">
                    <label>판매자</label>
                    <div class="seller-profile-icon">
                        <img src="<%= sellerProfileImg %>" alt="판매자 프로필">
                    </div>
                    <span class="seller-name"><%= sellerNick %></span>
                </div>

                <div class="action-buttons">
                    <a href="javascript:history.back()" class="btn-cancel">취소</a>
                    <button type="submit" class="btn-buy">구매하기</button>
                </div>
            </div>
        </div>
    </form>
    <% } %>

</div>
</body>
</html>