package com.ubagroup.superfileprocessor.core.utils;

import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class OracleDBConfig {
    public static String ORACLE_DRIVER="oracle.jdbc.driver.OracleDriver";
    public static String URL="jdbc:oracle:thin:@10.100.20.50:1521/UEMOAUAT";
    public static String USER="DBREAD";
    public static String PASSWORD="dbread";
    @Bean
    public DataSource dataSource(){
        return DataSourceBuilder.create()
                .driverClassName(ORACLE_DRIVER)
                .url(URL)
                .username(USER)
                .password(PASSWORD)
                .build();
    }

}


