package com.ubagroup.superfileprocessor.core.repository.model;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * This class represents the data with which the txt file splitter view on the front end will
 * generate in order to be saved in the DB.On the client if such a config is found then it
 * will ask the user to skip the manual file splitting and start processing the file right
 * away.
 */
public class FileSplitterMetadata {
    /**
     * the dbFields list is to be mapped with custom config inserted by the user
     */
    private List<String> dbFields;
    /**
     * a cron job
     * in the form of a cron syntax * * * * *
     */
    private String executionTime;

    private Date endingDate;

    /**
     * the custom config will be mapped to the dbFields and their onscreen translation item and stored in a DbFieldsTranslation instance
     */
    private Map<String, DbFieldsTranslation> mapToDbFields;
    private Map<String, List<Integer>> positions;


    public FileSplitterMetadata(List<String> dbFields, String executionTime, Date endingDate, Map<String, DbFieldsTranslation> mapToDbFields, Map<String, List<Integer>> positions) {
        this.dbFields = dbFields;
        this.executionTime = executionTime;
        this.endingDate = endingDate;
        this.mapToDbFields = mapToDbFields;
        this.positions = positions;
    }

    @Override
    public String toString() {
        return String.format("FileSplitterMetadata:[dbfields:%s\nmapToDbFields:%s\n,positions:%s]", dbFields, mapToDbFields, positions);
    }

    public String getExecutionTime() {
        return executionTime;
    }

    public void setExecutionTime(String executionTime) {
        this.executionTime = executionTime;
    }


    public Map<String, DbFieldsTranslation> getMapToDbFields() {
        return mapToDbFields;
    }

    public void setMapToDbFields(Map<String, DbFieldsTranslation> mapToDbFields) {
        this.mapToDbFields = mapToDbFields;
    }


    public List<String> getDbFields() {
        return dbFields;
    }

    public void setDbFields(List<String> dbFields) {
        this.dbFields = dbFields;
    }


    public Map<String, List<Integer>> getPositions() {
        return positions;
    }

    public void setPositions(Map<String, List<Integer>> positions) {
        this.positions = positions;
    }


    public Date getEndingDate() {
        return endingDate;
    }

    public void setEndingDate(Date endingDate) {
        this.endingDate = endingDate;
    }


}
