<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.acebank.lite.service.NotificationService" %>
<%
    Integer accountNumber = (Integer) session.getAttribute("accountNumber");
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String email = (String) session.getAttribute("email");

    int unreadCount = 0;
    if(accountNumber != null) {
        unreadCount = NotificationService.getUnreadCount(accountNumber);
    }

    String currentPage = request.getRequestURI();
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AceBank NetBanking</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #f3f4f6;
            min-height: 100vh;
        }

        /* Dark Mode Styles */
        .dark-mode {
            background: #111827;
            color: #f3f4f6;
        }

        .dark-mode .bg-white {
            background: #1f2937 !important;
        }

        .dark-mode .bg-gray-50 {
            background: #374151 !important;
        }

        .dark-mode .text-gray-800 {
            color: #f3f4f6 !important;
        }

        .dark-mode .text-gray-600 {
            color: #9ca3af !important;
        }

        .dark-mode .border-gray-200 {
            border-color: #374151 !important;
        }

        /* Input styles for dark mode */
        .dark-mode input,
        .dark-mode select,
        .dark-mode textarea,
        .dark-mode .border-2 {
            background: #374151 !important;
            border-color: #4b5563 !important;
            color: #f3f4f6 !important;
        }

        .dark-mode input::placeholder,
        .dark-mode textarea::placeholder {
            color: #9ca3af !important;
        }

        .dark-mode input:focus,
        .dark-mode select:focus,
        .dark-mode textarea:focus {
            border-color: #3b82f6 !important;
            outline: none;
        }

        /* Quick amount buttons in dark mode */
        .dark-mode .quick-amount-btn {
            background: #374151 !important;
            border-color: #4b5563 !important;
            color: #f3f4f6 !important;
        }

        .dark-mode .quick-amount-btn:hover {
            background: #4b5563 !important;
            border-color: #3b82f6 !important;
        }

        .header {
            background: linear-gradient(135deg, #0f2b4b, #0a1e33);
            color: white;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .header-content {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 1rem;
            height: 64px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.25rem;
            font-weight: bold;
            color: white;
            text-decoration: none;
        }

        .logo i {
            color: #eab308;
            font-size: 1.5rem;
        }

        .nav-menu {
            display: flex;
            gap: 0.25rem;
        }

        .nav-item {
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: white;
            text-decoration: none;
            transition: background 0.3s;
        }

        .nav-item:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .nav-item.active {
            background: #1e3a5f;
        }

        .right-section {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .icon-btn {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: none;
            cursor: pointer;
            transition: background 0.3s;
            position: relative;
        }

        .icon-btn:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: #ef4444;
            color: white;
            font-size: 10px;
            font-weight: bold;
            min-width: 18px;
            height: 18px;
            border-radius: 9999px;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: pulse 2s infinite;
        }

        .profile-btn {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            border: none;
            color: white;
            cursor: pointer;
            transition: background 0.3s;
        }

        .profile-btn:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .avatar {
            width: 32px;
            height: 32px;
            border-radius: 9999px;
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #0f2b4b;
            font-weight: bold;
            font-size: 14px;
        }

        .dropdown {
            position: absolute;
            right: 0;
            margin-top: 0.5rem;
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
            z-index: 100;
            min-width: 320px;
            max-height: 500px;
            overflow-y: auto;
        }

        .dark-mode .dropdown {
            background: #1f2937;
            border-color: #374151;
        }

        .dropdown-header {
            padding: 1rem;
            border-bottom: 1px solid #e5e7eb;
            position: sticky;
            top: 0;
            background: white;
        }

        .dark-mode .dropdown-header {
            background: #1f2937;
            border-color: #374151;
        }

        .dropdown-item {
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #374151;
            text-decoration: none;
            transition: background 0.2s;
            font-size: 0.875rem;
            cursor: pointer;
        }

        .dark-mode .dropdown-item {
            color: #e5e7eb;
        }

        .dropdown-item:hover {
            background: #f3f4f6;
        }

        .dark-mode .dropdown-item:hover {
            background: #374151;
        }

        .submenu {
            padding-left: 2.5rem;
            font-size: 0.875rem;
            background: #f9fafb;
        }

        .dark-mode .submenu {
            background: #2d3748;
        }

        .submenu-item {
            padding: 0.5rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #4b5563;
            text-decoration: none;
            transition: background 0.2s;
        }

        .dark-mode .submenu-item {
            color: #9ca3af;
        }

        .submenu-item:hover {
            background: #e5e7eb;
        }

        .dark-mode .submenu-item:hover {
            background: #4b5563;
            color: #f3f4f6;
        }

        .notification-item {
            border-bottom: 1px solid #e5e7eb;
        }

        .dark-mode .notification-item {
            border-color: #374151;
        }

        .main-content {
            max-width: 1280px;
            margin: 0 auto;
            padding: 1.5rem 1rem;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }
    </style>
</head>
<body x-data="{
    darkMode: localStorage.getItem('darkMode') === 'true',
    notifications: [],
    showNotifications: false,
    unreadCount: <%= unreadCount %>,
    showProfileMenu: false,
    showPersonalDetails: false
}" x-init="
    if (darkMode) $el.classList.add('dark-mode');
    $watch('darkMode', val => {
        if (val) {
            $el.classList.add('dark-mode');
            localStorage.setItem('darkMode', 'true');
        } else {
            $el.classList.remove('dark-mode');
            localStorage.setItem('darkMode', 'false');
        }
    });
    // Load notifications on init
    loadNotifications();

    // Refresh notifications every 30 seconds
    setInterval(() => {
        loadNotifications();
    }, 30000);
">

    <!-- Header -->
    <header class="header">
        <div class="header-content">
            <!-- Logo -->
            <a href="<%= contextPath %>/index.jsp" class="logo">
                <i class="fas fa-university"></i>
                <span>Ace</span><span style="color: #eab308;">Bank</span>
            </a>

            <% if(accountNumber != null) { %>
            <!-- Navigation -->
            <nav class="nav-menu">
                <a href="<%= contextPath %>/home" class="nav-item <%= currentPage.contains("home") ? "active" : "" %>">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="<%= contextPath %>/Statement.jsp" class="nav-item <%= currentPage.contains("Statement") ? "active" : "" %>">
                    <i class="fas fa-file-alt"></i>
                    <span>Statements</span>
                </a>
                <a href="<%= contextPath %>/Transfer.jsp" class="nav-item <%= currentPage.contains("Transfer") ? "active" : "" %>">
                    <i class="fas fa-exchange-alt"></i>
                    <span>Transfer</span>
                </a>
                <a href="<%= contextPath %>/Loan.jsp" class="nav-item <%= currentPage.contains("Loan") ? "active" : "" %>">
                    <i class="fas fa-hand-holding-usd"></i>
                    <span>Loans</span>
                </a>
            </nav>
            <% } %>

            <!-- Right Section -->
            <div class="right-section">
                <!-- Dark Mode Toggle -->
                <button @click="darkMode = !darkMode" class="icon-btn">
                    <i :class="darkMode ? 'fas fa-sun' : 'fas fa-moon'"></i>
                </button>

                <% if(accountNumber != null) { %>
                    <!-- Notifications -->
                    <div class="relative">
                        <button @click="showNotifications = !showNotifications; if(showNotifications) loadNotifications()" class="icon-btn">
                            <i class="fas fa-bell"></i>
                            <span x-show="unreadCount > 0" x-text="unreadCount" class="notification-badge" style="display: none;"></span>
                        </button>

                        <!-- Notifications Dropdown -->
                        <div x-show="showNotifications" @click.away="showNotifications = false" class="dropdown" style="display: none;">
                            <div class="dropdown-header">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <h3 class="font-semibold">Notifications</h3>
                                    <button @click="markAllAsRead()" class="text-xs text-blue-600 hover:underline">Mark all read</button>
                                </div>
                            </div>
                            <div>
                                <template x-for="notification in notifications" :key="notification.id">
                                    <div class="dropdown-item notification-item" @click="markAsRead(notification.id); window.location.href=notification.actionLink">
                                        <i :class="'fas ' + notification.icon" style="font-size: 1.25rem;"></i>
                                        <div style="flex: 1;">
                                            <p x-text="notification.message" style="font-size: 0.875rem;"></p>
                                            <p class="text-xs text-gray-500" x-text="notification.formattedTime" style="margin-top: 0.25rem;"></p>
                                        </div>
                                        <span x-show="!notification.read" class="h-2 w-2 bg-blue-600 rounded-full" style="display: inline-block;"></span>
                                    </div>
                                </template>
                                <div x-show="notifications.length === 0" class="p-4 text-center text-gray-500">
                                    <i class="fas fa-bell-slash text-4xl mb-2"></i>
                                    <p>No notifications</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Profile Menu -->
                    <div class="relative">
                        <button @click="showProfileMenu = !showProfileMenu" class="profile-btn">
                            <div class="avatar">
                                <%= firstName != null && !firstName.isEmpty() ? firstName.charAt(0) : "U" %>
                            </div>
                            <span class="hidden md:inline"><%= firstName != null ? firstName : "" %></span>
                            <i class="fas fa-chevron-down text-xs"></i>
                        </button>

                        <!-- Profile Dropdown -->
                        <div x-show="showProfileMenu" @click.away="showProfileMenu = false" class="dropdown" style="display: none;">
                            <div class="dropdown-header">
                                <p class="font-semibold"><%= firstName != null ? firstName : "" %> <%= lastName != null ? lastName : "" %></p>
                                <p class="text-xs text-gray-500"><%= email != null ? email : "" %></p>
                            </div>

                            <!-- Personal Details Toggle -->
                            <div class="dropdown-item" @click="showPersonalDetails = !showPersonalDetails">
                                <i class="fas fa-user-circle"></i>
                                <span>Personal Details</span>
                                <i class="fas fa-chevron-down ml-auto" :class="{ 'rotate-180': showPersonalDetails }" style="transition: transform 0.3s;"></i>
                            </div>

                            <!-- Personal Details Submenu -->
                            <div x-show="showPersonalDetails" class="submenu" style="display: none;">
                                <div class="submenu-item">
                                    <i class="fas fa-id-card" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">Full Name</p>
                                        <p class="text-sm font-medium"><%= firstName != null ? firstName : "" %> <%= lastName != null ? lastName : "" %></p>
                                    </div>
                                </div>
                                <div class="submenu-item">
                                    <i class="fas fa-envelope" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">Email</p>
                                        <p class="text-sm font-medium"><%= email != null ? email : "" %></p>
                                    </div>
                                </div>
                                <div class="submenu-item">
                                    <i class="fas fa-phone" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">Phone</p>
                                        <p class="text-sm font-medium">+91 98765 43210</p>
                                    </div>
                                </div>
                                <div class="submenu-item">
                                    <i class="fas fa-id-card" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">Aadhar Number</p>
                                        <p class="text-sm font-medium">**** **** 1234</p>
                                    </div>
                                </div>
                                <div class="submenu-item">
                                    <i class="fas fa-credit-card" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">PAN Card</p>
                                        <p class="text-sm font-medium">*****1234A</p>
                                    </div>
                                </div>
                                <div class="submenu-item">
                                    <i class="fas fa-calendar" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">Date of Birth</p>
                                        <p class="text-sm font-medium">15/08/1995</p>
                                    </div>
                                </div>
                                <div class="submenu-item">
                                    <i class="fas fa-map-marker-alt" style="width: 20px;"></i>
                                    <div>
                                        <p class="text-xs text-gray-500">Address</p>
                                        <p class="text-sm font-medium">Mumbai, Maharashtra</p>
                                    </div>
                                </div>
                            </div>

                            <a href="<%= contextPath %>/ChangePassword.jsp" class="dropdown-item">
                                <i class="fas fa-key"></i> Change Password
                            </a>
                            <a href="<%= contextPath %>/Statement.jsp" class="dropdown-item">
                                <i class="fas fa-file-alt"></i> Statements
                            </a>
                            <hr class="my-2 border-gray-200">
                            <a href="<%= contextPath %>/Logout" class="dropdown-item" style="color: #dc2626;">
                                <i class="fas fa-sign-out-alt"></i> Logout
                            </a>
                        </div>
                    </div>
                <% } else { %>
                    <a href="<%= contextPath %>/Login.jsp" class="nav-item">Login</a>
                    <a href="<%= contextPath %>/SignUp.jsp" class="nav-item" style="background: #eab308; color: #0f2b4b;">Sign Up</a>
                <% } %>
            </div>
        </div>
    </header>

    <!-- Main Content Container -->
    <div class="main-content">