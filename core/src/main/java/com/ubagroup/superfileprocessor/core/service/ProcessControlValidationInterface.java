package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessControlValidation;

import java.util.List;

public interface ProcessControlValidationInterface {
    List<ProcessControlValidation> getAll();
    ProcessControlValidation getOne(String configName,String initiatorId);
    boolean saveOne(ProcessControlValidation process);
    void deleteOne(String configName,String initiatorId);
}
