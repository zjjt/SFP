package com.ubagroup.superfileprocessor.core.entity;

import com.ubagroup.superfileprocessor.core.repository.model.FileSplitterMetadata;
import com.ubagroup.superfileprocessor.core.repository.model.ProcessingSteps;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;
import java.util.Map;

/**
 * ProcessConfig represents a process which UBA handles with its partners ie CANAL+
 * and which is stored in the DB
 * It should be configured in such a way in order to minimize refactoring of the front end client
 * this has to be parameterized by the admins and the list of its instances should be loaded into
 * the client after connexion of a user
 */
@Document(collection="process_config")
public class ProcessConfig {
    @Id
    private String id;
    @Indexed(unique = true)
    private String configName;
    private String description;
    /**
     * The types define the frontend functionality that will be available to the user to
     * handle the task at hand depending if it requires it or not.
     * the default types are ['FILE_UPLOAD','TXT_SPLITTER','VALIDATIONS','ALLOW_DOWNLOAD','ALLOW_MAIL_SENDING']
     * Since this is a list, a processConfig can have one or many of the above mentioned types.Each functionnality
     * will be processed in order and will determine the steps shown in the front end.
     *
     * FILE_UPLOAD is the first element which is automatically present in the list
     * TXT_SPLITTER enables the possibility to split txt files on the client and store meta data about the splitting for
     * further references.
     */
    private List<String> functionnalityTypes;
    private FileSplitterMetadata metaparameters;
    private List<ProcessingSteps> processingSteps;
    private Map<String,Object> fileTypeAndSizeInMB;

    public ProcessConfig(String configName, String description, List<String> functionnalityTypes, FileSplitterMetadata metaparameters, List<ProcessingSteps> processingSteps, Map<String, Object> fileTypeAndSizeInMB) {
        this.configName = configName;
        this.description = description;
        this.functionnalityTypes = functionnalityTypes;
        this.metaparameters = metaparameters;
        this.processingSteps = processingSteps;
        this.fileTypeAndSizeInMB = fileTypeAndSizeInMB;
    }

    @Override
    public String toString() {
        return String.format("id:%s\n,configname:%s\ntypes:%s\nmetaparameters:%s\n,processingsteps:%s\nfileTypeAndSizeInMB:%s",id,configName, functionnalityTypes,metaparameters,processingSteps,fileTypeAndSizeInMB);
    }

    public Map<String, Object> getFileTypeAndSizeInMB() {
        return fileTypeAndSizeInMB;
    }

    public void setFileTypeAndSizeInMB(Map<String, Object> fileTypeAndSizeInMB) {
        this.fileTypeAndSizeInMB = fileTypeAndSizeInMB;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<String> getFunctionnalityTypes() {
        return functionnalityTypes;
    }

    public void setFunctionnalityTypes(List<String> functionnalityTypes) {
        this.functionnalityTypes = functionnalityTypes;
    }

    public FileSplitterMetadata getMetaparameters() {
        return metaparameters;
    }

    public void setMetaparameters(FileSplitterMetadata metaparameters) {
        this.metaparameters = metaparameters;
    }

    public List<ProcessingSteps> getProcessingSteps() {
        return processingSteps;
    }

    public void setProcessingSteps(List<ProcessingSteps> processingSteps) {
        this.processingSteps = processingSteps;
    }

    public String getConfigName() {
        return configName;
    }

    public void setConfigName(String configName) {
        this.configName = configName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}

