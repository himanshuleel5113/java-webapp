<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.acebank.lite.models.Transaction" %>
<%
    Integer accountNumber = (Integer) session.getAttribute("accountNumber");
    String firstName = (String) session.getAttribute("firstName");
    List<Transaction> transactions = (List<Transaction>) session.getAttribute("transactionDetailsList");
    BigDecimal balance = (BigDecimal) session.getAttribute("balance");

    if(accountNumber == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    BigDecimal totalCredits = BigDecimal.ZERO;
    BigDecimal totalDebits = BigDecimal.ZERO;
    if(transactions != null) {
        for(Transaction t : transactions) {
            if(t.senderAccount() != null && t.senderAccount().equals(accountNumber)) {
                totalDebits = totalDebits.add(t.amount());
            } else {
                totalCredits = totalCredits.add(t.amount());
            }
        }
    }
%>
<jsp:include page="/includes/header.jsp" />

<div class="max-w-7xl mx-auto">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-6">
        <div>
            <h1 class="text-2xl font-bold">Account Statement</h1>
            <p class="text-gray-600">Account: XXXX<%= String.valueOf(accountNumber).substring(Math.max(0, String.valueOf(accountNumber).length()-4)) %></p>
        </div>
        <button onclick="window.print()" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition">
            <i class="fas fa-print mr-2"></i>Print Statement
        </button>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-xl shadow-lg p-4">
            <p class="text-sm text-gray-500">Opening Balance</p>
            <p class="text-xl font-bold">₹ 0.00</p>
        </div>
        <div class="bg-white rounded-xl shadow-lg p-4">
            <p class="text-sm text-gray-500">Total Credits</p>
            <p class="text-xl font-bold text-green-600">₹ <%= String.format("%,.2f", totalCredits) %></p>
        </div>
        <div class="bg-white rounded-xl shadow-lg p-4">
            <p class="text-sm text-gray-500">Total Debits</p>
            <p class="text-xl font-bold text-red-600">₹ <%= String.format("%,.2f", totalDebits) %></p>
        </div>
        <div class="bg-white rounded-xl shadow-lg p-4">
            <p class="text-sm text-gray-500">Closing Balance</p>
            <p class="text-xl font-bold text-blue-600">₹ <%= balance != null ? String.format("%,.2f", balance) : "0.00" %></p>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-lg p-4 mb-6">
        <div class="flex flex-wrap gap-4">
            <select class="border border-gray-300 rounded-lg px-4 py-2 text-sm">
                <option>Last 7 days</option>
                <option>Last 30 days</option>
                <option>Last 3 months</option>
                <option>Last 6 months</option>
                <option>This year</option>
                <option>All time</option>
            </select>
            <input type="date" class="border border-gray-300 rounded-lg px-4 py-2 text-sm">
            <span class="py-2">to</span>
            <input type="date" class="border border-gray-300 rounded-lg px-4 py-2 text-sm">
            <button class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition text-sm">
                Apply Filter
            </button>
            <button class="border border-gray-300 text-gray-600 px-4 py-2 rounded-lg hover:bg-gray-50 transition text-sm">
                <i class="fas fa-download mr-2"></i>Download PDF
            </button>
        </div>
    </div>

    <!-- Transactions Table -->
    <div class="bg-white rounded-xl shadow-lg overflow-hidden">
        <div class="overflow-x-auto">
            <table class="professional-table w-full">
                <thead>
                    <tr>
                        <th>Date & Time</th>
                        <th>Transaction ID</th>
                        <th>Description</th>
                        <th>Type</th>
                        <th>Debit</th>
                        <th>Credit</th>
                        <th>Balance</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(transactions != null && !transactions.isEmpty()) {
                        BigDecimal runningBalance = balance;
                        for(Transaction t : transactions) {
                            boolean isDebit = (t.senderAccount() != null && t.senderAccount().equals(accountNumber));
                    %>
                        <tr>
                            <td class="text-sm"><%= t.createdAt().format(formatter) %></td>
                            <td class="text-sm font-mono">TXN<%= String.format("%08d", t.id()) %></td>
                            <td class="text-sm">
                                <% if("TRANSFER".equals(t.txType())) { %>
                                    <%= isDebit ? "To: A/C " + t.receiverAccount() : "From: A/C " + t.senderAccount() %>
                                <% } else if("DEPOSIT".equals(t.txType())) { %>
                                    Cash Deposit
                                <% } else { %>
                                    ATM Withdrawal
                                <% } %>
                            </td>
                            <td>
                                <span class="badge-<%= "DEPOSIT".equals(t.txType()) ? "success" : "WITHDRAWAL".equals(t.txType()) ? "pending" : "info" %>">
                                    <%= t.txType() %>
                                </span>
                            </td>
                            <td class="text-sm text-red-600">
                                <%= isDebit ? "₹ " + String.format("%,.2f", t.amount()) : "-" %>
                            </td>
                            <td class="text-sm text-green-600">
                                <%= !isDebit ? "₹ " + String.format("%,.2f", t.amount()) : "-" %>
                            </td>
                            <td class="text-sm font-semibold">₹ <%= String.format("%,.2f", runningBalance) %></td>
                        </tr>
                    <%
                            if(isDebit) {
                                runningBalance = runningBalance.add(t.amount());
                            } else {
                                runningBalance = runningBalance.subtract(t.amount());
                            }
                        }
                    } else { %>
                        <tr>
                            <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                                <i class="fas fa-receipt text-5xl mb-4 opacity-50"></i>
                                <p>No transactions found</p>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />