package com.ubagroup.superfileprocessor.core.repository.mongodb;
import org.springframework.data.mongodb.repository.MongoRepository;

import com.ubagroup.superfileprocessor.core.entity.ProcessControlValidation;

public interface ProcessControlValidationRepository extends MongoRepository<ProcessControlValidation,String> {
    ProcessControlValidation findFirstByConfigNameAndInitiatorId(String configName, String initiatorId);
    //DELETE
    void deleteByConfigNameAndInitiatorId(String configName,String initiatorId);
}
