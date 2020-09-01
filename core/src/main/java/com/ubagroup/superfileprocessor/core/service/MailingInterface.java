package com.ubagroup.superfileprocessor.core.service;

import java.io.File;
import java.util.List;

public interface MailingInterface {
    boolean sendMail(String subject, List<String> to,String from,List<String> cci,List<String> bci,List<File> attachments,String body);
}
