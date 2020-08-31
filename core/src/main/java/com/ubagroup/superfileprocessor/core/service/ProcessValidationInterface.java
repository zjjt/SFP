package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessValidation;

import java.util.List;

public interface ProcessValidationInterface {
    List<ProcessValidation> getAll();
    ProcessValidation getOne(String configName,String initiatorId);
    boolean saveOne(ProcessValidation process);
    void deleteOne(String configName,String initiatorId);
}
