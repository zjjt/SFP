package com.ubagroup.superfileprocessor.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * ProcessType represents the type of processing allowed in the current process
 * the default types are ['FILE_UPLOAD','TXT_SPLITTER','VALIDATIONS','ALLOW_DOWNLOAD','ALLOW_MAIL_SENDING']
 */
@Document(collection="process_type")
public class ProcessType {
    @Id
    private String id;
    @Indexed(unique = true)
    private String type;

    public ProcessType(String type) {
        this.type = type;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
