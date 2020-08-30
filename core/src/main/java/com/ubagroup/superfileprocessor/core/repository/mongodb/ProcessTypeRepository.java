package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.ProcessType;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ProcessTypeRepository extends MongoRepository<ProcessType,String> {
    //SELECT
    public List<ProcessType> findByTypeLike(String type);
    public ProcessType findFirstByType(String type);
    //DELETE
    public void deleteByType(String type);

}
