<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>MySQL 연결 테스트</title></head>
<body>
<h2>MySQL에서 사용자 목록 불러오기</h2>
<%
    String url = "jdbc:mysql://localhost:3306/testdb?serverTimezone=Asia/Seoul";
    String user = "root";
    String password = "1234";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, user, password);
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM users");

        while (rs.next()) {
            out.println("<p>" + rs.getInt("id") + " | " + rs.getString("name") + " | " + rs.getString("email") + "</p>");
        }

        rs.close();
        stmt.close();
        conn.close();

    } catch (Exception e) {
        out.println("<p>에러: " + e.toString() + "</p>");
    }
%>
</body>
</html>
