package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.LogEntry;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

public interface LogEntryRepository extends MongoRepository<LogEntry,String> {
    //Select
     List<LogEntry> findByWho(String who);
     List<LogEntry> findByWhatIsLike(String what);
     List<LogEntry> findByWhen(Date when);
     List<LogEntry> findByWhenBefore(Date when);
     List<LogEntry> findByWhenAfter(Date when);
     List<LogEntry> findByWhenBetween(Date one,Date two);
     List<LogEntry> findByWhoAndWhatIsLikeAndWhen(String who,String what,Date when);
     List<LogEntry> findByWhoAndWhatBefore(String who,String what,Date when);
     List<LogEntry> findByWhoAndWhatAfter(String who,String what,Date when);
     List<LogEntry> findByWhatAfter(String what,Date when);
     List<LogEntry> findByWhoAfter(String who,Date when);
     List<LogEntry> findByWhatBefore(String what,Date when);
     List<LogEntry> findByWhoBefore(String who,Date when);
     List<LogEntry> findByWhoAndWhatIsLike(String who,String what);
     List<LogEntry> findByWhoAndWhatIsLikeAndWhenIsBetween(String who,String what,Date one,Date two);
     List<LogEntry> findByWhatIsLikeAndWhen(String what,Date when);
     List<LogEntry> findByWhatIsLikeAndWhenIsBetween(String what,Date one,Date two);
     List<LogEntry> findByWhoAndWhenIsBetween(String who,Date one,Date two);
     List<LogEntry> findByWhoAndWhen(String who,Date when);
    List<LogEntry> findByWhoAndWhatIsLikeAndWhenIsBefore(String who, String what, Date when);
    List<LogEntry> findByWhatIsLikeAndWhenIsBefore(String what, Date when);
    List<LogEntry> findByWhoAndWhenIsBefore(String who, Date when);
    List<LogEntry> findByWhatIsLikeAndWhenIsAfter(String what, Date when);
    List<LogEntry> findByWhoAndWhatIsLikeAndWhenIsAfter(String who, String what, Date when);
    List<LogEntry> findByWhoAndWhenIsAfter(String who, Date when);


    //DELETE
    public void deleteByWhatBefore(Date date);



}
