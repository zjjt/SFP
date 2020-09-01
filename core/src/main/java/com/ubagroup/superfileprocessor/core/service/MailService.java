package com.ubagroup.superfileprocessor.core.service;

import java.io.File;
import java.util.List;

public class MailService implements MailingInterface {
    @Override
    public boolean sendMail(String subject, List<String> to, String from, List<String> cci, List<String> bci, List<File> attachments, String body) {
        return false;
    }
}
