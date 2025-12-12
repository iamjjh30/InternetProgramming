<%@page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. 파라미터 받기 (상품 번호)
    String prdNo = request.getParameter("prdNo");

    // 상품 정보 저장을 위한 변수 초기화
    String prdName = "";
    int prdPrice = 0;
    int prdDeliver = 0;
    String prdCategory = "";
    String prdDescription = "";
    String goodsImgPath = ""; // 기존 이미지 경로 저장

    // 2. DB 접속 및 조회 설정 (insertItem.jsp와 동일한 DB 정보 사용)
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    boolean isItemFound = false;

    // 3. 상품 상세 조회 SQL (goods 테이블 컬럼명 가정)
    String goodsSql = "SELECT prdName, prdPrice, prdDeliver, ctgType, prdDescription, goodsImg FROM goods WHERE prdNo = ?";

    // 4. 상품 조회 및 데이터 저장
    if (prdNo != null && !prdNo.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            pstmt = conn.prepareStatement(goodsSql);
            pstmt.setString(1, prdNo);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                isItemFound = true;
                prdName = rs.getString("prdName");
                prdPrice = rs.getInt("prdPrice");
                prdDeliver = rs.getInt("prdDeliver");
                prdCategory = rs.getString("ctgType");
                prdDescription = rs.getString("prdDescription");
                goodsImgPath = rs.getString("goodsImg");
            }

        } catch (SQLException e) {
            System.out.println("상품 수정 데이터 조회 DB 오류: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            System.out.println("드라이버 로드 오류: " + e.getMessage());
        } finally {
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
    <title>상품 수정</title>
    <link rel="stylesheet" href="insertItem.css" />
    <style>
        /* 기존 이미지 미리보기 섹션이 이미지 경로가 있을 때 즉시 보이도록 설정 */
        .image-box img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
    </style>
</head>
<body>
<div id="header-placeholder"></div>

<h2 class="title">상품 수정</h2>

<div class="sell-container">
    <% if (!isItemFound) { %>
    <p style="color: red; text-align: center;">오류: 수정할 상품 정보를 찾을 수 없습니다.</p>
    <% } else { %>

    <form action="updateItemAction.jsp" method="post" enctype="multipart/form-data" name="updateForm">

        <input type="hidden" name="prdNo" value="<%= prdNo %>">
        <input type="hidden" name="currentImgPath" value="<%= goodsImgPath %>">

        <div class="image-section">
            <label for="itemImageInput" class="image-box">
                <img id="previewImage" src="<%= goodsImgPath %>" alt="상품 사진" style="display: <%= (goodsImgPath != null && !goodsImgPath.isEmpty()) ? "block" : "none" %>;" />
                <span class="placeholder" style="display: <%= (goodsImgPath != null && !goodsImgPath.isEmpty()) ? "none" : "block" %>;">상품 사진</span>
            </label>
            <input type="file" id="itemImageInput" name="goodsImg" accept="image/*" style="display:none;">
            <p style="font-size: 12px; color: #777; margin-top: 5px;">* 새 파일을 선택하면 기존 이미지는 교체됩니다.</p>
        </div>

        <div class="form-section">

            <label class="form-label">제목</label>
            <input type="text" class="input-field" name="prdName" value="<%= prdName %>" placeholder="제목을 입력하세요." required>

            <label class="form-label">카테고리</label>
            <select class="input-field" name="prdCategory" required>
                <option value="" disabled <%= prdCategory.isEmpty() ? "selected" : "" %>>카테고리 선택</option>
                <option value="패션의류" <%= "패션의류".equals(prdCategory) ? "selected" : "" %>>패션의류</option>
                <option value="뷰티" <%= "뷰티".equals(prdCategory) ? "selected" : "" %>>뷰티</option>
                <option value="모바일/태블릿" <%= "모바일/태블릿".equals(prdCategory) ? "selected" : "" %>>모바일/태블릿</option>
                <option value="가전제품" <%= "가전제품".equals(prdCategory) ? "selected" : "" %>>가전제품</option>
            </select>

            <label class="form-label">가격</label>
            <div class="price-row">
                <input type="text" class="input-field price" name="prdPrice" value="<%= prdPrice %>" placeholder="가격을 입력하세요." required pattern="\d+">
                <span class="won">원</span>

                <label class="form-label ship-label">배송비</label>
                <select class="ship-select" name="prdDeliver" required>
                    <option value="0" <%= prdDeliver == 0 ? "selected" : "" %>>없음 (0원)</option>
                    <option value="1000" <%= prdDeliver == 1000 ? "selected" : "" %>>1,000원</option>
                    <option value="2000" <%= prdDeliver == 2000 ? "selected" : "" %>>2,000원</option>
                    <option value="3000" <%= prdDeliver == 3000 ? "selected" : "" %>>3,000원</option>
                </select>
            </div>

            <label class="form-label">상품정보</label>
            <textarea class="textarea" name="prdDescription" placeholder="상품정보를 입력하세요." required><%= prdDescription %></textarea>

        </div>
</div>

<div class="btn-row">
    <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
    <button type="submit" class="submit-btn">수정 완료</button>
</div>
</form>
<% } %>
</div>

<script>
    // 상품 이미지 미리보기 (파일이 변경되면 실행)
    document.getElementById("itemImageInput").addEventListener("change", function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (event) {
            const img = document.getElementById("previewImage");
            img.src = event.target.result;
            img.style.display = "block";

            document.querySelector(".placeholder").style.display = "none";
        };
        reader.readAsDataURL(file);
    });
</script>
<script src="include.js"></script>

</body>
</html>