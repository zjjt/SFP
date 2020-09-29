package com.ubagroup.superfileprocessor.core.entity;

import com.ubagroup.superfileprocessor.core.repository.model.Line;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.List;

/**
 * ProcessedFiles represents how the files are kept into the DB
 */
@Document(collection="processed_file")
public class ProcessedFile {
    @Id
    private String id;
    private List<Line> inFile;
    private List<Line> outFile;
    private String userId;
    private String configName;
    private boolean processingStatus;
    private boolean hasBeenExecutedOnce;
    private boolean canBeRemoved;
    private Date lastExecution;
    private Date nextExecution;
    private Date dateProcessed;
    private List<Line> fileLines;

    public ProcessedFile(List<Line> inFile, List<Line> outFile, String userId, String configName, boolean processingStatus, boolean hasBeenExecutedOnce, boolean canBeRemoved, Date lastExecution, Date nextExecution, Date dateProcessed, List<Line> fileLines) {
        this.inFile = inFile;
        this.outFile = outFile;
        this.userId = userId;
        this.configName = configName;
        this.processingStatus = processingStatus;
        this.hasBeenExecutedOnce = hasBeenExecutedOnce;
        this.canBeRemoved = canBeRemoved;
        this.lastExecution = lastExecution;
        this.nextExecution = nextExecution;
        this.dateProcessed = dateProcessed;
        this.fileLines = fileLines;
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

    public List<Line> getInFile() {
        return inFile;
    }

    public void setInFile(List<Line> inFile) {
        this.inFile = inFile;
    }

    public List<Line> getOutFile() {
        return outFile;
    }

    public void setOutFile(List<Line> outFile) {
        this.outFile = outFile;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public List<Line> getFileLines() {
        return fileLines;
    }

    public void setFileLines(List<Line> fileLines) {
        this.fileLines = fileLines;
    }

    public boolean isProcessingStatus() {
        return processingStatus;
    }

    public void setProcessingStatus(boolean processingStatus) {
        this.processingStatus = processingStatus;
    }

    public Date getNextExecution() {
        return nextExecution;
    }

    public void setNextExecution(Date nextExecution) {
        this.nextExecution = nextExecution;
    }

    public Date getLastExecution() {
        return lastExecution;
    }

    public void setLastExecution(Date lastExecution) {
        this.lastExecution = lastExecution;
    }

    public boolean isHasBeenExecutedOnce() {
        return hasBeenExecutedOnce;
    }

    public void setHasBeenExecutedOnce(boolean hasBeenExecutedOnce) {
        this.hasBeenExecutedOnce = hasBeenExecutedOnce;
    }

    public boolean isCanBeRemoved() {
        return canBeRemoved;
    }

    public void setCanBeRemoved(boolean canBeRemoved) {
        this.canBeRemoved = canBeRemoved;
    }
}
