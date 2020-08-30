package com.ubagroup.superfileprocessor.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

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
     * a list of the different validators id and the current validation status in the form of a {"userid":"validationstatus"}.
     * The different status allowed are:
     * OK,REJECTED,STANDBY
     * OK means ok for transmission
     * REJECTED triggers a popup on the frontend to enter the rejection motives and this notifies the INITIATOR user who can decide
     * to restart or retract the current file uploaded.If he does then we delete the processValidation by its id and recreate a new one
     * we also update the VALIDATORS if he requests to
     * STANDBY is the default status
     */
    private Map<String,String> validators;

    public ProcessValidation(String configName, String initiatorId, Map<String, String> validators) {
        this.configName = configName;
        this.initiatorId = initiatorId;
        this.validators = validators;
    }

    @Override
    public String toString() {
        return String.format("ProcessValidation:[id:%s\nconfigName:%s\n,initiatorId:%s\nvalidators:%s\n]",id,configName,initiatorId,validators);
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
}
