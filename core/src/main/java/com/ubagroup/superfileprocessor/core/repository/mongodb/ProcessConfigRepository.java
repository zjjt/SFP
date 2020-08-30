package com.ubagroup.superfileprocessor.core.repository.mongodb;
import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ProcessConfigRepository extends MongoRepository<ProcessConfig,String> {
    //SELECT
    public List<ProcessConfig> findByConfigName(String configName);
    //DELETE
    public void deleteByConfigName(String configName);
}
