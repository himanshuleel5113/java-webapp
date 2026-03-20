package com.acebank.lite.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {
    private static final Properties properties = new Properties();

    static {
        // Look for the file in the src/main/resources folder
        try (InputStream is = ConfigLoader.class.getClassLoader()
                .getResourceAsStream(ConfigKeys.DEV_PROPERTIES)) {

            if (is == null) {
                throw new RuntimeException("Could not find " + ConfigKeys.DEV_PROPERTIES);
            }
            properties.load(is);

        } catch (IOException e) {
            throw new RuntimeException("Failed to load configuration", e);
        }
    }

    /**
     * Retrieves a property value.
     * It checks Environment Variables first (great for Render!)
     * and falls back to the properties file.
     */
    public static String getProperty(String key) {
        // Priority 1: Check System Environment (Render/Docker)
        String envValue = System.getenv(key.replace(".", "_").toUpperCase());

        // I am giving priority to env variables
        if (envValue != null) return envValue;

        // Priority 2: Check the properties file
        return properties.getProperty(key);
    }
}