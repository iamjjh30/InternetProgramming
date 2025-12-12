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
            <button class="btn-primary btn-wish" id="wishBtn">찜하기</button>
            <button class="btn-primary btn-buy">구매하기</button>
        </div>

        <input type="hidden" id="currentPrdNo" value="<%=request.getParameter("prdNo") %>">
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
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        const $wishBtn = $('#wishBtn');
        const currentPrdNo = $('#currentPrdNo').val(); // HTML에서 상품 번호를 가져옴

        const contextPath = "<%= request.getContextPath() %>";
        // 찜 상태를 확인하는 함수
        function checkWishStatus() {
            if (!currentPrdNo) return;

            // DB에서 현재 상품이 찜 되어 있는지 확인하는 AJAX 호출 (별도 checkWishStatusAction.jsp 필요)
            // 편의상, 여기서는 바로 토글 기능을 구현합니다.
            // 실제 구현에서는 이 부분이 페이지 로드 시에 동작해야 합니다.

            // --- 간소화된 초기 상태 설정 (필요시 상세 구현) ---
            // $wishBtn.text('찜하기').removeClass('wished');
            // if (초기_찜_상태) { $wishBtn.text('찜 취소').addClass('wished'); }
            // ----------------------------------------------------
        }

        $(document).ready(function() {
            // checkWishStatus(); // 페이지 로드 시 찜 상태 확인 (선택 사항)

            $wishBtn.on('click', function() {
                if (!currentPrdNo) {
                    alert('상품 정보가 유효하지 않습니다.');
                    return;
                }

                $.ajax({
                    url: contextPath + '/toggleWishAction.jsp',
                    type: 'POST',
                    data: { prdNo: currentPrdNo },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            if (response.action === 'insert') {
                                $wishBtn.text('찜 취소').addClass('wished');
                                alert('상품을 찜 목록에 추가했습니다.');
                            } else {
                                $wishBtn.text('찜하기').removeClass('wished');
                                alert('찜 목록에서 상품을 제거했습니다.');
                            }
                        } else {
                            if (response.message === 'self_wish_not_allowed') {
                                alert('자신이 등록한 상품은 찜할 수 없습니다.'); // ⭐️ 사용자에게 메시지 표시 ⭐️
                            } else if (response.message === 'login_required') {
                                alert('로그인이 필요합니다.');
                                location.href = contextPath + '/login.jsp';
                            } else {
                                alert('찜 처리 중 오류가 발생했습니다: ' + response.message);
                                console.error(response);
                            }
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('서버 통신 오류가 발생했습니다.');
                        console.error(xhr, status, error);
                    }
                });
            });
        });
    </script>
</body>
</html>