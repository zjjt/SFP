package com.ubagroup.superfileprocessor.core.repository.model;

import java.util.Map;

/**
 * This class represents a single entry line of a txt file which is stored in the collection
 * It should also have a flag and the date the line has been processed at the end of the internal map to hold the current line debit operation status
 * like "statusProcessing":"OK" and "dateProcessed":"Date.now()"
 * for canal+ configuration for exemple from the 25th of the current month to the 5th of the next one a cron job has to run
 * to check for each line of the file if the bank account can be debited.if the debit operation occurs, we mark the line as OK
 * if not it will be NOK.the next day the cron will proceed to handle the lines which are NOK
 */
public class Line {
    private Map<String, Object> ligne;

    public Line(Map<String, Object> ligne) {
        this.ligne = ligne;
    }
    public void removeKey(String key){
        ligne.remove(key);
    }

    public Map<String, Object> getLigne() {
        return ligne;
    }

    public void setLigne(Map<String, Object> ligne) {
        this.ligne = ligne;
    }
}
