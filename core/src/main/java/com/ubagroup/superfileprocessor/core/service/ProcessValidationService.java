package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessValidation;
import com.ubagroup.superfileprocessor.core.repository.mongodb.ProcessValidationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProcessValidationService implements ProcessValidationInterface {
    @Autowired
    private ProcessValidationRepository processValidationRepository;
    @Override
    public List<ProcessValidation> getAll() {
        return processValidationRepository.findAll();
    }

    @Override
    public ProcessValidation getOne(String configName, String initiatorId) {
        return processValidationRepository.findFirstByConfigNameAndInitiatorId(configName,initiatorId);
    }

    @Override
    public boolean saveOne(ProcessValidation process) {
        var s=processValidationRepository.save(process);
        if(s!=null){
            return true;
        }
        return false;
    }

    @Override
    public void deleteOne(String configName, String initiatorId) {
        processValidationRepository.deleteByConfigNameAndInitiatorId(configName,initiatorId);
    }
}
