package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Date;
import java.util.List;

public interface ProcessedFileRepository extends MongoRepository<ProcessedFile,String> {
    //SELECT
     List<ProcessedFile> findByDateProcessed(Date date);
    List<ProcessedFile> findByUserIdAndDateProcessed(String userId,Date date);
    List<ProcessedFile> findByUserIdAndProcessingStatus(String userId,boolean processingStatus);
    List<ProcessedFile> findByUserIdAndConfigNameAndProcessingStatus(String userId,String configName,boolean processingStatus);
    List<ProcessedFile> findByConfigNameAndProcessingStatus(String userId,boolean processingStatus);
     List<ProcessedFile> findByUserIdAndConfigName(String uid,String configName);
    List<ProcessedFile> findByUserIdAndConfigNameAndDateProcessedIsBetween(String uid,String configName,Date one,Date two);
     List<ProcessedFile> findByDateProcessedBetween(Date one,Date two);
     List<ProcessedFile> findByProcessingStatus(boolean processingStatus);
    //DELETE
     void deleteByDateProcessedAndUserId(Date date,String userId);
     void deleteAllByUserId(String userId);
     void deleteAllByProcessingStatus(boolean processingStatus);
     void deleteAllByDateProcessed(Date date);
     void deleteAllByUserIdAndProcessingStatus(String userId,boolean processingStatus);
}
