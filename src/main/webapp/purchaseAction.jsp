<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 세션에서 구매자 ID 가져오기
    String buyerId = (String) session.getAttribute("userId");

    // 2. 폼 데이터 및 히든 필드 값 받기
    String prdNo = request.getParameter("prdNo");
    String sellerId = request.getParameter("sellerId");

    String buyerName = request.getParameter("buyerName"); // 수령인 (ordReceiver)
    String buyerPhone = request.getParameter("buyerPhone"); // 연락처 (ordRcvPhone)
    String address = request.getParameter("address"); // 기본 주소
    String detailAddress = request.getParameter("detailAddress"); // 상세 주소
    String requestMemo = request.getParameter("requestMemo"); // 배송 요청 사항

    // 3. 필수 파라미터 유효성 검사
    if (buyerId == null || prdNo == null || buyerName == null || address == null) {
        out.println("<script>alert('구매 정보가 누락되었습니다. 다시 시도해 주세요.'); history.back();</script>");
        return;
    }

    // 최종 배송지 주소 합치기: ordRcvAddress 컬럼에 저장
    String fullAddress = address.trim() + " " + (detailAddress != null ? detailAddress.trim() : "");

    // 4. DB 접속 및 트랜잭션 처리
    Connection conn = null;
    PreparedStatement pstmtOrder = null;
    PreparedStatement pstmtUpdateGoods = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    boolean purchaseSuccess = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // ⭐️ 트랜잭션 시작 ⭐️
        conn.setAutoCommit(false);

        // A. 주문 기록 INSERT (orderinfo 테이블 사용)
        // ordNo는 char(10)에 맞게 UUID 앞 10자리를 사용합니다.
        String ordNo = UUID.randomUUID().toString().substring(0, 10);

        // ordPay는 INT 타입이므로 0으로 설정. 나머지 결제 정보는 NULL 처리합니다.
        // sellStatus는 '결제완료'로 설정합니다.
        // ordPay, ordBank, ordCardNo, ordCardPass는 폼에 없으므로 INSERT 문에서 명시적으로 NULL/0 처리합니다.
        String insertSql = "INSERT INTO orderinfo (ordNo, memId, prdNo, ordReceiver, ordRcvAddress, ordRcvPhone, ordDate, sellStatus, requestMemo, ordPay) VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?, 0)";

        pstmtOrder = conn.prepareStatement(insertSql);
        pstmtOrder.setString(1, ordNo);
        pstmtOrder.setString(2, buyerId); // memId
        pstmtOrder.setString(3, prdNo); // prdNo
        pstmtOrder.setString(4, buyerName); // ordReceiver
        pstmtOrder.setString(5, fullAddress); // ordRcvAddress
        pstmtOrder.setString(6, buyerPhone); // ordRcvPhone
        pstmtOrder.setString(7, "결제완료"); // sellStatus
        pstmtOrder.setString(8, requestMemo); // requestMemo (DB에 requestMemo 컬럼이 있다고 가정)

        pstmtOrder.executeUpdate();


        // B. 상품 상태를 '판매완료'로 업데이트 (goods 테이블)
        String updateGoodsSql = "UPDATE goods SET status = 'SoldOut' WHERE prdNo = ?";

        pstmtUpdateGoods = conn.prepareStatement(updateGoodsSql);
        pstmtUpdateGoods.setString(1, prdNo);

        int rowsAffected = pstmtUpdateGoods.executeUpdate();

        if (rowsAffected > 0) {
            // 두 쿼리가 모두 성공했다면 최종 커밋
            conn.commit();
            purchaseSuccess = true;
        } else {
            // 상품 업데이트 실패 (이미 판매완료되었을 수 있음)
            conn.rollback();
            out.println("<script>alert('상품 상태 업데이트에 실패했습니다. 이미 판매 완료되었을 수 있습니다.'); history.back();</script>");
            return;
        }

    } catch (SQLException e) {
        // 오류 발생 시 롤백 및 에러 처리
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.out.println("Rollback 오류: " + ex.getMessage());
            }
        }
        System.out.println("구매 처리 DB 오류: " + e.getMessage());
        out.println("<script>alert('구매 처리 중 오류가 발생했습니다: " + e.getMessage().replace("'", "") + "'); history.back();</script>");

    } catch (ClassNotFoundException e) {
        System.out.println("드라이버 로드 오류: " + e.getMessage());
        out.println("<script>alert('서버 설정 오류가 발생했습니다.'); history.back();</script>");

    } finally {
        // 5. 리소스 해제 및 자동 커밋 복구
        if (pstmtUpdateGoods != null) try { pstmtUpdateGoods.close(); } catch(SQLException e) {}
        if (pstmtOrder != null) try { pstmtOrder.close(); } catch(SQLException e) {}
        if (conn != null) {
            try {
                conn.setAutoCommit(true); // 자동 커밋 복구
                conn.close();
            } catch(SQLException e) {}
        }
    }

    // 6. 구매 성공 시 리다이렉션
    if (purchaseSuccess) {
        out.println("<script>alert('구매가 성공적으로 완료되었습니다! 마이페이지에서 주문 내역을 확인하세요.'); location.href='myPage.jsp';</script>");
    }
%>