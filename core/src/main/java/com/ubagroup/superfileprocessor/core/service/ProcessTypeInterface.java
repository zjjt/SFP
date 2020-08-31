package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessType;

import java.util.List;

public interface ProcessTypeInterface {
    List<ProcessType> getAll();
    boolean addOne(ProcessType type);
}
