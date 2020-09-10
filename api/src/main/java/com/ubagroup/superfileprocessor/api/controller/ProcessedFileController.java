package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.service.ProcessedFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
@RestController
@RequestMapping("/upload")
public class ProcessedFileController {
    @Autowired
    ProcessedFileService processedFileService;
    @PostMapping
    public Map<String,Object> uploadFile(@RequestParam(name="files") List<MultipartFile> files,
                                         @RequestParam(name="configName") String configName,
                                         @RequestParam(name="userName") String userName){
        System.out.println("uploading "+files.size()+" files API ---- called");
        System.out.println(files.toString());

        var m=new HashMap<String,Object>();
        if(!files.isEmpty()){
            //Here we forward everything to the service which will handle the proper treatment based on the processing config chosen
            System.out.println(files);
            m.put("errors",false);
            m.put("message","files uploaded successfully");
            return m;
        }
        m.put("errors",true);
        m.put("message","No files provided, please report this to IT SUPPORT");
        return m;
    }
}
