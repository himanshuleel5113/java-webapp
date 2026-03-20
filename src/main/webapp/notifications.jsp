<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.acebank.lite.models.Notification" %>
<%@ page import="com.acebank.lite.service.NotificationService" %>
<%
    Integer accountNumber = (Integer) session.getAttribute("accountNumber");
    String firstName = (String) session.getAttribute("firstName");

    if(accountNumber == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    List<Notification> notifications = NotificationService.getNotifications(accountNumber);
    int unreadCount = NotificationService.getUnreadCount(accountNumber);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AceBank - Notifications</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-100">
    <!-- Header -->
    <header class="bg-gradient-to-r from-blue-900 to-blue-800 text-white shadow-lg">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div class="flex justify-between items-center">
                <h1 class="text-2xl font-bold">
                    <i class="fas fa-university mr-2"></i>
                    <span class="text-blue-300">Ace</span><span class="text-yellow-400">Bank</span>
                </h1>
                <div class="flex items-center space-x-4">
                    <a href="home" class="hover:text-yellow-400 transition">
                        <i class="fas fa-home mr-1"></i>Dashboard
                    </a>
                    <a href="Logout" class="bg-red-600 px-4 py-2 rounded-lg hover:bg-red-700 transition">
                        <i class="fas fa-sign-out-alt mr-2"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-4 py-8">
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
            <div class="p-6 border-b border-gray-200 flex justify-between items-center">
                <div>
                    <h2 class="text-2xl font-bold text-gray-800">Notifications</h2>
                    <p class="text-gray-600">You have <%= unreadCount %> unread notifications</p>
                </div>
                <div class="flex space-x-2">
                    <button onclick="markAllAsRead()" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition text-sm">
                        Mark all as read
                    </button>
                    <button onclick="clearAll()" class="border border-gray-300 text-gray-600 px-4 py-2 rounded-lg hover:bg-gray-50 transition text-sm">
                        Clear all
                    </button>
                </div>
            </div>

            <div class="divide-y divide-gray-200">
                <% if(notifications != null && !notifications.isEmpty()) {
                    for(Notification n : notifications) { %>
                        <div class="p-6 <%= !n.isRead() ? "bg-blue-50" : "" %> hover:bg-gray-50 transition notification-item"
                             onclick="markAsRead(<%= n.getId() %>); window.location.href='<%= n.getActionLink() %>'">
                            <div class="flex items-start space-x-4">
                                <div class="h-10 w-10 rounded-full bg-<%= n.getType().toLowerCase() %>-100 flex items-center justify-center">
                                    <i class="fas <%= n.getIcon() %> text-<%= n.getType().toLowerCase() %>-600"></i>
                                </div>
                                <div class="flex-1">
                                    <p class="text-gray-800"><%= n.getMessage() %></p>
                                    <p class="text-sm text-gray-500 mt-1"><%= n.getFormattedTime() %></p>
                                </div>
                                <% if(!n.isRead()) { %>
                                    <span class="h-2 w-2 bg-blue-600 rounded-full"></span>
                                <% } %>
                            </div>
                        </div>
                <% } } else { %>
                    <div class="p-12 text-center text-gray-500">
                        <i class="fas fa-bell-slash text-5xl mb-4"></i>
                        <p class="text-lg">No notifications</p>
                        <p class="text-sm">You're all caught up!</p>
                    </div>
                <% } %>
            </div>
        </div>
    </main>

    <script>
        function markAsRead(id) {
            fetch('notifications?action=markRead&id=' + id);
        }

        function markAllAsRead() {
            fetch('notifications?action=markAllRead')
                .then(() => window.location.reload());
        }

        function clearAll() {
            if(confirm('Clear all notifications?')) {
                fetch('notifications?action=clearAll')
                    .then(() => window.location.reload());
            }
        }
    </script>
</body>
</html>