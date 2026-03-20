package com.acebank.lite.controllers;

import com.acebank.lite.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.extern.java.Log;

import java.io.IOException;

@Log
@WebServlet("/test-notification")
public class TestNotification extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountNumber") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        int accountNo = (int) session.getAttribute("accountNumber");
        
        // Add test notifications
        NotificationService.addNotification(accountNo, "Welcome to AceBank! Your account is now active.", "INFO");
        NotificationService.addNotification(accountNo, "Your account balance has been updated.", "DEPOSIT");
        NotificationService.addNotification(accountNo, "Security alert: New login detected", "SECURITY");
        
        response.setContentType("text/html");
        response.getWriter().println("<html><body style='font-family: Arial; padding: 20px;'>");
        response.getWriter().println("<h2 style='color: green;'>✓ Test notifications added!</h2>");
        response.getWriter().println("<p>3 notifications have been added to your account.</p>");
        response.getWriter().println("<a href='home' style='display: inline-block; padding: 10px 20px; background: #2563eb; color: white; text-decoration: none; border-radius: 5px;'>Go to Dashboard</a>");
        response.getWriter().println("</body></html>");
    }
}