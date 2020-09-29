package com.ubagroup.superfileprocessor;

import com.ubagroup.superfileprocessor.config.DefaultConfig;
import com.ubagroup.superfileprocessor.core.service.ProcessConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.web.servlet.MultipartAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.*;

@SpringBootApplication()
@EnableScheduling
public class ApiApplication implements CommandLineRunner {
    @Autowired
    private DefaultConfig defaultConfig;
    @Autowired
    private ProcessConfigService processConfigService;

    public static void main(String[] args) {
        SpringApplication.run(ApiApplication.class, args);
    }

    //Initial setup of the database
    @Override
    public void run(String... args) throws Exception {
        //loading default configuration
        defaultConfig.load();
    }

    @Bean
    public String getCanalCronTime() {
        var list = processConfigService.getAll();
        String executionTime = "0 */5 * * * *";
        if (list.size() > 0) {
            var c = processConfigService.get("CANAL");
            executionTime = c.getMetaparameters().getExecutionTime();
        }
        return executionTime;
    }

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**");
            }
        };
    }


}
