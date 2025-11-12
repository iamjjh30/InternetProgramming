<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ page import="java.nio.file.Paths" %>

<%-- 
  [필수] 
  Servlet 3.0+ 표준에 따라, 이 JSP가 multipart/form-data를 
  처리할 수 있도록 @MultipartConfig 어노테이션을 설정합니다.
  JSP에서는 page 지시어에 포함시킬 수 없으므로,
  별도의 <%! ... %> 선언부나 web.xml 설정이 필요할 수 있으나,
  대부분의 최신 톰캣은 request.getPart() 호출 시 자동으로 이를 인지합니다.
  
  만약 이 코드가 작동하지 않으면, 이 JSP를 서블릿으로 만들고 
  클래스 위에 @MultipartConfig 를 붙여야 합니다.
  
  (Tomcat 8.5+ 에서는 JSP에서도 @MultipartConfig를 page 지시어처럼
   설정하는 것을 지원하려는 논의가 있었으나, 
   가장 확실한 방법은 request.getPart()를 바로 호출하는 것입니다.)
--%>

<%
    request.setCharacterEncoding("euc-kr");

    // 1. 서버에 파일을 저장할 경로 지정
    // [주의] 이 "upload" 폴더는 서버에 미리 만들어져 있어야 합니다.
    String saveDirectory = application.getRealPath("/upload");

    // 2. 업로드 폴더가 없으면 생성 (안정성을 위해)
    File uploadDir = new File(saveDirectory);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();
    }

    String productName = "";
    String originalFileName = "";
    String savedFileName = "";
    String fileType = "";

    try {
        // 3. 텍스트 데이터(productName) 가져오기
        // request.getPart()가 호출된 이후에는 getParameter() 사용 가능
        productName = request.getParameter("productName");

        // 4. 파일 데이터(productImage) 가져오기
        Part filePart = request.getPart("productImage"); // <input name="productImage">
        
        // 5. 원본 파일명 가져오기
        // getSubmittedFileName()는 클라이언트가 전송한 파일 이름을 반환합니다.
        originalFileName = filePart.getSubmittedFileName();

        // 6. 파일이 실제로 전송되었는지 확인
        if (originalFileName != null && !originalFileName.trim().isEmpty()) {
            
            // 7. 파일 타입 확인
            fileType = filePart.getContentType();
            
            // 8. 실제 저장할 파일 경로 조합
            // (보안) 클라이언트 경로명 제거(예: C:\temp\img.jpg -> img.jpg)
            savedFileName = Paths.get(originalFileName).getFileName().toString();
            String savePath = saveDirectory + File.separator + savedFileName;

            // [주의] 파일명 중복 처리 로직이 없습니다. 
           

            // 9. 파일 저장
            // Part 객체의 write() 메소드를 사용하여 파일을 지정된 경로에 저장합니다.
            filePart.write(savePath);

            // 결과 출력
            out.println("<h2>파일 업로드 성공 (내장 기능)</h2>");
            out.println("--------------------<br>");
            out.println("저장된 경로: " + saveDirectory + "<br>");
            out.println("상품명: " + productName + "<br>");
            out.println("원본 파일명: " + originalFileName + "<br>");
            out.println("저장된 파일명: " + savedFileName + "<br>");
            out.println("파일 타입: " + fileType + "<br>");

        } else {
            out.println("<h2>파일 업로드 실패</h2>");
            out.println("업로드할 파일을 선택하지 않았습니다.");
        }

    } catch (Exception e) {
        out.println("<h2>파일 업로드 실패</h2>");
        out.println("오류: " + e.getMessage());
        e.printStackTrace();
    }
%>