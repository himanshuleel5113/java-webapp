<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.acebank.lite.models.Transaction" %>
<%
    Integer accountNumber = (Integer) session.getAttribute("accountNumber");
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    String email = (String) session.getAttribute("email");
    BigDecimal balance = (BigDecimal) session.getAttribute("balance");
    List<Transaction> transactions = (List<Transaction>) session.getAttribute("transactionDetailsList");

    if(accountNumber == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");
    String fullAccountNumber = accountNumber.toString();
    String hiddenAccountNumber = "XXXX" + (fullAccountNumber.length() > 4 ?
        fullAccountNumber.substring(fullAccountNumber.length() - 4) : fullAccountNumber);
%>
<jsp:include page="/includes/header.jsp" />

<!-- Welcome Banner -->
<div style="background: linear-gradient(135deg, #0f2b4b, #0a1e33); border-radius: 1rem; padding: 1.5rem; margin-bottom: 1.5rem; color: white;">
    <div>
        <p style="color: #93c5fd; font-size: 0.875rem; margin-bottom: 0.25rem;">Welcome back,</p>
        <h2 style="font-size: 1.875rem; font-weight: bold; margin-bottom: 0.5rem;"><%= firstName != null ? firstName : "" %>! 👋</h2>
        <div style="display: flex; align-items: center; gap: 0.5rem;">
            <p style="color: #93c5fd; font-size: 0.875rem;">Account:</p>
            <p style="font-family: monospace; font-size: 1.1rem; font-weight: 600;" id="accountNumberDisplay"><%= hiddenAccountNumber %></p>
            <button onclick="toggleAccountNumber()" style="background: none; border: none; cursor: pointer; color: #93c5fd; font-size: 1rem;">
                <i class="fas fa-eye" id="accountToggleIcon"></i>
            </button>
        </div>
    </div>
</div>

<!-- Account Overview Cards -->
<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 2rem;">
    <div class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border-left: 4px solid #2563eb;">
        <div style="display: flex; justify-content: space-between;">
            <div>
                <p style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.25rem;">Total Balance</p>
                <div style="display: flex; align-items: center; gap: 0.5rem;">
                    <p style="font-size: 1.875rem; font-weight: bold; color: #2563eb;" id="balanceAmount">₹ <%= balance != null ? String.format("%,.2f", balance) : "0.00" %></p>
                    <button onclick="toggleBalance()" style="background: none; border: none; cursor: pointer; color: #2563eb; font-size: 1.25rem;">
                        <i class="fas fa-eye" id="balanceToggleIcon"></i>
                    </button>
                </div>
                <p style="color: #9ca3af; font-size: 0.75rem; margin-top: 0.5rem;">Available for transactions</p>
            </div>
            <div style="width: 48px; height: 48px; background: #dbeafe; border-radius: 9999px; display: flex; align-items: center; justify-content: center;">
                <i class="fas fa-wallet" style="color: #2563eb; font-size: 1.25rem;"></i>
            </div>
        </div>
    </div>

    <div class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border-left: 4px solid #059669;">
        <div style="display: flex; justify-content: space-between;">
            <div>
                <p style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.25rem;">Today's Earnings</p>
                <p style="font-size: 1.875rem; font-weight: bold; color: #059669;">₹ 0.00</p>
                <p style="color: #9ca3af; font-size: 0.75rem; margin-top: 0.5rem;">Interest accrued</p>
            </div>
            <div style="width: 48px; height: 48px; background: #d1fae5; border-radius: 9999px; display: flex; align-items: center; justify-content: center;">
                <i class="fas fa-chart-line" style="color: #059669; font-size: 1.25rem;"></i>
            </div>
        </div>
    </div>

    <div class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border-left: 4px solid #9333ea;">
        <div style="display: flex; justify-content: space-between;">
            <div>
                <p style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.25rem;">Reward Points</p>
                <p style="font-size: 1.875rem; font-weight: bold; color: #9333ea;">2,450</p>
                <p style="color: #9ca3af; font-size: 0.75rem; margin-top: 0.5rem;">Redeem for offers</p>
            </div>
            <div style="width: 48px; height: 48px; background: #f3e8ff; border-radius: 9999px; display: flex; align-items: center; justify-content: center;">
                <i class="fas fa-gem" style="color: #9333ea; font-size: 1.25rem;"></i>
            </div>
        </div>
    </div>
</div>

<!-- Toast Notification Container -->
<div id="toastContainer" style="position: fixed; bottom: 20px; right: 20px; z-index: 9999;"></div>

<script>
    // Show toast notification for transactions
    function showTransactionToast(type, amount, details) {
        const toast = document.createElement('div');

        let icon, bgColor, message;

        switch(type) {
            case 'deposit':
                icon = 'fa-arrow-down';
                bgColor = '#10b981';
                message = `₹${amount} deposited successfully`;
                break;
            case 'withdraw':
                icon = 'fa-arrow-up';
                bgColor = '#ef4444';
                message = `₹${amount} withdrawn successfully`;
                break;
            case 'transfer':
                icon = 'fa-exchange-alt';
                bgColor = '#3b82f6';
                message = `₹${amount} transferred to account ${details}`;
                break;
            case 'loan':
                icon = 'fa-hand-holding-usd';
                bgColor = '#8b5cf6';
                message = `Loan application submitted`;
                break;
            default:
                icon = 'fa-check-circle';
                bgColor = '#10b981';
                message = 'Transaction successful';
        }

        toast.style.cssText = `
            background: ${bgColor};
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.2);
            margin-top: 10px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 300px;
            animation: slideInRight 0.3s ease, fadeOut 0.3s ease 2.7s forwards;
            transform-origin: right;
        `;

        toast.innerHTML = `
            <div style="background: rgba(255,255,255,0.2); width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                <i class="fas ${icon}" style="font-size: 20px;"></i>
            </div>
            <div style="flex: 1;">
                <div style="font-weight: bold; margin-bottom: 4px;">Success!</div>
                <div style="opacity: 0.9; font-size: 13px;">${message}</div>
            </div>
            <button onclick="this.parentElement.remove()" style="background: none; border: none; color: white; opacity: 0.7; cursor: pointer; font-size: 16px;">
                <i class="fas fa-times"></i>
            </button>
        `;

        document.getElementById('toastContainer').appendChild(toast);

        // Auto remove after 3 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 3000);
    }

    // Check URL parameters for transaction messages
    (function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        const error = urlParams.get('error');

        if (msg) {
            if (msg.includes('Deposit')) {
                const amount = msg.match(/[\d,]+/)?.[0] || '';
                showTransactionToast('deposit', amount);
            } else if (msg.includes('Withdrawal')) {
                const amount = msg.match(/[\d,]+/)?.[0] || '';
                showTransactionToast('withdraw', amount);
            } else if (msg.includes('Transfer')) {
                showTransactionToast('transfer', '', '');
            } else if (msg.includes('Loan')) {
                showTransactionToast('loan');
            }
        }

        if (error) {
            showToast(error.replace(/\+/g, ' '), 'error');
        }
    })();
</script>

<!-- Add animation keyframes -->
<style>
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes fadeOut {
        to {
            opacity: 0;
            transform: translateX(100%);
        }
    }
</style>
<!-- Quick Actions -->
<h3 style="font-size: 1.125rem; font-weight: 600; margin-bottom: 1rem; display: flex; align-items: center;">
    <i class="fas fa-bolt" style="color: #eab308; margin-right: 0.5rem;"></i>
    Quick Actions
</h3>
<div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-bottom: 2rem;">
    <a href="<%= request.getContextPath() %>/Deposit.jsp" class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; text-align: center; text-decoration: none; color: inherit; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); transition: all 0.3s;" onmouseover="this.style.transform='translateY(-5px)'; this.style.boxShadow='0 20px 25px -5px rgba(0,0,0,0.1)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 6px -1px rgba(0,0,0,0.1)';">
        <div style="width: 64px; height: 64px; background: #d1fae5; border-radius: 9999px; display: flex; align-items: center; justify-content: center; margin: 0 auto 0.75rem;">
            <i class="fas fa-arrow-down" style="color: #059669; font-size: 1.5rem;"></i>
        </div>
        <span style="display: block; font-weight: 600;">Deposit</span>
        <span style="font-size: 0.75rem; color: #6b7280;">Add money</span>
    </a>

    <a href="<%= request.getContextPath() %>/Withdraw.jsp" class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; text-align: center; text-decoration: none; color: inherit; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); transition: all 0.3s;" onmouseover="this.style.transform='translateY(-5px)'; this.style.boxShadow='0 20px 25px -5px rgba(0,0,0,0.1)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 6px -1px rgba(0,0,0,0.1)';">
        <div style="width: 64px; height: 64px; background: #fee2e2; border-radius: 9999px; display: flex; align-items: center; justify-content: center; margin: 0 auto 0.75rem;">
            <i class="fas fa-arrow-up" style="color: #dc2626; font-size: 1.5rem;"></i>
        </div>
        <span style="display: block; font-weight: 600;">Withdraw</span>
        <span style="font-size: 0.75rem; color: #6b7280;">Cash out</span>
    </a>

    <a href="<%= request.getContextPath() %>/Transfer.jsp" class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; text-align: center; text-decoration: none; color: inherit; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); transition: all 0.3s;" onmouseover="this.style.transform='translateY(-5px)'; this.style.boxShadow='0 20px 25px -5px rgba(0,0,0,0.1)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 6px -1px rgba(0,0,0,0.1)';">
        <div style="width: 64px; height: 64px; background: #dbeafe; border-radius: 9999px; display: flex; align-items: center; justify-content: center; margin: 0 auto 0.75rem;">
            <i class="fas fa-exchange-alt" style="color: #2563eb; font-size: 1.5rem;"></i>
        </div>
        <span style="display: block; font-weight: 600;">Transfer</span>
        <span style="font-size: 0.75rem; color: #6b7280;">Send money</span>
    </a>

    <a href="<%= request.getContextPath() %>/Loan.jsp" class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; text-align: center; text-decoration: none; color: inherit; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); transition: all 0.3s;" onmouseover="this.style.transform='translateY(-5px)'; this.style.boxShadow='0 20px 25px -5px rgba(0,0,0,0.1)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 6px -1px rgba(0,0,0,0.1)';">
        <div style="width: 64px; height: 64px; background: #fef3c7; border-radius: 9999px; display: flex; align-items: center; justify-content: center; margin: 0 auto 0.75rem;">
            <i class="fas fa-hand-holding-usd" style="color: #d97706; font-size: 1.5rem;"></i>
        </div>
        <span style="display: block; font-weight: 600;">Apply Loan</span>
        <span style="font-size: 0.75rem; color: #6b7280;">Instant approval</span>
    </a>
</div>

<!-- Promotional Banner -->
<div style="background: linear-gradient(135deg, #9333ea, #db2777); border-radius: 0.75rem; padding: 1.5rem; margin-bottom: 2rem; color: white;">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <div>
            <h3 style="font-size: 1.25rem; font-weight: bold; margin-bottom: 0.5rem;">🎉 Special Diwali Offer!</h3>
            <p style="color: #f3e8ff;">Get up to ₹500 cashback on your first transfer of ₹2000+</p>
        </div>
        <button style="background: white; color: #9333ea; padding: 0.5rem 1.5rem; border-radius: 0.5rem; font-weight: 600; border: none; cursor: pointer;" onclick="alert('Offer claimed! Check your email for details.')">
            Claim Now →
        </button>
    </div>
</div>

<!-- Recent Transactions -->
<div class="bg-white" style="border-radius: 0.75rem; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
        <h3 style="font-size: 1.125rem; font-weight: 600;">
            <i class="fas fa-history" style="color: #2563eb; margin-right: 0.5rem;"></i>
            Recent Transactions
        </h3>
        <a href="Statement.jsp" style="color: #2563eb; font-size: 0.875rem; text-decoration: none;">
            View All <i class="fas fa-arrow-right" style="margin-left: 0.25rem;"></i>
        </a>
    </div>

    <% if(transactions != null && !transactions.isEmpty()) { %>
        <div style="overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="background: linear-gradient(135deg, #0f2b4b, #1e3a5f); color: white;">
                        <th style="padding: 0.75rem 1rem; text-align: left;">Date & Time</th>
                        <th style="padding: 0.75rem 1rem; text-align: left;">Description</th>
                        <th style="padding: 0.75rem 1rem; text-align: left;">Type</th>
                        <th style="padding: 0.75rem 1rem; text-align: left;">Amount</th>
                        <th style="padding: 0.75rem 1rem; text-align: left;">Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    int count = 0;
                    for(Transaction t : transactions) {
                        if(count++ >= 5) break;
                        boolean isDebit = (t.senderAccount() != null && t.senderAccount().equals(accountNumber));
                    %>
                        <tr style="border-bottom: 1px solid #e5e7eb;">
                            <td style="padding: 0.75rem 1rem; font-size: 0.875rem;"><%= t.createdAt().format(formatter) %></td>
                            <td style="padding: 0.75rem 1rem; font-size: 0.875rem;">
                                <% if("TRANSFER".equals(t.txType())) { %>
                                    <%= isDebit ? "To: A/C XXXXX" + (t.receiverAccount() != null ?
                                        t.receiverAccount().toString().substring(Math.max(0, t.receiverAccount().toString().length()-4)) : "")
                                                : "From: A/C XXXXX" + (t.senderAccount() != null ?
                                        t.senderAccount().toString().substring(Math.max(0, t.senderAccount().toString().length()-4)) : "") %>
                                <% } else if("DEPOSIT".equals(t.txType())) { %>
                                    Cash Deposit
                                <% } else { %>
                                    ATM Withdrawal
                                <% } %>
                            </td>
                            <td style="padding: 0.75rem 1rem;">
                                <span style="background: <%= "DEPOSIT".equals(t.txType()) ? "#d1fae5" : "WITHDRAWAL".equals(t.txType()) ? "#fed7aa" : "#dbeafe" %>; color: <%= "DEPOSIT".equals(t.txType()) ? "#065f46" : "WITHDRAWAL".equals(t.txType()) ? "#92400e" : "#1e40af" %>; padding: 0.25rem 0.5rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">
                                    <%= t.txType() %>
                                </span>
                            </td>
                            <td style="padding: 0.75rem 1rem; font-weight: 600; <%= isDebit ? "color: #dc2626;" : "color: #059669;" %>">
                                <%= isDebit ? "-" : "+" %> ₹ <%= String.format("%,.2f", t.amount()) %>
                            </td>
                            <td style="padding: 0.75rem 1rem;"><span style="background: #d1fae5; color: #065f46; padding: 0.25rem 0.5rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">Completed</span></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } else { %>
        <div style="text-align: center; padding: 3rem; color: #6b7280;">
            <i class="fas fa-receipt" style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;"></i>
            <p style="font-size: 1.125rem;">No transactions yet</p>
            <p style="font-size: 0.875rem;">Start by making a deposit or transfer</p>
        </div>
    <% } %>
</div>

<!-- Shopping Offers -->
<div style="margin-top: 2rem;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
        <h3 style="font-size: 1.125rem; font-weight: 600;">
            <i class="fas fa-tags" style="color: #ec4899; margin-right: 0.5rem;"></i>
            Exclusive Offers for You
        </h3>
        <a href="#" style="color: #2563eb; font-size: 0.875rem; text-decoration: none;">View All Offers →</a>
    </div>

    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem;">
        <div class="bg-white" style="border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1rem; text-align: center; position: relative;">
            <span style="position: absolute; top: 0.5rem; right: 0.5rem; background: #eab308; color: black; font-size: 0.625rem; padding: 0.125rem 0.5rem; border-radius: 9999px;">FLAT 30%</span>
            <i class="fab fa-amazon" style="font-size: 3rem; color: #f97316; margin-bottom: 0.5rem;"></i>
            <h4 style="font-weight: 600; font-size: 0.875rem;">Amazon.in</h4>
            <p style="font-size: 0.75rem; color: #6b7280;">On electronics</p>
            <p style="font-size: 0.75rem; color: #059669; margin-top: 0.25rem;">Use: BANK30</p>
        </div>

        <div class="bg-white" style="border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1rem; text-align: center; position: relative;">
            <span style="position: absolute; top: 0.5rem; right: 0.5rem; background: #eab308; color: black; font-size: 0.625rem; padding: 0.125rem 0.5rem; border-radius: 9999px;">₹500 OFF</span>
            <i class="fas fa-shopping-cart" style="font-size: 3rem; color: #2563eb; margin-bottom: 0.5rem;"></i>
            <h4 style="font-weight: 600; font-size: 0.875rem;">Flipkart</h4>
            <p style="font-size: 0.75rem; color: #6b7280;">Big Billion Days</p>
            <p style="font-size: 0.75rem; color: #059669; margin-top: 0.25rem;">Min ₹2999</p>
        </div>

        <div class="bg-white" style="border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1rem; text-align: center; position: relative;">
            <span style="position: absolute; top: 0.5rem; right: 0.5rem; background: #eab308; color: black; font-size: 0.625rem; padding: 0.125rem 0.5rem; border-radius: 9999px;">BUY 1 GET 1</span>
            <i class="fas fa-tshirt" style="font-size: 3rem; color: #ec4899; margin-bottom: 0.5rem;"></i>
            <h4 style="font-weight: 600; font-size: 0.875rem;">Myntra</h4>
            <p style="font-size: 0.75rem; color: #6b7280;">Fashion</p>
            <p style="font-size: 0.75rem; color: #059669; margin-top: 0.25rem;">Code: STYLE</p>
        </div>

        <div class="bg-white" style="border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1rem; text-align: center; position: relative;">
            <span style="position: absolute; top: 0.5rem; right: 0.5rem; background: #eab308; color: black; font-size: 0.625rem; padding: 0.125rem 0.5rem; border-radius: 9999px;">20% OFF</span>
            <i class="fas fa-utensils" style="font-size: 3rem; color: #f97316; margin-bottom: 0.5rem;"></i>
            <h4 style="font-weight: 600; font-size: 0.875rem;">Swiggy</h4>
            <p style="font-size: 0.75rem; color: #6b7280;">Food Delivery</p>
            <p style="font-size: 0.75rem; color: #059669; margin-top: 0.25rem;">First Order</p>
        </div>
    </div>
</div>

<!-- Toggle Scripts -->
<script>
    // Account Number Toggle
    let accountVisible = false;
    const fullAccountNumber = '<%= fullAccountNumber %>';
    const hiddenAccountNumber = '<%= hiddenAccountNumber %>';

    function toggleAccountNumber() {
        const accountElement = document.getElementById('accountNumberDisplay');
        const toggleIcon = document.getElementById('accountToggleIcon');

        if (accountVisible) {
            accountElement.innerHTML = hiddenAccountNumber;
            toggleIcon.className = 'fas fa-eye';
        } else {
            accountElement.innerHTML = fullAccountNumber;
            toggleIcon.className = 'fas fa-eye-slash';
        }
        accountVisible = !accountVisible;
    }

    // Balance Toggle
    let balanceVisible = true;
    const originalBalance = '<%= balance != null ? String.format("%,.2f", balance) : "0.00" %>';

    function toggleBalance() {
        const balanceElement = document.getElementById('balanceAmount');
        const toggleIcon = document.getElementById('balanceToggleIcon');

        if (balanceVisible) {
            balanceElement.innerHTML = '₹ ••••••';
            toggleIcon.className = 'fas fa-eye-slash';
        } else {
            balanceElement.innerHTML = '₹ ' + originalBalance;
            toggleIcon.className = 'fas fa-eye';
        }
        balanceVisible = !balanceVisible;
    }
</script>

<jsp:include page="/includes/footer.jsp" />