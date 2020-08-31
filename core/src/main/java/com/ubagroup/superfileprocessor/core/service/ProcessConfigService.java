package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;
import com.ubagroup.superfileprocessor.core.repository.mongodb.ProcessConfigRepository;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

public class ProcessConfigService implements ProcessConfigInterface {
    @Autowired
    ProcessConfigRepository processConfigRepository;
    @Override
    public List<ProcessConfig> getAll() {
        return processConfigRepository.findAll();
    }

    @Override
    public ProcessConfig get(String configName) {
        return processConfigRepository.findFirstByConfigName(configName);
    }

    @Override
    public boolean updateConfig(String configName, ProcessConfig config) {
        var s=processConfigRepository.save(config);
        if(s!=null){
            return true;
        }
        return false;
    }


    @Override
    public void deleteConfig(String configName) {
        processConfigRepository.deleteByConfigName(configName);
        System.out.println("config "+configName+" deleted");
    }
}