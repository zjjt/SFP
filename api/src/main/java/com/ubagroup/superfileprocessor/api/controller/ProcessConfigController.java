package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;
import com.ubagroup.superfileprocessor.core.service.ProcessConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/PC")
public class ProcessConfigController {
    @Autowired
    private ProcessConfigService processConfigService;
    //CRUD
    @GetMapping
    public List<ProcessConfig> get(@RequestParam(name="name",required = false) String configName){
        System.out.println("get process config API ---- called");
        if(configName!=null){
            var l=new ArrayList<ProcessConfig>();
            l.add(processConfigService.get(configName));
            return l;
        }
        return processConfigService.getAll();
    }
    @PostMapping
    public Map<String,Object> saveConfig(ProcessConfig config){
        var m=new HashMap<String,Object>();
        if(processConfigService.saveConfig(config)){
            m.put("errors",false);
            m.put("message","Process config saved in db");
            return m;
        }
        m.put("errors",true);
        m.put("message","Something went wrong while saveng the process config in the db");
        return m;

    }
    @PostMapping("/remove")
    public Map<String,Object> deleteConfig(String configName){
        var m=new HashMap<String,Object>();
        processConfigService.deleteConfig(configName);
        m.put("errors",false);
        m.put("message","Process config deleted from db");
        return m;

    }
    //PROCESSING
    @PostMapping("/processing/file-upload")
    public Map<String,Object> fileUpload(@RequestParam("file")MultipartFile[] file){

    }
}
