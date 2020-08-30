package com.ubagroup.superfileprocessor.core.repository.model;


/**
 * DbFieldsTranslation this class helps in translating the dbFields configured by the admin into a user readable format
 * for displaying to the user in the frontend
 */
public class DbFieldsTranslation {
    private String dbField;
    private String translation;

    public DbFieldsTranslation(String dbField, String translation) {
        this.dbField = dbField;
        this.translation = translation;
    }

    public String getDbField() {
        return dbField;
    }

    public void setDbField(String dbField) {
        this.dbField = dbField;
    }

    public String getTranslation() {
        return translation;
    }

    public void setTranslation(String translation) {
        this.translation = translation;
    }
}
