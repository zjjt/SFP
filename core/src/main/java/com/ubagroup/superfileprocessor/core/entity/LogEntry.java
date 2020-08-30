package com.ubagroup.superfileprocessor.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.stereotype.Component;

import java.util.Date;

/**
 * LogEntry represents a log entry in the db
 */
@Document(collection="logs")
public class LogEntry {
    @Id
    private String id;
    private String who;
    private String what;
    private Date when;

    public LogEntry( String who, String what, Date when) {
        this.who = who;
        this.what = what;
        this.when = when;
    }

    @Override
    public String toString() {
        return String.format("LogEntry:[id:%s\nwho:%s\nwhat:%s\nwhen:%s]",id,who,what,when);
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getWho() {
        return who;
    }

    public void setWho(String who) {
        this.who = who;
    }

    public String getWhat() {
        return what;
    }

    public void setWhat(String what) {
        this.what = what;
    }

    public Date getWhen() {
        return when;
    }

    public void setWhen(Date when) {
        this.when = when;
    }
}
