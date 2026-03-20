package com.acebank.lite.controllers;


import com.acebank.lite.service.BankService;
import com.acebank.lite.service.BankServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/deposit")
public class Deposit extends HttpServlet {
    private final BankService bankService = new BankServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer accNo = (Integer) session.getAttribute("accountNumber");
        String amountStr = request.getParameter("amount");

        if (accNo == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        try {
            BigDecimal amount = new BigDecimal(amountStr);

            // 1. Call Service to handle the deposit
            boolean success = bankService.processDeposit(accNo, amount);

            if (success) {
                // 2. Update the session balance so the user sees the change immediately
                BigDecimal currentBalance = (BigDecimal) session.getAttribute("balance");
                session.setAttribute("balance", currentBalance.add(amount));

                // 3. Optional: Refresh a transaction list here or in a filter
                response.sendRedirect(request.getContextPath() + "/home");


            } else {
                response.sendRedirect(request.getContextPath() + "/home");

            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home");

        }
    }
}