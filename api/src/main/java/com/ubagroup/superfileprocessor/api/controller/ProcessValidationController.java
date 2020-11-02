package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.ProcessControlValidation;
import com.ubagroup.superfileprocessor.core.entity.ProcessValidation;
import com.ubagroup.superfileprocessor.core.service.ProcessControlValidationService;
import com.ubagroup.superfileprocessor.core.service.ProcessValidationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/validation")
public class ProcessValidationController {
    @Autowired
    ProcessValidationService processValidationService;
    @Autowired
    ProcessControlValidationService processControlValidationService;

    @PostMapping
    public Map<String,Object> updateValidationProcess(@RequestParam(name="validatorId") String validatorId,
                                                      @RequestParam(name="validation") String validation,
                                                      @RequestParam(name="validationType") String validationType,
                                                      @RequestParam(name="configName") String configName,
                                                      @RequestParam(name="initiatorId") String initiatorId,
                                                      @RequestParam(name="rejectionMotive") String rejectionMotive){
        var m = new HashMap<String, Object>();
        if(validationType.equalsIgnoreCase("CONTROLLER")){
            ProcessControlValidation p=processControlValidationService.getOne(configName,initiatorId);
            var validatorMap=p.getValidators();
            validatorMap.put(validatorId,validation);
            p.setValidators(validatorMap);

            if(validation.equalsIgnoreCase("REJECTED")){
                var motives=p.getValidatorMotives();
                motives.put(validatorId,rejectionMotive);
                p.setValidatorMotives(motives);
            }
            if(processControlValidationService.saveOne(p)){
                m.put("errors", false);
                m.put("message", "process control validation  updated successfully");
                m.put("processValidation", p);
                return m;
            }else{
                m.put("errors", true);
                m.put("message", "process control validation couldnt be updated");
                m.put("processControlValidation", p);
                return m;
            }

        }else if(validationType.equalsIgnoreCase("VALIDATOR")){
            ProcessValidation p=processValidationService.getOne(configName,initiatorId);
            var validatorMap=p.getValidators();
            validatorMap.put(validatorId,validation);
            p.setValidators(validatorMap);
            if(validation.equalsIgnoreCase("REJECTED")){
                var motives=p.getValidatorMotives();
                motives.put(validatorId,rejectionMotive);
                p.setValidatorMotives(motives);
            }
            if(processValidationService.saveOne(p)){
                m.put("errors", false);
                m.put("message", "process validation  updated successfully");
                m.put("processValidation", p);
                return m;
            }else{
                m.put("errors", true);
                m.put("message", "process validation couldnt be updated");
                m.put("processControlValidation", p);
                return m;
            }
        }
        m.put("errors", true);
        m.put("message", "process validation couldnt be updated");
        m.put("processControlValidation", null);
        return m;
    }

    @PostMapping("/validator")
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
    @PostMapping("/controller")
    public Map<String, Object> createControlValidationProcess(@RequestBody ProcessControlValidation processValidation) {
        var m = new HashMap<String, Object>();
        if (processControlValidationService.saveOne(processValidation)) {
            m.put("errors", false);
            m.put("message", "process validation control  updated successfully");
            m.put("processValidation", processValidation);
            return m;
        }
        m.put("errors", true);
        m.put("message", "process validation control couldnt be updated");
        m.put("processValidation", processValidation);
        return m;
    }

    @GetMapping
    public Map<String,Object> getValidationProcess(@RequestParam(value = "configName") String configName,
                                                   @RequestParam(value = "initiatorId") String userId,
                                                   @RequestParam(value = "validatorType") String validatorType){
        System.out.println("Getting validators of type "+validatorType);
        var m=new HashMap<String,Object>();
        var p=validatorType.equalsIgnoreCase("VALIDATOR")?
                processValidationService.getOne(configName,userId):
                validatorType.equalsIgnoreCase("CONTROLLER")?
                        processControlValidationService.getOne(configName,userId):null;
        System.out.println(p);
        if(Objects.nonNull(p)){
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

    @PostMapping("/deleteValidation")
    public Map<String,Object> deleteValidationProcess(@RequestParam(value = "configName") String configName,
                                                      @RequestParam(value = "initiatorId") String initiatorId,
                                                      @RequestParam(value = "validatorType") String validatorType){
        var m=new HashMap<String,Object>();
        if(validatorType.equalsIgnoreCase("VALIDATOR")){
            processValidationService.deleteOne(configName,initiatorId);

        }else if(validatorType.equalsIgnoreCase("CONTROLLER")){
            processControlValidationService.deleteOne(configName,initiatorId);
        }
        var deleted=validatorType.equalsIgnoreCase("VALIDATOR")?
                processValidationService.getOne(configName,initiatorId):
                validatorType.equalsIgnoreCase("CONTROLLER")?
                        processControlValidationService.getOne(configName,initiatorId):null;
        if(!Objects.nonNull(deleted)){
            m.put("errors", false);
            m.put("message", "existing process validation for "+configName+ "and initiatorId "+initiatorId+" of type "+validatorType+" deleted");
            return m;
        }
        m.put("errors", true);
        m.put("message", "An error occured while trying to delete the validation process");
        return m;
    }
}
