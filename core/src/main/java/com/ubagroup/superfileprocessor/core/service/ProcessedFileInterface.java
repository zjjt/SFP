package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.util.Date;
import java.util.List;
import java.util.Map;

public interface ProcessedFileInterface {
    List<ProcessedFile> getAll(boolean between, boolean byDate, boolean treated,boolean processingStatus, Date one, Date two, Date when,String userId,String configName,String fileId);
    void delete(Map<String,Object> arg);
    boolean saveProcessedFile(List<ProcessedFile> files);
    List<String> generateFilePaths(String configName, String userId);
    List<ProcessedFile> processFiles(List<MultipartFile> files, String userId, String configName,String appmode,String processingId) throws ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException;
}
