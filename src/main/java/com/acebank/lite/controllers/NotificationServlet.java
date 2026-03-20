package com.acebank.lite.controllers;

import com.acebank.lite.models.Notification;
import com.acebank.lite.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.extern.java.Log;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@Log
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountNumber") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("[]");
            return;
        }

        int accountNo = (int) session.getAttribute("accountNumber");
        String action = request.getParameter("action");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            if ("count".equals(action)) {
                int count = NotificationService.getUnreadCount(accountNo);
                out.print("{\"count\":" + count + "}");
                log.info("Unread count for account " + accountNo + ": " + count);

            } else if ("markRead".equals(action)) {
                String notificationId = request.getParameter("id");
                if (notificationId != null) {
                    NotificationService.markAsRead(accountNo, Integer.parseInt(notificationId));
                    log.info("Marked notification " + notificationId + " as read for account " + accountNo);
                }
                out.print("{\"success\":true}");

            } else if ("markAllRead".equals(action)) {
                NotificationService.markAllAsRead(accountNo);
                log.info("Marked all notifications as read for account " + accountNo);
                out.print("{\"success\":true}");

            } else {
                List<Notification> notifications = NotificationService.getNotifications(accountNo);
                String json = convertNotificationsToJson(notifications);
                log.info("Returning " + notifications.size() + " notifications for account " + accountNo);
                out.print(json);
            }
        } catch (Exception e) {
            log.severe("Error in NotificationServlet: " + e.getMessage());
            out.print("[]");
        }
    }

    private String convertNotificationsToJson(List<Notification> notifications) {
        if (notifications == null || notifications.isEmpty()) {
            return "[]";
        }

        StringBuilder json = new StringBuilder("[");

        for (int i = 0; i < notifications.size(); i++) {
            Notification n = notifications.get(i);

            json.append("{");
            json.append("\"id\":").append(n.getId()).append(",");
            json.append("\"accountNo\":").append(n.getAccountNo()).append(",");
            json.append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",");
            json.append("\"type\":\"").append(escapeJson(n.getType())).append("\",");
            json.append("\"icon\":\"").append(escapeJson(n.getIcon())).append("\",");
            json.append("\"actionLink\":\"").append(escapeJson(n.getActionLink())).append("\",");
            json.append("\"read\":").append(n.isRead()).append(",");
            json.append("\"formattedTime\":\"").append(escapeJson(n.getFormattedTime())).append("\"");
            json.append("}");

            if (i < notifications.size() - 1) {
                json.append(",");
            }
        }

        json.append("]");
        return json.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t")
                .replace("/", "\\/");
    }
}