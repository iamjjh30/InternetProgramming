<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    // JSON 응답을 위한 설정
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    // 1. 세션에서 사용자 ID (memId) 및 상품 번호 가져오기
    // 세션 키는 "userId"이지만, DB 컬럼은 "memId"에 맞춰 사용합니다.
    String memId = (String) session.getAttribute("userId");
    String prdNo = request.getParameter("prdNo");

    // 2. 로그인 및 필수 파라미터 확인
    if (memId == null || memId.trim().isEmpty() || prdNo == null || prdNo.trim().isEmpty()) {
        if (memId == null) {
            out.print("{\"success\": false, \"message\": \"login_required\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"invalid_parameter\"}");
        }
        return;
    }

    // 3. DB 접속 정보
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement pstmtSeller = null;
    ResultSet rsSeller = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    boolean isWished = false; // 현재 찜 상태
    String actionType = "";   // 수행된 작업 (insert/delete)

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sellerId = null;
        String sellerSql = "SELECT sellerId FROM goods WHERE prdNo = ?";

        pstmtSeller = conn.prepareStatement(sellerSql);
        pstmtSeller.setString(1, prdNo);
        rsSeller = pstmtSeller.executeQuery();

        if (rsSeller.next()) {
            sellerId = rsSeller.getString("sellerId");
        }

        if (sellerId != null && sellerId.equals(memId)) {
            out.print("{\"success\": false, \"message\": \"self_wish_not_allowed\"}");
            return; // 자가 찜 방지 후 로직 종료
        }
        // 찜 테이블 구조: wishNo, memId, prdNo
        String checkSql = "SELECT wishNo FROM wishlist WHERE memId = ? AND prdNo = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, memId);
        pstmt.setString(2, prdNo);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            isWished = true;
        }

        // 이전 pstmt와 rs 닫기
        if (rs != null) { rs.close(); rs = null; }
        if (pstmt != null) { pstmt.close(); pstmt = null; }


        // B. 찜 상태에 따른 작업 수행 (DELETE 또는 INSERT)
        if (isWished) {
            // 찜 기록이 있으면 삭제 (찜 취소)
            String deleteSql = "DELETE FROM wishlist WHERE memId = ? AND prdNo = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setString(1, memId);
            pstmt.setString(2, prdNo);
            pstmt.executeUpdate();
            actionType = "delete";
        } else {
            // 찜 기록이 없으면 추가 (찜하기)
            // wishNo는 char(40)이므로 UUID 등을 사용하거나, DB에서 자동 생성되는 값이 아니라면 적절한 값으로 대체해야 합니다.
            // **편의상 현재는 prdNo와 memId를 조합하여 임시로 생성합니다. 실제 환경에서는 UUID.randomUUID().toString() 사용 권장.**
            String wishNo = java.util.UUID.randomUUID().toString();
            String insertSql = "INSERT INTO wishlist (wishNo, memId, prdNo) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, wishNo);
            pstmt.setString(2, memId);
            pstmt.setString(3, prdNo);
            pstmt.executeUpdate();
            actionType = "insert";
        }

        // 4. 성공 응답
        out.print("{\"success\": true, \"action\": \"" + actionType + "\"}");

    } catch (SQLException e) {
        System.err.println("SQL Exception in toggleWishAction.jsp: " + e.getMessage());
        out.print("{\"success\": false, \"message\": \"DB_ERROR\", \"detail\": \"" + e.getMessage() + "\"}");
        System.out.println("찜하기/취소 DB 오류: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        out.print("{\"success\": false, \"message\": \"DRIVER_ERROR\"}");
        System.out.println("드라이버 로드 오류: " + e.getMessage());
    } finally {
        if (rsSeller != null) try { rsSeller.close(); } catch(SQLException e) {}
        if (pstmtSeller != null) try { pstmtSeller.close(); } catch(SQLException e) {}

        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>