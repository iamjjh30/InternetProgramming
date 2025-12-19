<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="java.util.UUID" %>
<%
    // ----------------------------------------------------
    // 1. 로그인 확인 및 파일 업로드 환경 설정
    // ----------------------------------------------------
    String sellerId = (String) session.getAttribute("userId"); // 세션에서 판매자 ID 가져옴

    if (sellerId == null || sellerId.trim().isEmpty()) {
%>
<script>
    alert("로그인 후 이용해 주세요.");
    location.href = "login.jsp";
</script>
<%
        return;
    }

    String savePath = application.getRealPath("uploads"); // 파일을 저장할 서버 경로
    int maxSize = 10 * 1024 * 1024; // 최대 파일 크기 10MB
    String encoding = "UTF-8";

    // 파일 업로드 객체 생성
    MultipartRequest multi = null;
    try {
        multi = new MultipartRequest(request, savePath, maxSize, encoding, new DefaultFileRenamePolicy());
    } catch (IOException e) {
%>
<script>
    alert("파일 업로드에 실패했습니다. (크기 초과 또는 I/O 오류)");
    history.back();
</script>
<%
        return;
    }

    // ----------------------------------------------------
    // 2. 폼 데이터 추출 및 값 준비
    // ----------------------------------------------------
    String prdName = multi.getParameter("itemName"); // 상품 제목
    String prdPriceStr = multi.getParameter("itemPrice");
    String prdDeliverStr = multi.getParameter("shippingFee");
    String prdDescription = multi.getParameter("itemInfo"); // 상품 설명

    // 테이블 필수 컬럼 값 생성/설정
    String ctgType = multi.getParameter("ctgType");
    String prdNo = UUID.randomUUID().toString().substring(0, 10); // ⚠️ 임시 상품 번호 생성 (CHAR(10)에 맞춤)
    String goodsImg = multi.getFilesystemName("goodsImg"); // 서버에 저장된 실제 파일명

    int prdPrice = 0;
    int prdDeliver = 0;

    try {
        // 숫자 값 변환
        prdPrice = Integer.parseInt(prdPriceStr.replaceAll("[^0-9]", ""));
        prdDeliver = Integer.parseInt(prdDeliverStr);
    } catch (NumberFormatException e) {
%>
<script>
    alert("가격 정보가 올바르지 않습니다.");
    history.back();
</script>
<%
        return;
    }

    // ----------------------------------------------------
    // 3. 데이터베이스 삽입
    // ----------------------------------------------------
    Connection conn = null;
    PreparedStatement pstmt = null;

    // ⚠️ DB 접속 정보 수정 필요
    String dbURL = "jdbc:mysql://localhost:3306/internetProgramming?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul";
    String dbUser = "multi";
    String dbPass = "abcd";

    int result = 0;

    try {
        // DB 드라이버 로드 및 연결
        Class.forName("com.mysql.cj.jdbc.Driver"); // ⚠️ 사용하는 DB 드라이버로 수정
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // goods 테이블에 맞는 컬럼 순서 및 이름으로 SQL 작성
        String sql = "INSERT INTO goods (ctgType, prdNo, sellerId, prdName, prdPrice, prdDeliver, prdDescription, goodsImg) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, ctgType);
        pstmt.setString(2, prdNo);
        pstmt.setString(3, sellerId);
        pstmt.setString(4, prdName);
        pstmt.setInt(5, prdPrice);
        pstmt.setInt(6, prdDeliver);
        pstmt.setString(7, prdDescription);
        pstmt.setString(8, "uploads/" + goodsImg); // 이미지 경로

        result = pstmt.executeUpdate();

        if (result > 0) {
%>
<script>
    alert("상품 등록이 완료되었습니다.");
    location.href = "index.jsp";
</script>
<%
} else {
%>
<script>
    alert("상품 등록에 실패했습니다. (쿼리 실패)");
    history.back();
</script>
<%
    }

} catch (SQLException e) {
    System.out.println("SQL 오류 발생: " + e.getMessage());
%>
<script>
    alert("데이터베이스 처리 중 오류가 발생했습니다.");
    // 상세 오류 메시지를 개발 환경에서만 노출
    // alert("데이터베이스 처리 중 오류가 발생했습니다: <%= e.getMessage() %>");
    history.back();
</script>
<%
    } catch (ClassNotFoundException e) {
        System.out.println("JDBC 드라이버 로드 오류: " + e.getMessage());
    } finally {
        // 4. 리소스 해제
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>