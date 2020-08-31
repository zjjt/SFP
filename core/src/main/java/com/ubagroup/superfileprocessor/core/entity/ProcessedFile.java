package com.ubagroup.superfileprocessor.core.entity;

import org.json.JSONObject;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

/**
 * ProcessedFiles represents how the files are kept into the DB
 */
@Document(collection="processed_file")
public class ProcessedFile {
    @Id
    private String id;
    @Indexed(unique = true)
    private JSONObject inFile;
    @Indexed(unique = true)
    private JSONObject outFile;
    private String userId;
    private String configName;
    private boolean processingStatus;
    private Date dateProcessed;

    public ProcessedFile(JSONObject inFile, JSONObject outFile, String userId, String configName, boolean processingStatus, Date dateProcessed) {
        this.inFile = inFile;
        this.outFile = outFile;
        this.userId = userId;
        this.configName = configName;
        this.processingStatus = processingStatus;
        this.dateProcessed = dateProcessed;
    }

    @Override
    public String toString() {
        return String.format("ProcessedFiles[id=%s\ninFile=%s\noutFile=%s]",id,inFile,outFile);
    }

    public String getConfigName() {
        return configName;
    }

    public void setConfigName(String configName) {
        this.configName = configName;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Date getDateProcessed() {
        return dateProcessed;
    }

    public void setDateProcessed(Date dateProcessed) {
        this.dateProcessed = dateProcessed;
    }

    public JSONObject getInFile() {
        return inFile;
    }

    public void setInFile(JSONObject inFile) {
        this.inFile = inFile;
    }

    public JSONObject getOutFile() {
        return outFile;
    }

    public void setOutFile(JSONObject outFile) {
        this.outFile = outFile;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}
