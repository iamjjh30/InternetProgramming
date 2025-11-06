<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>커뮤니티 마켓</title>
    <link rel="stylesheet" href="style.css" />
</head>
<body>
<!-- 상단 헤더 -->
<header class="navbar">
    <div class="navbar-inner">
        <div class="nav-left">
            <button class="menu-btn">☰</button>
            <button class="category-btn">카테고리</button>
        </div>
        <div class="nav-center">
            <input type="text" class="search-bar" placeholder="검색어를 입력하세요" />
        </div>
        <div class="nav-right">
            <a href="#">판매하기</a>
            <a href="#">로그인</a>
        </div>
    </div>
</header>


<!-- 메인 영역 -->
<main class="main-container">
    <section class="hero">
        <div class="hero-text">
            <h2>
                당신의 취향이 만나는 곳, 모두의 중고생활<br />
                거래를 넘어, 사람과 취향이 연결되는 커뮤니티 마켓
            </h2>
            <button class="start-btn">지금 시작하기 →</button>
        </div>
        <div class="hero-img">
            <img src="https://cdn.pixabay.com/photo/2017/10/27/15/12/people-2892254_1280.png" alt="illustration" />
            <span class="credit">Illustration - pavan6811</span>
        </div>
    </section>

    <!-- 게시판 -->
    <section class="board-section">
        <div class="board">
            <h3>관심사 게시판</h3>
            <table>
                <tr><th>닉네임</th><th>제목</th><th>조회수</th></tr>
                <tr><td>aaa</td><td>aaa</td><td>120</td></tr>
                <tr><td>bbb</td><td>bbb</td><td>54</td></tr>
                <tr><td>ccc</td><td>ccc</td><td>60</td></tr>
                <tr><td>ddd</td><td>ddd</td><td>146</td></tr>
            </table>
        </div>

        <div class="board">
            <h3>자유게시판</h3>
            <table>
                <tr><th>닉네임</th><th>제목</th><th>조회수</th></tr>
                <tr><td>aaa</td><td>aaa</td><td>120</td></tr>
                <tr><td>bbb</td><td>bbb</td><td>54</td></tr>
                <tr><td>ccc</td><td>ccc</td><td>60</td></tr>
                <tr><td>ddd</td><td>ddd</td><td>146</td></tr>
            </table>
        </div>
    </section>
</main>
</body>
</html>
