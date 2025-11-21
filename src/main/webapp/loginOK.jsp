<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 폼 데이터 받기
    String memId = request.getParameter("memId");
    String memPasswd = request.getParameter("memPasswd");

    // DB 연결 관련 변수
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 로그인 성공 여부 플래그
    boolean loginSuccess = false;
    String userName = null; // 로그인 성공 시 사용자 이름을 저장할 변수

    // JDBC 드라이버 정보
    String dbURL = "jdbc:mysql://localhost:3306/internetProgramming?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul";
    String dbUser = "multi";
    String dbPass = "abcd";
    String driver = "com.mysql.cj.jdbc.Driver";

    try {
        // 2. 드라이버 로드
        Class.forName(driver);

        // 3. DB 연결
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 4. SQL 준비 및 실행 (Prepared Statement 사용으로 SQL Injection 방지)
        String sql = "SELECT memName FROM member WHERE memId = ? AND memPasswd = ?";
        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, memId);
        pstmt.setString(2, memPasswd);

        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 5. 로그인 성공
            loginSuccess = true;
            userName = rs.getString("memName");
        }

    } catch (SQLException e) {
        // DB 접속 또는 쿼리 오류 시
        System.out.println("DB 오류 발생: " + e.getMessage());
%>
<script>
    alert("서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
    history.back();
</script>
<%
        return; // 오류 발생 시 페이지 실행 중단
    } catch (ClassNotFoundException e) {
        // 드라이버 로드 오류 시
        System.out.println("JDBC 드라이버 로드 오류: " + e.getMessage());
        return;
    } finally {
        // 6. 리소스 해제 (가장 중요)
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    // 7. 로그인 결과에 따른 페이지 이동
    if (loginSuccess) {
        // 세션에 사용자 정보 저장
        session.setAttribute("userId", memId);
        session.setAttribute("userName", userName);
%>
<script>
    alert("<%= userName %>님, 환영합니다!");
    location.href = "index.jsp"; // 메인 페이지로 이동
</script>
<%
} else {
    // 로그인 실패
%>
<script>
    alert("아이디 또는 비밀번호가 일치하지 않습니다.");
    history.back(); // 로그인 페이지로 돌아가기
</script>
<%
    }
%>