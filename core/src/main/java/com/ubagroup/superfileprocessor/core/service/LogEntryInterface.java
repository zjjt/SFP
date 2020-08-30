package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.LogEntry;

import java.util.Date;
import java.util.List;

public interface LogEntryInterface {
    List<LogEntry> getLogs(String who,String what, Date when);
    List<LogEntry> getLogsBefore(String who,String what, Date when);
    List<LogEntry> getLogsAfter(String who,String what, Date when);
    List<LogEntry> getLogsBetween (String who,String what, Date one,Date two);
}
