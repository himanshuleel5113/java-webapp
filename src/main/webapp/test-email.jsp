<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.acebank.lite.util.MailUtil" %>
<%@ page import="com.acebank.lite.util.ConfigLoader" %>
<%@ page import="com.acebank.lite.util.ConfigKeys" %>
<!DOCTYPE html>
<html>
<head>
    <title>Email Test</title>
</head>
<body>
    <h2>Email Configuration Test</h2>

    <%
        String fromAddr = ConfigLoader.getProperty(ConfigKeys.MAIL_ADDR);
        String host = ConfigLoader.getProperty(ConfigKeys.MAIL_SMTP_HOST);
        String port = ConfigLoader.getProperty(ConfigKeys.MAIL_SMTP_PORT);
    %>

    <p>From Address: <%= fromAddr != null ? fromAddr : "NOT SET" %></p>
    <p>SMTP Host: <%= host != null ? host : "NOT SET" %></p>
    <p>SMTP Port: <%= port != null ? port : "NOT SET" %></p>

    <form method="post">
        <label>Test Email:</label>
        <input type="email" name="testEmail" required>
        <button type="submit">Send Test Email</button>
    </form>

    <%
        if(request.getMethod().equals("POST")) {
            String testEmail = request.getParameter("testEmail");
            boolean sent = MailUtil.sendMail(testEmail, "Test Email from AceBank",
                "This is a test email to verify your email configuration is working correctly.");
            if(sent) {
                out.println("<p style='color:green'>✓ Test email sent successfully!</p>");
            } else {
                out.println("<p style='color:red'>✗ Failed to send test email. Check logs.</p>");
            }
        }
    %>
</body>
</html>