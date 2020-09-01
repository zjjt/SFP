package com.ubagroup.superfileprocessor.core.repository.model;

import java.util.Map;

/**
 * ProcessingSteps represents a particular step in a particular processing configuration pipeline
 * ie a ProcessConfig instance.
 * this class intended purpose is to help the client build up a proper view for the user so that
 * each press of the validating button control, switches to the next ProcessingStep
 */
public class ProcessingSteps {
    private int stepNumber;
    private String stepName;
    private String apiEndpoint;
    private String httpverb;
    private Map<String,ApiParameterConstraints> apiParameters;

    public ProcessingSteps(int stepNumber, String stepName, String apiEndpoint, String httpverb, Map<String, ApiParameterConstraints> apiParameters) {
        this.stepNumber = stepNumber;
        this.stepName = stepName;
        this.apiEndpoint = apiEndpoint;
        this.httpverb = httpverb;
        this.apiParameters = apiParameters;
    }

    @Override
    public String toString() {
        return String.format("ProcessingSteps:[stepNo:%d,stepName:%s,apiEndpoint:%s,httpVerb:%s,apiParameters:%s]",stepNumber,stepName,apiEndpoint,httpverb, apiParameters);
    }

    public int getStepNumber() {
        return stepNumber;
    }

    public void setStepNumber(int stepNumber) {
        this.stepNumber = stepNumber;
    }

    public String getStepName() {
        return stepName;
    }

    public void setStepName(String stepName) {
        this.stepName = stepName;
    }

    public String getApiEndpoint() {
        return apiEndpoint;
    }

    public void setApiEndpoint(String apiEndpoint) {
        this.apiEndpoint = apiEndpoint;
    }

    public String getHttpverb() {
        return httpverb;
    }

    public void setHttpverb(String httpverb) {
        this.httpverb = httpverb;
    }

    public Map<String, ApiParameterConstraints> getApiParameters() {
        return apiParameters;
    }

    public void setApiParameters(Map<String, ApiParameterConstraints> apiParameters) {
        this.apiParameters = apiParameters;
    }
}

