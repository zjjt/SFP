package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface ProcessedFileInterface {
    List<ProcessedFile> getAll(boolean between, boolean byDate, boolean treated,boolean processingStatus, Date one, Date two, Date when,String userId,String configName);
    void delete(Map<String,Object> arg);
}
