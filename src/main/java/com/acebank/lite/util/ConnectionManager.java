package com.acebank.lite.util;

import org.apache.ibatis.jdbc.ScriptRunner;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Logger;

public final class ConnectionManager {

    private static Connection connection;
    private static boolean isSchemaInitialized = false;
    static final Logger log = Logger.getLogger(ConnectionManager.class.getName());

    private ConnectionManager() {}

    public static synchronized Connection getConnection() throws SQLException {
        // Always create a new connection to avoid closed connection issues
        Connection newConn = establishConnection();

        // Run schema initialization only once
        if (!isSchemaInitialized) {
            runInitScript(newConn);
            isSchemaInitialized = true;
        }

        return newConn;
    }

    private static Connection establishConnection() throws SQLException {
        try {
            String url = ConfigLoader.getProperty(ConfigKeys.DB_URL);
            String user = ConfigLoader.getProperty(ConfigKeys.DB_USER);
            String pass = ConfigLoader.getProperty(ConfigKeys.DB_PWD);
            String driverName = ConfigLoader.getProperty(ConfigKeys.DB_MYSQL_DRIVER);

            if (url == null || user == null || pass == null) {
                throw new SQLException("Database configuration missing. Check application-dev.properties");
            }

            Class.forName(driverName);
            Connection conn = DriverManager.getConnection(url, user, pass);
            log.info("Database connection established to: " + url);
            return conn;
        } catch (ClassNotFoundException e) {
            log.severe("MySQL JDBC Driver not found: " + e.getMessage());
            throw new SQLException("Database driver not found", e);
        } catch (Exception e) {
            log.severe("Database Connection Failed: " + e.getMessage());
            throw new SQLException("Could not establish database connection", e);
        }
    }

    private static void runInitScript(Connection conn) {
        String scriptPath = ConfigLoader.getProperty(ConfigKeys.DB_SCRIPT_PATH);
        if (scriptPath == null || scriptPath.isEmpty()) {
            log.warning("No script path configured, skipping schema initialization");
            return;
        }

        String normalizedPath = scriptPath.startsWith("/") ? scriptPath : "/" + scriptPath;
        log.info("Attempting to run schema script from: " + normalizedPath);

        try (InputStream is = ConnectionManager.class.getResourceAsStream(normalizedPath)) {
            if (is == null) {
                log.warning("Schema script not found at: " + normalizedPath);
                log.warning("Please create tables manually in MySQL");
                return;
            }

            ScriptRunner runner = new ScriptRunner(conn);
            runner.setLogWriter(null);
            runner.setErrorLogWriter(null);
            runner.setStopOnError(false);
            runner.setThrowWarning(false);
            runner.setAutoCommit(true);
            runner.setSendFullScript(true);

            log.info("Executing schema script...");
            runner.runScript(new BufferedReader(new InputStreamReader(is)));
            log.info("Database schema script executed successfully");

            // Verify tables were created
            var stmt = conn.createStatement();
            var rs = stmt.executeQuery("SHOW TABLES");
            log.info("Tables in database:");
            while (rs.next()) {
                log.info("  - " + rs.getString(1));
            }
            rs.close();
            stmt.close();

        } catch (Exception e) {
            log.severe("Schema initialization error: " + e.getMessage());
            log.severe("Please create tables manually in MySQL");
        }
    }
}