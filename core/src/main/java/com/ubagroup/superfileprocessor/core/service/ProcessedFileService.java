package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.repository.mongodb.ProcessedFileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class ProcessedFileService implements ProcessedFileInterface {
    @Autowired
    private ProcessedFileRepository processedFileRepository;
    @Override
    public List<ProcessedFile> getAll(boolean between, boolean byDate, boolean treated,
                                      boolean processingStatus,Date one, Date two, Date when, String userId,String configName)
            throws IllegalArgumentException {
        if(between){
            //we check between a period
            if(userId.isEmpty()||configName.isEmpty()){
                if(one==null || two==null){
                    throw new IllegalArgumentException("you have to enter a period to search in between");
                }
                return processedFileRepository.findByDateProcessedBetween(one, two);
            }
            if(one==null || two==null){
                throw new IllegalArgumentException("you have to enter a period to search in between");
            }
            return processedFileRepository.findByUserIdAndConfigNameAndDateProcessedIsBetween(userId,configName,one,two);
        }else if(byDate){
            //we check where date is
            if(when==null){
                throw new IllegalArgumentException("Please provide a valid date");
            }
            if(!userId.isEmpty()){
                return processedFileRepository.findByUserIdAndDateProcessed(userId,when);
            }
            return processedFileRepository.findByDateProcessed(when);
        }else if(treated){
            //we check for all that are treated
            if(!userId.isEmpty()&&configName.isEmpty()){
                return processedFileRepository.findByUserIdAndProcessingStatus(userId,processingStatus);
            }else if(userId.isEmpty()&&!configName.isEmpty()){
                return processedFileRepository.findByConfigNameAndProcessingStatus(configName,processingStatus);
            }
            return processedFileRepository.findByProcessingStatus(processingStatus);
        }else{
            //return everything
            return processedFileRepository.findAll();
        }
    }

    @Override
    public void delete(Map<String,Object> arg) {
        //arg is in the form of a where {"K":"V"}
        for(Map.Entry<String,Object> element:arg.entrySet()){
            switch(element.getKey()){
                case "userId":
                    processedFileRepository.deleteAllByUserId((String)element.getValue());
                    break;
                case "processingStatus":
                    processedFileRepository.deleteAllByProcessingStatus((boolean)element.getValue());
                    break;
                case "dateProcessed":
                    processedFileRepository.deleteAllByDateProcessed((Date)element.getValue());
                    break;
            }
        }
    }
}
