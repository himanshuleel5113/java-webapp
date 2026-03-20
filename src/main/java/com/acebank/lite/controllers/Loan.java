package com.acebank.lite.controllers;

import com.acebank.lite.dao.BankUserDao;
import com.acebank.lite.dao.BankUserDaoImpl;
import com.acebank.lite.service.BankService;
import com.acebank.lite.service.BankServiceImpl;
import com.acebank.lite.service.NotificationService;
import com.acebank.lite.util.QueryLoader;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.extern.java.Log;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Log
@WebServlet("/Loan")
public class Loan extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final BankService bankService = new BankServiceImpl();
    private final BankUserDao userDao = new BankUserDaoImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountNumber") == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int accountNumber = (int) session.getAttribute("accountNumber");
        String firstName = (String) session.getAttribute("firstName");
        String email = (String) session.getAttribute("email");

        String loanType = request.getParameter("loanType");
        String amountStr = request.getParameter("amount");
        String tenureStr = request.getParameter("tenure");
        String purpose = request.getParameter("purpose");

        // Validate inputs
        if (loanType == null || loanType.isEmpty()) {
            response.sendRedirect("Loan.jsp?error=Please+select+a+loan+type");
            return;
        }

        BigDecimal amount;
        int tenure;

        try {
            amount = new BigDecimal(amountStr);
            tenure = Integer.parseInt(tenureStr.split(" ")[0]); // Extract number from "5 Years"
        } catch (Exception e) {
            response.sendRedirect("Loan.jsp?error=Invalid+amount+or+tenure");
            return;
        }

        try {
            // Insert loan application into database
            boolean success = applyForLoan(accountNumber, loanType, amount, tenure, purpose);

            if (success) {
                // Send confirmation email
                bankService.applyForLoan(firstName, email, loanType);

                // Add notification
                String message = "Your " + loanType.toLowerCase() + " loan application has been submitted successfully.";
                NotificationService.addNotification(accountNumber, message, "LOAN");

                log.info("Loan application submitted for account: " + accountNumber + ", Type: " + loanType);
                response.sendRedirect(request.getContextPath() + "/home?msg=Loan+application+submitted+successfully");
            } else {
                response.sendRedirect("Loan.jsp?error=Application+failed.+Please+try+again");
            }
        } catch (Exception e) {
            log.severe("Loan application error: " + e.getMessage());
            response.sendRedirect("Loan.jsp?error=System+error.+Please+try+again");
        }
    }

    private boolean applyForLoan(int accountNo, String loanType, BigDecimal amount, int tenure, String purpose) {
        String sql = QueryLoader.get("loan.apply");

        try (Connection conn = java.sql.DriverManager.getConnection(
                com.acebank.lite.util.ConfigLoader.getProperty(com.acebank.lite.util.ConfigKeys.DB_URL),
                com.acebank.lite.util.ConfigLoader.getProperty(com.acebank.lite.util.ConfigKeys.DB_USER),
                com.acebank.lite.util.ConfigLoader.getProperty(com.acebank.lite.util.ConfigKeys.DB_PWD));
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);
            pstmt.setString(2, loanType);
            pstmt.setBigDecimal(3, amount);
            pstmt.setInt(4, tenure);
            pstmt.setString(5, purpose);

            int rows = pstmt.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            log.severe("Error applying for loan: " + e.getMessage());
            return false;
        }
    }
}