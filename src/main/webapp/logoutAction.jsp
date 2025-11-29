<%@ page contentType="text/html; charset=UTF-8"%>

<%
    // 1. 세션 무효화
    // 세션(session) 객체는 JSP 페이지에서 기본으로 제공되는 내장 객체입니다.

    if (session != null) {
        // session.invalidate()는 현재 세션에 저장된 모든 속성(userId, userName 등)을 삭제하고,
        // 세션을 완전히 무효화합니다.
        session.invalidate();
    }

    // 2. 로그아웃 확인 메시지 및 리다이렉트
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그아웃</title>
</head>
<body>
<script>
    alert("로그아웃되었습니다.");
    // 메인 페이지로 이동 (프로젝트의 기본 경로에 맞게 'index.jsp'를 수정할 수 있습니다.)
    location.href = "index.jsp";
</script>
</body>
</html>