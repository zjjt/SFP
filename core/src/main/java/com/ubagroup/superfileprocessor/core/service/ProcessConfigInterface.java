package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;

import java.util.List;

public interface ProcessConfigInterface  {
    List<ProcessConfig> getAll();
    ProcessConfig get(String configName);
    boolean updateConfig(String configName,ProcessConfig config);
    void deleteConfig(String configName);
}
