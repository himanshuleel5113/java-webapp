<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Enumeration" %>
<%
    // Only allow access if you're debugging (remove in production)
    // You can add a simple password check here if needed
%>
<!DOCTYPE html>
<html>
<head>
    <title>Session Debug</title>
    <style>
        body { font-family: monospace; padding: 20px; }
        .success { color: green; }
        .error { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>Session Debug Information</h2>

    <h3>Session Attributes:</h3>
    <table>
        <tr>
            <th>Attribute Name</th>
            <th>Attribute Value</th>
            <th>Status</th>
        </tr>
        <%
            HttpSession session2 = request.getSession(false);
            if (session2 != null) {
                Enumeration<String> attributeNames = session2.getAttributeNames();
                while (attributeNames.hasMoreElements()) {
                    String name = attributeNames.nextElement();
                    Object value = session2.getAttribute(name);
                    String status = value != null ?
                        "<span class='success'>✓ Present</span>" :
                        "<span class='error'>✗ Null</span>";
        %>
        <tr>
            <td><%= name %></td>
            <td><%= value != null ? value : "null" %></td>
            <td><%= status %></td>
        </tr>
        <%
                }
            } else {
        %>
        <tr>
            <td colspan="3" class="error">No active session found!</td>
        </tr>
        <%
            }
        %>
    </table>

    <h3>Request Parameters:</h3>
    <table>
        <tr>
            <th>Parameter Name</th>
            <th>Parameter Value</th>
        </tr>
        <%
            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String name = paramNames.nextElement();
                String[] values = request.getParameterValues(name);
        %>
        <tr>
            <td><%= name %></td>
            <td><%= String.join(", ", values) %></td>
        </tr>
        <%
            }
        %>
    </table>

    <br>
    <a href="home">Go to Home</a> |
    <a href="Login.jsp">Go to Login</a> |
    <a href="Logout">Logout</a>
</body>
</html>