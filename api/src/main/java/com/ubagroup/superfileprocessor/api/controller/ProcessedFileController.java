package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.processors.Processors;
import com.ubagroup.superfileprocessor.core.service.ProcessedFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@RestController
@RequestMapping("/upload")
public class ProcessedFileController {
    @Autowired
    ProcessedFileService processedFileService;

    @PostMapping
    public Map<String,Object> uploadFile(@RequestParam("files[]") List<MultipartFile> files,
                                         @RequestParam(name="configName") String configName,
                                         @RequestParam(name="userName") String userName, HttpServletRequest request)  {
        System.out.println("uploading "+files.size()+" files API ---- called");

        var m=new HashMap<String,Object>();
        if(!files.isEmpty()){
            //Here we forward everything to the service which will handle the proper treatment based on the processing config chosen
            try{
                Thread.sleep(5*1000);

            }catch(InterruptedException ex){
                ex.printStackTrace();
            }
            //Here we proceed with reading the files
            //Normally we should just send the files over to another microservice for recollection and handling but
            //we will go the messy way for now until we have time to refactor present code
            List<InputStream> fichiersInputStreams=new ArrayList<>();
            try{
                for(MultipartFile file:files){
                    fichiersInputStreams.add(file.getInputStream());
                }
                Class<?> processClass=Class.forName("com.ubagroup.superfileprocessor.core.processors.Processors");
                Method process= processClass.getDeclaredMethod(configName.toLowerCase()+"Processor",List.class);
                process.invoke(new Processors(),fichiersInputStreams);
            }catch(IOException | ClassNotFoundException e){
                e.printStackTrace();
            }catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }

            //here we use reflection based on the configuration name received via the api to call the right processor method
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
