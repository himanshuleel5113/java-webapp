package com.acebank.lite.dao;

import com.acebank.lite.models.AccountRecoveryDTO;
import com.acebank.lite.models.LoginResult;
import com.acebank.lite.models.Transaction;
import com.acebank.lite.models.User;
import com.acebank.lite.util.ConnectionManager;
import com.acebank.lite.util.QueryLoader;

import java.sql.*;
import java.util.Optional;

import lombok.extern.java.Log;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Log
public class BankUserDaoImpl implements BankUserDao {

    private Connection getConnection() throws SQLException {
        return ConnectionManager.getConnection();
    }

    @Override
    public String getPasswordHash(int accountNo) throws SQLException {
        String sql = QueryLoader.get("user.get_password_by_acc");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("PASSWORD_HASH");
                }
            }
        }
        return null;
    }

    @Override
    public boolean login(int accountNo, String password) throws SQLException {
        String sql = QueryLoader.get("user.login_details");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);
            pstmt.setString(2, password);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public LoginResult getUserDetails(int accountNo) throws SQLException {
        String sql = QueryLoader.get("user.get_details");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new LoginResult(
                            rs.getString("FIRST_NAME"),
                            rs.getString("LAST_NAME"),
                            rs.getString("EMAIL"),
                            rs.getBigDecimal("BALANCE"),
                            accountNo
                    );
                }
            }
        }
        throw new SQLException("User details not found for account: " + accountNo);
    }

    @Override
    public boolean signUp(User user, int accountNo) throws SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String userSql = QueryLoader.get("user.signup");
            try (PreparedStatement ps1 = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS)) {
                ps1.setString(1, user.firstName());
                ps1.setString(2, user.lastName());
                ps1.setString(3, user.aadhaarNo());
                ps1.setString(4, user.email());
                ps1.setString(5, user.passwordHash());

                int affectedRows = ps1.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
                }

                try (ResultSet rs = ps1.getGeneratedKeys()) {
                    if (rs.next()) {
                        int userId = rs.getInt(1);

                        String accountSql = QueryLoader.get("account.create");
                        try (PreparedStatement ps2 = conn.prepareStatement(accountSql)) {
                            ps2.setInt(1, accountNo);
                            ps2.setInt(2, userId);
                            ps2.executeUpdate();
                        }
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            log.info("User registered successfully with account: " + accountNo);
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    log.severe("Rollback failed: " + ex.getMessage());
                }
            }
            log.severe("Signup failed: " + e.getMessage());
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    @Override
    public BigDecimal getDailyWithdrawalTotal(int accountNo) throws SQLException {
        String sql = QueryLoader.get("transaction.get_daily_withdrawal_total");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal(1);
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        }
        return BigDecimal.ZERO;
    }

    @Override
    public boolean withdraw(int accountNo, BigDecimal amount) throws SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            log.info("Processing withdrawal for account: " + accountNo + ", Amount: " + amount);

            BigDecimal currentBalance = getBalance(accountNo);
            log.info("Current balance: " + currentBalance);

            if (currentBalance.compareTo(amount) < 0) {
                log.warning("Insufficient balance");
                return false;
            }

            String withdrawSql = QueryLoader.get("account.withdraw_balance");
            try (PreparedStatement psUpdate = conn.prepareStatement(withdrawSql)) {
                psUpdate.setBigDecimal(1, amount);
                psUpdate.setInt(2, accountNo);
                psUpdate.setBigDecimal(3, amount);

                int rows = psUpdate.executeUpdate();
                log.info("Rows updated in ACCOUNTS: " + rows);

                if (rows == 0) {
                    conn.rollback();
                    log.warning("Withdrawal failed - no rows updated");
                    return false;
                }
            }

            String logSql = "INSERT INTO TRANSACTIONS (SENDER_ACCOUNT, RECEIVER_ACCOUNT, AMOUNT, TX_TYPE, REMARK) VALUES (?, ?, ?, 'WITHDRAWAL', ?)";
            try (PreparedStatement psLog = conn.prepareStatement(logSql)) {
                psLog.setInt(1, accountNo);
                psLog.setNull(2, Types.INTEGER);
                psLog.setBigDecimal(3, amount);
                psLog.setString(4, "ATM/Counter Withdrawal");
                psLog.executeUpdate();
            }

            conn.commit();
            log.info("Withdrawal successful");
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    log.severe("Rollback failed: " + ex.getMessage());
                }
            }
            log.severe("Withdrawal failed: " + e.getMessage());
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    @Override
    public boolean transfer(int fromAcc, int toAcc, BigDecimal amount) throws SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String withdrawSql = QueryLoader.get("account.withdraw");
            try (PreparedStatement ps1 = conn.prepareStatement(withdrawSql)) {
                ps1.setBigDecimal(1, amount);
                ps1.setInt(2, fromAcc);
                ps1.setBigDecimal(3, amount);

                int rowsAffected = ps1.executeUpdate();
                if (rowsAffected == 0) {
                    conn.rollback();
                    return false;
                }
            }

            String depositSql = QueryLoader.get("account.deposit");
            try (PreparedStatement ps2 = conn.prepareStatement(depositSql)) {
                ps2.setBigDecimal(1, amount);
                ps2.setInt(2, toAcc);
                ps2.executeUpdate();
            }

            String logSql = QueryLoader.get("transaction.log");
            try (PreparedStatement ps3 = conn.prepareStatement(logSql)) {
                ps3.setInt(1, fromAcc);
                ps3.setInt(2, toAcc);
                ps3.setBigDecimal(3, amount);
                ps3.setString(4, "TRANSFER");
                ps3.setString(5, "Transfer to " + toAcc);
                ps3.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    log.severe("Rollback failed: " + ex.getMessage());
                }
            }
            log.severe("Transfer failed: " + e.getMessage());
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    @Override
    public List<Transaction> getStatement(int accountNo) throws SQLException {
        List<Transaction> txList = new ArrayList<>();
        String sql = QueryLoader.get("transaction.statement");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);
            pstmt.setInt(2, accountNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    txList.add(new Transaction(
                            rs.getInt("ID"),
                            rs.getObject("SENDER_ACCOUNT") != null ? rs.getInt("SENDER_ACCOUNT") : null,
                            rs.getObject("RECEIVER_ACCOUNT") != null ? rs.getInt("RECEIVER_ACCOUNT") : null,
                            rs.getBigDecimal("AMOUNT"),
                            rs.getString("TX_TYPE"),
                            rs.getString("REMARK"),
                            rs.getTimestamp("CREATED_AT").toLocalDateTime()
                    ));
                }
            }
        }
        return txList;
    }

    @Override
    public boolean deposit(int accountNo, BigDecimal amount) throws SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String depositSql = QueryLoader.get("account.deposit");
            try (PreparedStatement ps1 = conn.prepareStatement(depositSql)) {
                ps1.setBigDecimal(1, amount);
                ps1.setInt(2, accountNo);
                ps1.executeUpdate();
            }

            String logSql = QueryLoader.get("transaction.log");
            try (PreparedStatement ps2 = conn.prepareStatement(logSql)) {
                ps2.setInt(1, accountNo);
                ps2.setInt(2, accountNo);
                ps2.setBigDecimal(3, amount);
                ps2.setString(4, "DEPOSIT");
                ps2.setString(5, "Self Deposit");
                ps2.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    log.severe("Rollback failed: " + ex.getMessage());
                }
            }
            log.severe("Deposit failed: " + e.getMessage());
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    @Override
    public boolean changePassword(int accountNo, String oldPw, String newPw) throws SQLException {
        try (Connection conn = getConnection()) {
            String checkSql = QueryLoader.get("account.check_pw");
            try (PreparedStatement ps1 = conn.prepareStatement(checkSql)) {
                ps1.setInt(1, accountNo);

                try (ResultSet rs = ps1.executeQuery()) {
                    if (rs.next() && rs.getString("PASSWORD_HASH").equals(oldPw)) {
                        String updateSql = QueryLoader.get("user.update_password");
                        try (PreparedStatement ps2 = conn.prepareStatement(updateSql)) {
                            ps2.setString(1, newPw);
                            ps2.setInt(2, rs.getInt("USER_ID"));
                            return ps2.executeUpdate() > 0;
                        }
                    }
                }
            }
            return false;
        }
    }

    @Override
    public Optional<AccountRecoveryDTO> getRecoveryDetails(String email) throws SQLException {
        String sql = "SELECT u.FIRST_NAME, u.LAST_NAME, a.ACCOUNT_NO " +
                "FROM USERS u " +
                "JOIN ACCOUNTS a ON u.USER_ID = a.USER_ID " +
                "WHERE u.EMAIL = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(new AccountRecoveryDTO(
                            rs.getString("FIRST_NAME"),
                            rs.getString("LAST_NAME"),
                            rs.getInt("ACCOUNT_NO")
                    ));
                }
            }
        } catch (SQLException e) {
            log.severe("Error getting recovery details for email: " + email + " - " + e.getMessage());
            throw e;
        }
        return Optional.empty();
    }

    @Override
    public boolean accountExists(int accountNo) throws SQLException {
        String sql = "SELECT 1 FROM ACCOUNTS WHERE ACCOUNT_NO = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountNo);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public BigDecimal getBalance(int accountNo) throws SQLException {
        String sql = QueryLoader.get("account.get_balance");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, accountNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("BALANCE");
                }
            }
        }
        return BigDecimal.ZERO;
    }

    @Override
    public boolean updatePasswordByAccountNo(int accountNo, String newHashedPassword) throws SQLException {
        String sql = "UPDATE USERS u " +
                "JOIN ACCOUNTS a ON u.USER_ID = a.USER_ID " +
                "SET u.PASSWORD_HASH = ? " +
                "WHERE a.ACCOUNT_NO = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, newHashedPassword);
            pstmt.setInt(2, accountNo);

            int rows = pstmt.executeUpdate();
            log.info("Password update for account " + accountNo + ": " + rows + " rows affected");
            return rows > 0;

        } catch (SQLException e) {
            log.severe("Error updating password for account: " + accountNo + " - " + e.getMessage());
            throw e;
        }
    }
}