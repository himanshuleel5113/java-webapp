<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Filter Test</title>
</head>
<body>
    <h2>Test Public Page Access</h2>
    <p>This page should be accessible without login.</p>

    <h3>Test OTP Flow:</h3>
    <ol>
        <li><a href="ForgotPassword.jsp">Go to Forgot Password</a></li>
        <li>Enter your email</li>
        <li>You should be redirected to <strong>VerifyOTP.jsp</strong></li>
    </ol>

    <h3>Current Session:</h3>
    <%
        HttpSession sess = request.getSession(false);
        if (sess != null) {
            out.println("<p>Session ID: " + sess.getId() + "</p>");
            out.println("<p>resetEmail: " + sess.getAttribute("resetEmail") + "</p>");
        } else {
            out.println("<p>No active session</p>");
        }
    %>
</body>
</html>