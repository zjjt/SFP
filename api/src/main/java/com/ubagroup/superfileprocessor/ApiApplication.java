package com.ubagroup.superfileprocessor;
import com.ubagroup.superfileprocessor.config.DefaultConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.*;

@SpringBootApplication
public class ApiApplication implements CommandLineRunner {
    @Autowired
    private DefaultConfig defaultConfig;
    public static void main(String[] args) {
        SpringApplication.run(ApiApplication.class, args);
    }
    //Initial setup of the database
    @Override
    public void run(String... args)throws Exception{
        //loading default configuration
        defaultConfig.load();
    }

}
