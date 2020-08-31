package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessType;
import com.ubagroup.superfileprocessor.core.repository.mongodb.ProcessTypeRepository;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

public class ProcessTypeService implements ProcessTypeInterface {
    @Autowired
    private ProcessTypeRepository processTypeRepository;
    @Override
    public List<ProcessType> getAll() {
        return processTypeRepository.findAll();
    }

    @Override
    public boolean addOne(ProcessType type) {
        var s=processTypeRepository.save(type);
        if(s!=null){
            return true;
        }
        return false;
    }
}
