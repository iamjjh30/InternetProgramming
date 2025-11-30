<%@ page contentType="text/html;charset=euc-kr" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("euc-kr");

    // 이전 페이지(상품상세 등)에서 넘겨준 값
    String prdNo = request.getParameter("prdNo");
    String sellerId = request.getParameter("sellerId");
    String prdName = request.getParameter("prdName"); // 화면 표시용
    int prdPrice = Integer.parseInt(request.getParameter("prdPrice"));
%>
<html>
<head>
    <title>주문 / 결제</title>
    <script>
        function calcPrice() {
            var price = parseInt(document.orderForm.hiddenPrice.value);
            var qty = parseInt(document.orderForm.ordQty.value); // 수량 입력이 있다면
            // 현재 테이블 구조엔 수량 컬럼이 없으므로 단순 1개 기준으로 처리하거나
            // ordPay 계산용으로만 사용합니다.
            document.orderForm.ordPay.value = price;
        }
    </script>
</head>
<body>
    <h2>주문 / 결제 정보 입력</h2>

    <form name="orderForm" action="orderProc.jsp" method="post">
        <input type="hidden" name="prdNo" value="<%=prdNo%>">
        <input type="hidden" name="sellerId" value="<%=sellerId%>">
        <input type="hidden" name="hiddenPrice" value="<%=prdPrice%>">

        <table>
            <tr>
                <td colspan="2"><b>상품 정보</b></td>
            </tr>
            <tr>
                <td>상품명</td>
                <td><%=prdName%> (상품번호: <%=prdNo%>)</td>
            </tr>
            <tr>
                <td>결제 금액</td>
                <td>
                    <input type="text" name="ordPay" value="<%=prdPrice%>" readonly> 원
                </td>
            </tr>

            <tr>
                <td colspan="2"><b>배송지 정보 (수령인)</b></td>
            </tr>
            <tr>
                <td>수령인 명</td>
                <td><input type="text" name="ordReceiver"></td>
            </tr>
            <tr>
                <td>연락처</td>
                <td><input type="text" name="ordRcvPhone"></td>
            </tr>
            <tr>
                <td>배송지 주소</td>
                <td><input type="text" name="ordRcvAddress" size="50"></td>
            </tr>

            <tr>
                <td colspan="2"><b>결제 정보</b></td>
            </tr>
            <tr>
                <td>결제 은행</td>
                <td>
                    <select name="ordBank">
                        <option value="KB국민">KB국민</option>
                        <option value="신한">신한</option>
                        <option value="우리">우리</option>
                        <option value="하나">하나</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>카드 번호</td>
                <td><input type="text" name="ordCardNo" maxlength="16" placeholder="- 제외하고 입력"></td>
            </tr>
            <tr>
                <td>카드 비밀번호</td>
                <td><input type="password" name="ordCardPass" maxlength="4"> (앞 2자리 또는 4자리)</td>
            </tr>

            <tr>
                <td colspan="2">
                    <br>
                    <input type="submit" value="결제 및 주문완료">
                    <input type="button" value="취소" onclick="history.back()">
                </td>
            </tr>
        </table>
    </form>
</body>
</html>