package com.acebank.lite.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter(urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    // Public pages that don't require authentication
    private static final List<String> PUBLIC_PATHS = Arrays.asList(
            "/Login.jsp",
            "/SignUp.jsp",
            "/index.jsp",
            "/ForgotPassword.jsp",
            "/ResetPassword.jsp",
            "/VerifyOTP.jsp",      // ADD THIS - OTP verification page
            "/ForgotFail.jsp",
            "/LoginFail.jsp",
            "/GenericError.html",
            "/test-connection.jsp",
            "/test-email.jsp",
            "/test-notification",
            "/test-notifications.jsp",
            "/Forgot",             // ADD THIS - Forgot password servlet
            "/VerifyOTP",          // ADD THIS - OTP verification servlet
            "/ResetPassword",      // ADD THIS - Reset password servlet
            "/signup",
            "/Login"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();
        String contextPath = httpRequest.getContextPath();

        System.out.println("AuthFilter - Processing path: " + path);

        // Check if the requested path is public
        if (isPublicPath(path)) {
            System.out.println("AuthFilter - Public path allowed: " + path);
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("accountNumber") != null);

        if (isLoggedIn) {
            System.out.println("AuthFilter - Authenticated user accessing: " + path);
            chain.doFilter(request, response);
        } else {
            System.out.println("AuthFilter - Unauthorized access to: " + path + " - Redirecting to login");
            httpResponse.sendRedirect(contextPath + "/Login.jsp?error=Please+login+first");
        }
    }

    private boolean isPublicPath(String path) {
        for (String publicPath : PUBLIC_PATHS) {
            if (path.endsWith(publicPath) || path.equals(publicPath)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AuthFilter initialized");
    }

    @Override
    public void destroy() {
        System.out.println("AuthFilter destroyed");
    }
}