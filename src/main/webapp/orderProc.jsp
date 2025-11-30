<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    request.setCharacterEncoding("euc-kr");

    // 1. 로그인한 사용자 ID 가져오기 (세션 가정)
    // 세션이 없으면 테스트용 ID 'testUser' 사용
    String memId = (String)session.getAttribute("id");
    if(memId == null) memId = "testUser";

    // 2. 폼 데이터 수신
    String prdNo = request.getParameter("prdNo");
    String sellerId = request.getParameter("sellerId");
    String ordReceiver = request.getParameter("ordReceiver");
    String ordRcvAddress = request.getParameter("ordRcvAddress");
    String ordRcvPhone = request.getParameter("ordRcvPhone");
    int ordPay = Integer.parseInt(request.getParameter("ordPay"));
    String ordBank = request.getParameter("ordBank");
    String ordCardNo = request.getParameter("ordCardNo");
    String ordCardPass = request.getParameter("ordCardPass");

    // 3. 주문번호(ordNo) 생성 로직 (CHAR 10자리 맞춤)
    // 예: 현재시간(초) 10자리 사용 (Unix Timestamp)
    long time = System.currentTimeMillis() / 1000;
    String ordNo = String.valueOf(time);
    // 또는 "20251129A1" 처럼 날짜+문자 조합도 가능하지만, 간단히 10자리 숫자로 함.

    Connection con = null;
    PreparedStatement pstmt = null;

    try {
        String DB_URL="jdbc:mysql://localhost:3306/internetprogramming";
        String DB_ID="multi";
        String DB_PASSWORD="abcd";

        Class.forName("org.gjt.mm.mysql.Driver");
        con = DriverManager.getConnection(DB_URL, DB_ID, DB_PASSWORD);

        // 4. SQL 작성
        // 테이블 순서: ordNo, memId, prdNo, sellerId, ordDate(자동), ordReceiver, ...
        // 주의: ordDate는 default가 있으므로 insert에서 제외해도 됨
        String sql = "INSERT INTO orderInfo "
                + "(ordNo, memId, prdNo, sellerId, ordReceiver, ordRcvAddress, ordRcvPhone, ordPay, ordBank, ordCardNo, ordCardPass, sellStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '판매중')";

        pstmt = con.prepareStatement(sql);

        pstmt.setString(1, ordNo);
        pstmt.setString(2, memId);
        pstmt.setString(3, prdNo);
        pstmt.setString(4, sellerId);
        pstmt.setString(5, ordReceiver);
        pstmt.setString(6, ordRcvAddress);
        pstmt.setString(7, ordRcvPhone);
        pstmt.setInt(8, ordPay);
        pstmt.setString(9, ordBank);
        pstmt.setString(10, ordCardNo);
        pstmt.setString(11, ordCardPass);

        pstmt.executeUpdate();

%>
<script>
    alert("주문이 완료되었습니다.\n주문번호: <%=ordNo%>");
    location.href = "productList.jsp"; // 메인이나 목록으로 이동
</script>
<%
    } catch(Exception e) {
        out.println("<h3>주문 처리 실패</h3>");
        out.println(e.getMessage());
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(con != null) try { con.close(); } catch(SQLException ex) {}
    }
%>