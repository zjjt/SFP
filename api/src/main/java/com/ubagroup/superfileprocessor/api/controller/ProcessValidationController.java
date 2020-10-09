package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.ProcessValidation;
import com.ubagroup.superfileprocessor.core.service.ProcessValidationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/validation")
public class ProcessValidationController {
    @Autowired
    ProcessValidationService processValidationService;

    @PostMapping
    public Map<String, Object> createValidationProcess(@RequestBody ProcessValidation processValidation) {
        var m = new HashMap<String, Object>();
        if (processValidationService.saveOne(processValidation)) {
            m.put("errors", false);
            m.put("message", "process validation  updated successfully");
            m.put("processValidation", processValidation);
            return m;
        }
        m.put("errors", true);
        m.put("message", "process validation couldnt be updated");
        m.put("processValidation", processValidation);
        return m;
    }

    @GetMapping
    public Map<String,Object> getValidationProcess(@RequestParam(value = "configName") String configName,
                                                   @RequestParam(value = "initiatorId") String userId){
        var m=new HashMap<String,Object>();
        ProcessValidation p=processValidationService.getOne(configName,userId);
        if(!p.equals(null)){
            m.put("errors", false);
            m.put("message", "process validation found");
            m.put("processValidation", p);
            return m;
        }
        m.put("errors", true);
        m.put("message", "process validation couldnt be found");
        m.put("processValidation", null);
        return m;
    }
}
