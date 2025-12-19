<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>

<%
    // 1. 파일 업로드 설정
    String savePath = request.getServletContext().getRealPath("uploads"); // 실제 저장 경로
    int maxSize = 10 * 1024 * 1024; // 최대 10MB
    String encoding = "UTF-8";

    // uploads 폴더가 없으면 생성
    File dir = new File(savePath);
    if (!dir.exists()) dir.mkdirs();

    MultipartRequest multi = null;

    try {
        // 2. 파일 업로드 실행
        multi = new MultipartRequest(request, savePath, maxSize, encoding, new DefaultFileRenamePolicy());
    } catch (Exception e) {
        out.println("<script>alert('파일 업로드 실패: " + e.getMessage() + "'); history.back();</script>");
        return;
    }

    // 3. 파라미터 가져오기 (MultipartRequest를 통해 가져옴)
    String prdNo = multi.getParameter("prdNo");
    String prdName = multi.getParameter("prdName");
    String prdCategory = multi.getParameter("prdCategory");
    int prdPrice = Integer.parseInt(multi.getParameter("prdPrice"));
    int prdDeliver = Integer.parseInt(multi.getParameter("prdDeliver"));
    String prdDescription = multi.getParameter("prdDescription");
    String currentImgPath = multi.getParameter("currentImgPath"); // 기존 이미지 경로

    // 4. 이미지 처리 로직
    String fileName = multi.getFilesystemName("goodsImg"); // 새로 업로드된 파일 이름
    String goodsImg = "";

    if (fileName != null) {
        // 새 이미지가 업로드된 경우: "uploads/파일명" 형식으로 저장
        goodsImg = "uploads/" + fileName;
    } else {
        // 새 이미지가 없는 경우: 기존 경로 유지
        goodsImg = currentImgPath;
    }

    // 5. DB 업데이트 실행
    Connection conn = null;
    PreparedStatement pstmt = null;

    String dbURL = "jdbc:mysql://localhost:3306/internetprogramming?serverTimezone=Asia/Seoul&useUnicode=true&characterEncoding=UTF-8";
    String dbUser = "multi";
    String dbPass = "abcd";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "UPDATE goods SET prdName=?, prdPrice=?, prdDeliver=?, ctgType=?, prdDescription=?, goodsImg=? WHERE prdNo=?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, prdName);
        pstmt.setInt(2, prdPrice);
        pstmt.setInt(3, prdDeliver);
        pstmt.setString(4, prdCategory);
        pstmt.setString(5, prdDescription);
        pstmt.setString(6, goodsImg);
        pstmt.setString(7, prdNo);

        int result = pstmt.executeUpdate();

        if (result > 0) {
%>
<script>
    alert("상품 수정이 완료되었습니다.");
    location.href = "itemDetail.jsp?prdNo=<%= prdNo %>";
</script>
<%
} else {
%>
<script>
    alert("수정에 실패했습니다. 다시 시도해주세요.");
    history.back();
</script>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('DB 오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
        if (conn != null) try { conn.close(); } catch(SQLException e) {}
    }
%>