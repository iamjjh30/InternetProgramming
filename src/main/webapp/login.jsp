<%@ page contentType="text/html;charset=euc-kr" %>
<html><head><title>로그인</title></head>
<body onLoad="login_focus()">

<center>
<br><br><br><br>
<form name="login" method="post" action="loginOK.jsp" target=_parent> 
 <table border=0 cellpadding=5>
<tr>
 <td><font size=2>아이디 : </font></td>
<td><input type="text" name="id" style="width:120;height=20"></td>
<td rowspan=2>
 <tr>
 <td><font size=2>패스워드 : </font></td>
 <td><input type="password" name="pw" style="width:120;height=20">&nbsp
 <input type="submit" value="로그인">
 </tr>
 </table><p> 
 </form>
</center> 
</body> 
</html>