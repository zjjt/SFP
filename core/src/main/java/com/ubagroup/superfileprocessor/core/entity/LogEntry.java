package com.ubagroup.superfileprocessor.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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
    private String when;

    public LogEntry( String who, String what) {
        this.who = who;
        this.what = what;
        DateTimeFormatter dtf=DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        LocalDateTime now=LocalDateTime.now();
        this.when = dtf.format(now);
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

    public String getWhen() {
        return when;
    }

    public void setWhen(String when) {
        this.when = when;
    }
}
