<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.sql.*" %>

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=euc-kr">
<title>로그인</title>
</head>

<body bgcolor="white" text="black" link="blue" vlink="purple" alink="red">

<%
 	 String DB_URL="jdbc:mysql://localhost:3306/final"; 
     String DB_ID="multi"; 
     String DB_PASSWORD="abcd";
 	 
	 Class.forName("org.gjt.mm.mysql.Driver");  
 	 Connection con = DriverManager.getConnection(DB_URL, DB_ID, DB_PASSWORD); 

    String id = request.getParameter("id");            
    String pass = request.getParameter("pw");  

    
    String jsql = "select  *  from user where id = ? "; 
    PreparedStatement pstmt = con.prepareStatement(jsql);
    pstmt.setString(1, id);

    ResultSet rs = pstmt.executeQuery(); 

    if( rs.next() )   //  (1) 입력한 ID를 가지는 레코드가 테이블에 존재하는 경우
    {
        if (pass.equals(rs.getString("pw")))  
    	//  (1.1) 입력한 ID를 가지는 레코드가 존재하면서, 
	    //	        입력한 비밀번호가 member테이블상의 비밀번호와도 일치하는 경우
        {
             session.setAttribute("sid", id);
 	      // 로그인 성공시, 접속한 사용자의 ID를 "sid" 속성의 속성값으로 설정함.
          // 추후 로그인 된 상태에서 접속 ID와 관련된 정보를 필요로 할때,
	      // (String)session.getAttribute("sid")를 이용하여 접속 ID 정보를 가져올 수 있다.
     	  // 단순히, 로그인 여부 판별은 이 속성값이 null인지 아닌지로 로그인 여부를 확인함. 
	      //  (로그인이 안된 경우, 이 값은 null값을 가짐)

             response.sendRedirect("index.jsp");

		 } else {   // (1.2) 입력한 ID를 가지는 레코드가 테이블에 존재하지만, 비밀번호가 불일치한 경우
%>
      <br><br><br>
	  <center>
      <font color=black size=2>
            비밀번호가 잘못 되었습니다.  다시 확인해 주세요!<p>
			로그인 페이지로 돌아가시려면 
			<a href="login.jsp" ><font color=red><여기></font></a>를 클릭, <p>
			메인 페이지로 가시려면 
			<a href="index.html" ><font color=red><여기></font></a>를 클릭
		</font>              
		</center>
<%       
        }   //  두번째 if-else문의 끝      
    } else {    //  (2)  입력한 ID를 가지는 레코드가 테이블에 존재하지 않는 경우
 %>
       <br><br><br>
	  <center>
	  <font color=black size=2>
			아이디가 존재하지 않습니다. 다시 확인해 주세요!<p>
			로그인 페이지로 돌아가시려면 
			<a href="login.jsp" ><font color=red><여기></font></a>를 클릭, <p>
			메인 페이지로 가시려면 
			<a href="index.html" ><font color=red><여기></font></a>를 클릭!
	   </font>
	   </center>
<%
   }  // 첫번째 if-else문의 끝
%>

</body>
</html>

