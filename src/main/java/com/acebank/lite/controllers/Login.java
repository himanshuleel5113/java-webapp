package com.acebank.lite.controllers;

import java.io.IOException;
import java.io.Serial;
import java.util.List;
import java.util.Optional;

import com.acebank.lite.dao.BankUserDao;
import com.acebank.lite.dao.BankUserDaoImpl;
import com.acebank.lite.models.LoginResult;
import com.acebank.lite.models.Transaction;
import com.acebank.lite.service.BankService;
import com.acebank.lite.service.BankServiceImpl;
import com.acebank.lite.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import lombok.extern.java.Log;

@Log
@WebServlet(name = "Login", urlPatterns = "/Login")
public class Login extends HttpServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    private final BankService bankService = new BankServiceImpl();
    private final BankUserDao userDao = new BankUserDaoImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accStr = request.getParameter("accountNumber");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        try {
            int accountNo = Integer.parseInt(accStr);

            // 1. Get stored hash
            String storedHash = userDao.getPasswordHash(accountNo);

            if (storedHash != null && PasswordUtil.checkPassword(password, storedHash)) {
                // 2. Get user details
                LoginResult details = userDao.getUserDetails(accountNo);

                HttpSession session = request.getSession(true);

                // 3. Populate Session Attributes
                session.setAttribute("accountNumber", accountNo);
                session.setAttribute("firstName", details.firstName());
                session.setAttribute("lastName", details.lastName());
                session.setAttribute("email", details.email());
                session.setAttribute("balance", details.balance());

                // 4. Fetch Transaction History
                List<Transaction> statement = userDao.getStatement(accountNo);
                session.setAttribute("transactionDetailsList", statement);

                // 5. Handle "Remember Me" Cookie
                if (rememberMe != null) {
                    Cookie cookie = new Cookie("rememberedAccount", String.valueOf(accountNo));
                    cookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                    cookie.setPath("/");
                    response.addCookie(cookie);
                }

                log.info("User " + accountNo + " logged in successfully.");
                response.sendRedirect(request.getContextPath() + "/home");

            } else {
                log.warning("Authentication failed for account: " + accStr);
                response.sendRedirect("LoginFail.jsp");
            }

        } catch (Exception e) {
            log.severe("Login Error: " + e.getMessage());
            response.sendRedirect("LoginFail.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Login.jsp");
    }
}