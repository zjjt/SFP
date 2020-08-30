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
}
