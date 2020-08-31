package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.ProcessType;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ProcessTypeRepository extends MongoRepository<ProcessType,String> {
    //SELECT
     ProcessType findFirstByType(String type);
    //DELETE
     void deleteByType(String type);

}
