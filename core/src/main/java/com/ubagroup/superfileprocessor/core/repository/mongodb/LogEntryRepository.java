package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.LogEntry;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

public interface LogEntryRepository extends MongoRepository<LogEntry,String> {
    //Select
    public List<LogEntry> findByWho(String who);
    public List<LogEntry> findByWhoLike(String who);
    public List<LogEntry> findByWhat(String what);
    public List<LogEntry> findByWhatLike(String what);
    public List<LogEntry> findByWhen(Date when);
    public List<LogEntry> findByWhenBefore(Date when);
    public List<LogEntry> findByWhenAfter(Date when);
    public List<LogEntry> findByWhenBetween(Date one,Date two);
    public List<LogEntry> findByWhoAndWhatAndWhen(String who,String what,Date when);
    public List<LogEntry> findByWhoAndWhatBefore(String who,String what,Date when);
    public List<LogEntry> findByWhoAndWhatAfter(String who,String what,Date when);
    public List<LogEntry> findByWhatAfter(String what,Date when);
    public List<LogEntry> findByWhoAfter(String who,Date when);
    public List<LogEntry> findByWhatBefore(String what,Date when);
    public List<LogEntry> findByWhoBefore(String who,Date when);
    public List<LogEntry> findByWhoAndWhat(String who,String what);
    public List<LogEntry> findByWhoAndWhatBetween(String who,String what,Date one,Date two);
    public List<LogEntry> findByWhatAndWhen(String what,Date when);
    public List<LogEntry> findByWhatAndWhenIsBetween(String what,Date one,Date two);
    public List<LogEntry> findByWhoAndWhenIsBetween(String who,Date one,Date two);
    public List<LogEntry> findByWhoAndWhen(String who,Date when);


    //DELETE
    public void deleteByWhatBefore(Date date);


}
