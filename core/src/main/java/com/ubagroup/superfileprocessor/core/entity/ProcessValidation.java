package com.ubagroup.superfileprocessor.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;
import java.util.Map;

/**
 * ProcessValidation class represents a process where validation is required
 */
@Document(collection="validation_process")
public class ProcessValidation {
    @Id
    private String id;
    @Indexed(unique = true)
    private String configName;
    private String initiatorId;
    /**
     * a list of files submitted as attachments the format of the whole object is a list of maps
     *
     */
    private List<Map<String,Object>> addedFiles;
    /**
     * a list of the different validators id and the current validation status in the form of a {"usermailid":"validationstatus"}.
     * The different status allowed are:
     * OK,REJECTED,STANDBY
     * OK means ok for transmission
     * REJECTED triggers a popup on the frontend to enter the rejection motives and this notifies the INITIATOR user who can decide
     * to restart or retract the current file uploaded.If he does then we delete the processValidation by its id and recreate a new one
     * we also update the VALIDATORS if he requests to
     * STANDBY is the default status
     */
    private Map<String,String> validators;
    private Map<String,String> validatiorMotives;

    public ProcessValidation(String configName, String initiatorId, List<Map<String,Object>> addedFiles, Map<String, String> validators, Map<String, String> validatiorMotives) {
        this.configName = configName;
        this.initiatorId = initiatorId;
        this.addedFiles = addedFiles;
        this.validators = validators;
        this.validatiorMotives = validatiorMotives;
    }

    @Override
    public String toString() {
        return String.format("ProcessValidation:[id:%s\nconfigName:%s\n,initiatorId:%s\nvalidators:%s\n]",id,configName,initiatorId,validators);
    }

    public Map<String, String> getValidatiorMotives() {
        return validatiorMotives;
    }

    public void setValidatiorMotives(Map<String, String> validatiorMotives) {
        this.validatiorMotives = validatiorMotives;
    }

    public String getInitiatorId() {
        return initiatorId;
    }

    public void setInitiatorId(String initiatorId) {
        this.initiatorId = initiatorId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Map<String, String> getValidators() {
        return validators;
    }

    public void setValidators(Map<String, String> validators) {
        this.validators = validators;
    }

    public String getConfigName() {
        return configName;
    }

    public void setConfigName(String configName) {
        this.configName = configName;
    }

    public List<Map<String,Object>> getAddedFiles() {
        return addedFiles;
    }

    public void setAddedFiles(List<Map<String,Object>> addedFiles) {
        this.addedFiles = addedFiles;
    }
}
