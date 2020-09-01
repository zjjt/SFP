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
        System.out.println("parameters value who: "+who+" what: "+what+" when: "+when);
        List<LogEntry> logs;
        //here we check arguments for building the query
        if(who !=null && what!=null && when!=null){
            //getlogs for who and what and when  TESTED
            System.out.println("for who and what and when");
            logs=logEntryRepository.findByWhoAndWhatIsLikeAndWhen(who,what,when);

        }else if(who==null && what!=null && when!=null){
            //getlogs for what and when TESTED
            System.out.println("for what and when");
            logs=logEntryRepository.findByWhatIsLikeAndWhen(what,when);

        }else if(who==null && what==null && when!=null){
            //getlogs for when only TESTED
            System.out.println("for when only");
            logs=logEntryRepository.findByWhen(when);
        }else if(who!=null && what==null && when!=null){
            //getlogs for who and when TESTED
            System.out.println("for who and when");
            logs=logEntryRepository.findByWhoAndWhen(who,when);
        }else if(who!=null && what!=null && when==null){
            //getlogs for who and what TESTED
            System.out.println("for who and what");
            logs=logEntryRepository.findByWhoAndWhatIsLike(who,what);
        }else if(who!=null && what==null && when==null){
            //getlogs for who only TESTED
            System.out.println("for who only");
            logs=logEntryRepository.findByWho(who);
        }else if(who==null && what!=null && when==null){
            //getlogs for what only TESTED
            System.out.println("for what only");
            logs=logEntryRepository.findByWhatIsLike(what);
        }else{
            //get all the logs in db TESTED
            System.out.println("all the logs in db");
            logs=logEntryRepository.findAll();
        }
        return logs;
    }

    @Override
    public List<LogEntry> getLogsBefore(String who, String what, Date when) throws IllegalArgumentException{
        System.out.println("parameters value who: "+who+" what: "+what+" when: "+when);

        if(when==null){
            throw new IllegalArgumentException("please fill out the period of time to do the checking");
        }
        List<LogEntry> logs=new ArrayList<>();
        //here we check arguments for building the query
        if(who !=null && what!=null ){
            //getlogs for who and what before when TESTED
            System.out.println("for who and what before when");
            logs=logEntryRepository.findByWhoAndWhatIsLikeAndWhenIsBefore(who,what,when);
        }else if(who==null && what!=null ){
            //getlogs for what before when TESTED
            System.out.println("for what before when");
            logs=logEntryRepository.findByWhatIsLikeAndWhenIsBefore(what,when);
        }else if(who!=null && what==null ){
            //getlogs for who before when TESTED
            System.out.println("for who before when");
            logs=logEntryRepository.findByWhoAndWhenIsBefore(who,when);
        }
        return logs;
    }

    @Override
    public List<LogEntry> getLogsAfter(String who, String what, Date when)throws IllegalArgumentException {
        System.out.println("parameters value who: "+who+" what: "+what+" when: "+when);
        if(when==null){
            throw new IllegalArgumentException("please fill out the period of time to do the checking");
        }
        List<LogEntry> logs=new ArrayList<>();
        //here we check arguments for building the query
        if(who !=null && what!=null){
            //getlogs for who and what after when TESTED
            System.out.println("for who and what after when");
            logs=logEntryRepository.findByWhoAndWhatIsLikeAndWhenIsAfter(who,what,when);
        }else if(who==null && what!=null){
            //getlogs for what after when TESTED
            System.out.println("for what after when");
            logs=logEntryRepository.findByWhatIsLikeAndWhenIsAfter(what,when);
        }else if(who!=null && what==null ){
            //getlogs for who after when TESTED
            System.out.println("for who after when");
            logs=logEntryRepository.findByWhoAndWhenIsAfter(who,when);
        }
        return logs;
    }

    @Override
    public List<LogEntry> getLogsBetween (String who, String what, Date one, Date two) throws IllegalArgumentException {
        System.out.println("parameters value who: "+who+" what: "+what+" date1: "+one+" date2: "+two);
        List<LogEntry> logs=new ArrayList<>();
        if(one==null || two==null){
            throw new IllegalArgumentException("please fill out the period of time to do the checking");
        }
        if(who!=null && what!=null){
            //TESTED
            System.out.println("for who and what between");
            logs=logEntryRepository.findByWhoAndWhatIsLikeAndWhenIsBetween(who,what,one,two);
        }else if(who==null && what!=null){
            //TESTED
            System.out.println("for what between");
            logs=logEntryRepository.findByWhatIsLikeAndWhenIsBetween(what,one,two);
        }else if(who!=null && what==null){
            //TESTED
            System.out.println("for who is between");
            logs=logEntryRepository.findByWhoAndWhenIsBetween(who,one,two);
        }else{
            //TESTED
            System.out.println("when date is between");
            logs=logEntryRepository.findByWhenBetween(one,two);
        }
        return logs;
    }
    //the logs are built and stored
    public boolean saveLogs(List<LogEntry> logs){
        //saving all the logs TESTED
        System.out.println("saving log "+logs);
        var l=logEntryRepository.saveAll(logs);
        if(l!=null && !l.isEmpty()){
            return true;
        }
        return false;
    }
    public LogEntry delete(LogEntry log){
        //TESTED
        System.out.println("deleting log "+log);
        logEntryRepository.delete(log);
        return log;
    }
    //bulk delete
    public boolean delete(List<LogEntry> logs){
        //TESTED
        System.out.println("deleting log "+logs);
        logEntryRepository.deleteAll(logs);
        return true;
    }
    public void exportToXL(){
        var logs=getLogs(null,null,null);
        //here we write to the excel file and we return the file stream
    }

}
