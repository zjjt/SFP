package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.processors.Processors;
import com.ubagroup.superfileprocessor.core.service.ProcessedFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.time.Instant;
import java.util.*;

@RestController
@RequestMapping("/files")
public class ProcessedFileController {
    @Autowired
    ProcessedFileService processedFileService;
    @Value("#{'${application.mode}'}")
    private  String appmode;

    @PostMapping("/delete")
    public Map<String, Object> deleteFiles(@RequestParam("file_ids[]") List<String> ids) {
        var m = new TreeMap<String, Object>();
        if (!ids.isEmpty()) {
            ids.stream()
                    .parallel()
                    .forEach(id -> {
                        m.put("fileId", id);
                    });
        }
        if (!m.isEmpty()) {
            processedFileService.delete(m);
            m.clear();
            m.put("errors", false);
            m.put("message", "files deleted successfully");
            System.out.println(m);
        } else {
            m.put("errors", true);
            m.put("message", "A problem occurred while trying to delete the files");
            System.out.println(m);
        }
        return m;
    }
    @GetMapping("/get-in-process")
    public Map<String,Object> getProcessingFiles(@RequestParam(value = "uid") String userId,
                                                 @RequestParam(value = "configname")String configName){
        System.out.println("getting list of current files in processing for the uid "+userId+" for the config "+configName);
        List<ProcessedFile> files=processedFileService.getAll(false,false,true,false,
                new Date(0),new Date(0),new Date(0),userId,configName);
        var m = new HashMap<String, Object>();
        m.put("errors", false);
        m.put("message", " "+files.size()+" found");
        m.put("fichiers", files);
        return m;

    }

    @PostMapping("/upload")
    public Map<String, Object> uploadFile(@RequestParam("files[]") List<MultipartFile> files,
                                          @RequestParam(name = "configName") String configName,
                                          @RequestParam(name = "userId") String userId, HttpServletRequest request) {
        System.out.println("uploading " + files.size() + " files API ---- called with content type " + files.get(0).getContentType());
        List<ProcessedFile> treatedFiles = new ArrayList<>();

        var m = new HashMap<String, Object>();
        if (!files.isEmpty()) {
            //Here we forward everything to the service which will handle the proper treatment based on the processing config chosen
            //Normally we should just send the files over to another microservice for recollection and handling but
            //we will go the messy way for now until we have time to refactor present code
            long start = Instant.now().toEpochMilli();

            try {
                treatedFiles = processedFileService.processFiles(files, userId, configName,appmode);
                //the files have been processed and now we need to read from the db and save into db
            } catch (ClassNotFoundException e) {
                long end = Instant.now().toEpochMilli();
                m.put("errors", true);
                m.put("message", "an error occured during processing check your files");
                m.put("processing_time", (end - start) + " milliseconds");
                m.put("fichiers", new ArrayList<>());
                e.printStackTrace();
                return m;
            } catch (NoSuchMethodException e) {
                long end = Instant.now().toEpochMilli();
                m.put("errors", true);
                m.put("message", "an error occured during processing check your files");
                m.put("processing_time", (end - start) + " milliseconds");
                m.put("fichiers", new ArrayList<>());
                e.printStackTrace();
                return m;
            } catch (IllegalAccessException e) {
                long end = Instant.now().toEpochMilli();
                m.put("errors", true);
                m.put("message", "an error occured during processing check your files");
                m.put("processing_time", (end - start) + " milliseconds");
                m.put("fichiers", new ArrayList<>());
                e.printStackTrace();
                return m;
            } catch (InvocationTargetException e) {
                long end = Instant.now().toEpochMilli();
                m.put("errors", true);
                m.put("message", "an error occured during processing check your files");
                m.put("processing_time", (end - start) + " milliseconds");
                m.put("fichiers", new ArrayList<>());
                e.printStackTrace();
                return m;
            }

            long end = Instant.now().toEpochMilli();
            m.put("errors", false);
            m.put("message", "files uploaded successfully");
            m.put("processing_time", (end - start) + " milliseconds");
            m.put("fichiers", treatedFiles);
            return m;
        }
        m.put("errors", true);
        m.put("message", "No files provided, please report this to IT SUPPORT");
        m.put("processing_time", 0 + " milliseconds");
        m.put("fichiers", treatedFiles);
        return m;
    }
}
