<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*, com.acebank.lite.util.ConnectionManager" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Test</title>
</head>
<body>
    <h2>Database Connection Test</h2>
    <%
        try {
            Connection conn = ConnectionManager.getConnection();
            out.println("<p style='color:green'>✅ Database connected successfully!</p>");

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SHOW TABLES");
            out.println("<h3>Tables in database:</h3><ul>");
            while(rs.next()) {
                out.println("<li>" + rs.getString(1) + "</li>");
            }
            out.println("</ul>");

            rs.close();
            stmt.close();
            conn.close();
        } catch(Exception e) {
            out.println("<p style='color:red'>❌ Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    %>
    <br>
    <a href="SignUp.jsp">Go to Sign Up</a> |
    <a href="Login.jsp">Go to Login</a>
</body>
</html>