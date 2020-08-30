package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.LogEntry;
import com.ubagroup.superfileprocessor.core.repository.mongodb.LogEntryRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
public class LogEntryService implements LogEntryInterface {
    @Autowired
    private LogEntryRepository logEntryRepository;

    @Override
    public List<LogEntry> getLogs(String who, String what, Date when) {
        List<LogEntry> logs=new ArrayList<>();
        //here we check arguments for building the query
        if(who !=null && what!=null && when!=null){
            //getlogs for who and what and when
            logs=logEntryRepository.findByWhoAndWhatAndWhen(who,what,when);

        }else if(who==null && what!=null && when!=null){
            //getlogs for what and when
            logs=logEntryRepository.findByWhatAndWhen(what,when);

        }else if(who==null && what==null && when!=null){
            //getlogs for when only
            logs=logEntryRepository.findByWhen(when);
        }else if(who!=null && what==null && when!=null){
            //getlogs for who and when
            logs=logEntryRepository.findByWhoAndWhen(who,when);
        }else if(who!=null && what!=null && when!=null){
            //getlogs for who and what
            logs=logEntryRepository.findByWhoAndWhat(who,what);
        }else if(who!=null && what==null && when==null){
            //getlogs for who only
            logs=logEntryRepository.findByWho(who);
        }else if(who==null && what!=null && when==null){
            //getlogs for what only
            logs=logEntryRepository.findByWhatLike(what);
        }else{
            //get al the logs in db
            logs=logEntryRepository.findAll();
        }
        return logs;
    }

    @Override
    public List<LogEntry> getLogsBefore(String who, String what, Date when) {
        List<LogEntry> logs=new ArrayList<>();
        //here we check arguments for building the query
        if(who !=null && what!=null && when!=null){
            //getlogs for who and what before when
            logs=logEntryRepository.findByWhoAndWhatBefore(who,what,when);
        }else if(who==null && what!=null && when!=null){
            //getlogs for what before when
            logs=logEntryRepository.findByWhatBefore(what,when);
        }else if(who!=null && what==null && when!=null){
            //getlogs for who before when
            logs=logEntryRepository.findByWhoBefore(who,when);
        }
        return logs;
    }

    @Override
    public List<LogEntry> getLogsAfter(String who, String what, Date when) {
        List<LogEntry> logs=new ArrayList<>();
        //here we check arguments for building the query
        if(who !=null && what!=null && when!=null){
            //getlogs for who and what after when
            logs=logEntryRepository.findByWhoAndWhatAfter(who,what,when);
        }else if(who==null && what!=null && when!=null){
            //getlogs for what after when
            logs=logEntryRepository.findByWhatAfter(what,when);
        }else if(who!=null && what==null && when!=null){
            //getlogs for who after when
            logs=logEntryRepository.findByWhoAfter(who,when);
        }
        return logs;
    }

    @Override
    public List<LogEntry> getLogsBetween (String who, String what, Date one, Date two) throws IllegalArgumentException {
        List<LogEntry> logs=new ArrayList<>();
        if(one==null || two==null){
            throw new IllegalArgumentException("please fill out the period of time to do the checking");
        }
        if(who!=null&&what!=null){

        }
    }

    public boolean saveLog(List<LogEntry> logs){
        //saving all the logs
        return false;
    }
    public LogEntry delete(LogEntry log){
        return log;
    }
    //bulk delete
    public boolean delete(List<LogEntry> log){
        return false;
    }

}
