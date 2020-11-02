package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessControlValidation;
import com.ubagroup.superfileprocessor.core.repository.mongodb.ProcessControlValidationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.util.List;
@Service
public class ProcessControlValidationService implements ProcessControlValidationInterface{
    @Autowired
    private ProcessControlValidationRepository processControlValidationRepository;
    @Override
    public List<ProcessControlValidation> getAll() {
        return processControlValidationRepository.findAll();
    }

    @Override
    public ProcessControlValidation getOne(String configName, String initiatorId) {
        return processControlValidationRepository.findFirstByConfigNameAndInitiatorId(configName,initiatorId);
    }

    @Override
    public boolean saveOne(ProcessControlValidation process) {
        var s=processControlValidationRepository.save(process);
        if(s!=null){
            return true;
        }
        return false;
    }

    @Override
    public void deleteOne(String configName, String initiatorId) {
        processControlValidationRepository.deleteByConfigNameAndInitiatorId(configName,initiatorId);
    }
}
