package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Date;
import java.util.List;

public interface ProcessedFileRepository extends MongoRepository<ProcessedFile,String> {
    //SELECT
    public List<ProcessedFile> findByDateProcessed(Date date);
    public List<ProcessedFile> findByDateProcessedBetween(Date one,Date two);
    //DELETE
    public void deleteByDateProcessedAndUserId(Date date,String userId);
}
