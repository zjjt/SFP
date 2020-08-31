package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.ProcessValidation;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ProcessValidationRepository extends MongoRepository<ProcessValidation,String> {
    //SELECT
     ProcessValidation findFirstByConfigNameAndInitiatorId(String configName,String initiatorId);
    //DELETE
     void deleteByConfigNameAndInitiatorId(String configName,String initiatorId);

}
