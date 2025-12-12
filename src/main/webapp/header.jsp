<%@page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>커뮤니티 마켓</title>
    <link rel="stylesheet" href="style.css" />
    <style>
        .profile-info {
            display: flex;
            align-items: center;
            gap: 10px; /* 아이콘과 이름 사이 간격 */
            position: relative;
        }
        .profile-icon {
            /* 임시 아이콘 스타일 */
            width: 30px;
            height: 30px;
            background-color: #ddd;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: bold;
            color: #333;
            text-decoration: none;
            cursor: pointer;
            overflow: hidden; /* 이미지 원형으로 자르기 */
        }
        /* ⭐️ 추가된 프로필 이미지 스타일 ⭐️ */
        .profile-icon {
            /* ... (기타 스타일) */
            width: 30px;
            height: 30px;
            overflow: hidden; /* 이미지 원형으로 자르기 */
        }
        .profile-icon img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }
        /* --------------------------------- */
        .user-dropdown {
            display: none; /* 초기에는 숨김 */
            position: absolute;
            top: 40px; /* 헤더 높이와 아이콘 크기에 맞춰 위치 조정 */
            right: 0;
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
            z-index: 1000;
            min-width: 140px;
            flex-direction: column;
            padding: 5px 0;
        }
        .user-dropdown a {
            padding: 10px 15px;
            text-decoration: none;
            color: #222;
            font-size: 14px;
            white-space: nowrap; /* 줄 바꿈 방지 */
            margin-left: 0; /* 기존 nav-right a 마진 상쇄 */
        }
        .user-dropdown a:hover {
            background-color: #f1f1f1;
        }
        .user-dropdown.active {
            display: flex; /* 활성화 시 표시 */
        }
    </style>
</head>
<body>

<%
    // 1. 세션에서 사용자 ID 및 이름 가져오기
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    System.out.println("로그인된 사용자 ID: " + userId);
    String userProfileImg = null; // 프로필 이미지 경로 저장 변수

    // 2. DB 접속 및 조회 설정
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // ⭐️ DB 연결 정보 (이전 코드에서 사용된 정보 가정) ⭐️
    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    // 3. 회원 프로필 조회 SQL (가정: member 테이블에 memberId와 profileImg 컬럼이 있음)
    String memberSql = "SELECT profileImg FROM member WHERE memId = ?";

    // 4. 로그인된 상태일 경우에만 프로필 이미지 조회
    if (userId != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            pstmt = conn.prepareStatement(memberSql);
            // ⭐️ 세션의 userId를 memberId로 사용하여 조회 ⭐️
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String imgPathFromDb = rs.getString("profileImg");
                if (imgPathFromDb != null && !imgPathFromDb.isEmpty()) {
                    userProfileImg = imgPathFromDb; // 프로필 이미지 경로 저장
                }
            }

        } catch (SQLException e) {
            System.out.println("헤더 프로필 DB 오류: " + e.getMessage());
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


<header class="navbar">
    <div class="navbar-inner">
        <div class="nav-left">
            <button class="category-btn" id="categoryBtn">☰ 카테고리</button>
            <div class="dropdown" id="dropdownMenu">
                <a href="itemSearch.jsp?category=패션의류">패션의류</a>
                <a href="itemSearch.jsp?category=뷰티">뷰티</a>
                <a href="itemSearch.jsp?category=모바일/태블릿">모바일/태블릿</a>
                <a href="itemSearch.jsp?category=가전제품">가전제품</a>
            </div>
        </div>
        <form action="itemSearch.jsp" method="get">
            <input type="text" name="keyword" class="search-bar" placeholder="검색어를 입력하세요">
        </form>
        <div class="nav-right">
            <a href="insertItem.jsp">판매하기</a>
            <%
                if (userId != null) {
                    // 🌟 로그인 상태: 프로필 정보 및 로그아웃 버튼 표시
            %>
            <div class="profile-info" id="profileInfo">
                <a href="#" class="profile-icon" id="profileToggle">
                    <%
                        if (userProfileImg != null) {
                            // ⭐️ 프로필 이미지가 있을 경우 <img> 태그 출력 ⭐️
                    %>
                    <img src="<%= userProfileImg %>" alt="프로필 이미지">
                    <%
                    } else {
                        // 이미지가 없을 경우: 기존처럼 이름 첫 글자 표시
                    %>
                    <img src="./images/free-icon-profile-3106773.png">
                    <%
                        }
                    %>
                </a>
                <a href="#" class="user-name" id="userNameToggle">
                    <%= userName %>님
                </a>


                <div class="user-dropdown" id="userDropdown">
                    <a href="myPage.jsp">마이페이지</a>
                    <a href="logoutAction.jsp">로그아웃</a>
                </div>
            </div>
            <%
            } else {
                // 🌟 로그아웃 상태: 로그인 버튼 표시
            %>
            <a href="login.jsp">로그인</a>
            <%
                }
            %>
        </div>
    </div>
</header>
<script src="include.js"></script>
</body>
</html>