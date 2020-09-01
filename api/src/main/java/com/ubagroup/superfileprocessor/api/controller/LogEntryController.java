package com.ubagroup.superfileprocessor.api.controller;
import com.ubagroup.superfileprocessor.core.entity.LogEntry;
import com.ubagroup.superfileprocessor.core.service.LogEntryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/log")
public class LogEntryController {
    @Autowired
    private LogEntryService logEntryService;
    @GetMapping
    public List<LogEntry> getLogs(@RequestParam(name="who",required = false) String who,
                                  @RequestParam(name="what",required = false)String what,
                                  @RequestParam(name="when",required = false) @DateTimeFormat(iso=DateTimeFormat.ISO.DATE) Date when,
                                  @RequestParam(name="before",required = false) boolean before,
                                  @RequestParam(name="after",required = false) boolean after,
                                  @RequestParam(name="between",required = false) boolean between,
                                  @RequestParam(name="one",required = false) @DateTimeFormat(iso=DateTimeFormat.ISO.DATE) Date one,
                                  @RequestParam(name="two",required = false) @DateTimeFormat(iso=DateTimeFormat.ISO.DATE) Date two){
        System.out.println("getLogs API ----called ");
        List<LogEntry> list=new ArrayList<>();
        if(before){
            try{
                list=logEntryService.getLogsBefore(who,what,when);
            }catch(IllegalArgumentException e){
                System.out.println(e.getMessage());
            }

        }else if(after){
            try{
                list=logEntryService.getLogsAfter(who,what,when);
            }catch(IllegalArgumentException e){
                System.out.println(e.getMessage());
            }

        }else if(between && one!=null && two !=null){
            try{
                list=logEntryService.getLogsBetween(who,what,one,two);
            }catch(IllegalArgumentException e){
                System.out.println(e.getMessage());
            }
        }else{
            System.out.println("getting all logs ");
            list=logEntryService.getLogs(who,what,when);
        }

        return list;
    }

    @PostMapping
    public Map<String,Object> writeLogs(@RequestBody List<LogEntry> logs){
        System.out.println("writeLogs API ---- called ");
        var m=new HashMap<String,Object>();
        if(logEntryService.saveLogs(logs)){
            m.put("errors",false);
            m.put("message","Logs written in db");
            return m;
        }
        m.put("errors",true);
        m.put("message","failed to write logs into the DB");
        return m;
    }

    @PostMapping("/remove")
    public Map<String,Object> deleteLog(@RequestBody List<LogEntry> logs){
        System.out.println("deleteLog API ----- called");
        var m=new HashMap<String,Object>();
        logEntryService.delete(logs);
        m.put("errors",false);
        m.put("message","Logs deleted");
        return m;
    }

}
