package com.ubagroup.superfileprocessor.config;

import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;
import com.ubagroup.superfileprocessor.core.entity.ProcessType;
import com.ubagroup.superfileprocessor.core.entity.User;
import com.ubagroup.superfileprocessor.core.repository.model.ApiParameterConstraints;
import com.ubagroup.superfileprocessor.core.repository.model.DbFieldsTranslation;
import com.ubagroup.superfileprocessor.core.repository.model.FileSplitterMetadata;
import com.ubagroup.superfileprocessor.core.repository.model.ProcessingSteps;
import com.ubagroup.superfileprocessor.core.repository.mongodb.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class DefaultConfig {
    @Autowired
    private LogEntryRepository logEntryRepository;
    @Autowired
    private ProcessConfigRepository processConfigRepository;
    @Autowired
    private ProcessedFileRepository processedFileRepository;
    @Autowired
    private ProcessTypeRepository processTypeRepository;
    @Autowired
    private ProcessValidationRepository processValidationRepository;
    @Autowired
    private  UserRepository userRepository;
    @Value("#{'${application.mode}'}")
    private  String appmode;
    /**
     * Default value list configurable in the application.properties file
     */
    @Value("#{'${config.canal.dbfields.list}'.split(',')}")
    private List<String> canalDbFields;
    /**
     * this method generates the default validation per API steps and its parameters to be handled client side and server-side
     * @param step an integer representing the step order
     * @param configName a String representing the configuration name of which we want to generate the mappings
     * @return Map<String/ApiParameterConstraints>
     */
    private Map<String, ApiParameterConstraints> generateApiParams(int step, String configName){
        //for the booleans true for activated and false for the opposite
        var apiParams=new HashMap<String,ApiParameterConstraints>();

        if(configName=="CANAL+"){
            switch(step){
                case 1:
                    apiParams.put("file",new ApiParameterConstraints(true,false,false,10,0,0,false, false, false,true));
                    break;
                case 2:
                    apiParams.put("configName",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    break;
                case 3:
                    //here we store the user configuration for file splitting and the default positions of values in this file
                    apiParams.put("configName",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    apiParams.put("filemapping1",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    apiParams.put("filemapping2",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    apiParams.put("filemapping3",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    apiParams.put("filemapping4",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    break;
                case 4:
                    apiParams.put("fileid",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));


            }
        }else if(configName=="PAYSEND"){
            switch(step){
                case 1:
                    apiParams.put("file",new ApiParameterConstraints(true,false,false,10,0,0,false, false, false,true));
                    break;
                case 2:
                    apiParams.put("configName",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    break;
                case 3:
                    apiParams.put("validators",new ApiParameterConstraints(true,true,false,0,0,0,false, true, false,false));
                    break;
                case 4:
                    apiParams.put("subject",new ApiParameterConstraints(true,true,false,0,0,0,false, false, false,false));
                    apiParams.put("to",new ApiParameterConstraints(true,true,false,0,0,0,true, true, false,false));
                    apiParams.put("from",new ApiParameterConstraints(true,true,false,0,0,0,true, false, false,false));
                    apiParams.put("cci",new ApiParameterConstraints(false,false,false,0,0,0,true, true, false,false));
                    apiParams.put("bci",new ApiParameterConstraints(false,false,false,0,0,0,true, true, false,false));
                    apiParams.put("attachments",new ApiParameterConstraints(true,true,false,0,0,0,false, true, false,true));
                    apiParams.put("body",new ApiParameterConstraints(true,true,false,0,0,0,false, true, false,false));

                    break;
            }
        }

        return apiParams;
    }
    private  void clearAll(){
        logEntryRepository.deleteAll();
        processConfigRepository.deleteAll();
        processedFileRepository.deleteAll();
        processTypeRepository.deleteAll();
        processedFileRepository.deleteAll();
        userRepository.deleteAll();
    }
    private  void showEntete(){
        var logCount= logEntryRepository.count();
        var pCCount=processConfigRepository.count();
        var pFCount=processedFileRepository.count();
        var pTCount=processTypeRepository.count();
        var pVCount=processValidationRepository.count();
        var uCount=userRepository.count();

        System.out.println("\n\n***Super File Processor started***\n\n=======================App by ZJJT AKA the TECHNIKING for UBA Cote d'ivoire september 2020=======================\n\n\n");
        System.out.println("Document count in Log collection: "+logCount );
        System.out.println("Document count in process_config collection: "+pCCount);
        System.out.println("Document count in processed_file collection: "+pFCount);
        System.out.println("Document count in process_type collection: "+pTCount);
        System.out.println("Document count in process_validation collection: "+pVCount);
        System.out.println("Document count in Log collection: "+uCount);
    }
    /**
     * load is responsible for loading the default config in memory
     */
    public  void load(){
        System.out.println("appmode: "+appmode+"\n canalDBfields: "+canalDbFields);
        if(appmode.equals("test")){
            System.out.println("Clearing database");
            clearAll();
        }

        showEntete();
        //checking now if we should empty or re insert initial configuration data
        if(processTypeRepository.count()==0){
            processTypeRepository.saveAll(Arrays.asList(new ProcessType("FILE_UPLOAD"),new ProcessType("TXT_SPLITTER"),new ProcessType("VALIDATIONS"),new ProcessType("ALLOW_DOWNLOAD"),new ProcessType("ALLOW_MAIL_SENDING")));
            System.out.println("processing types inserted in process_type collection");
        }



        if(userRepository.count()==0){
            userRepository.save(new User("admin","uba2020","ADMIN"));
            System.out.println("Admin user inserted in user collection");

        }

        if(processConfigRepository.count()==0){
            //The project was initially developed to automate dealing with HR pay mailing to cameroon problem and CANAL+ transactions
            //so we load them here in the DB as defaults.They can be then modified from inside the code directly or using the
            //GUI admin interface along with any new config
            //PROCESS FUNCTIONALITY
            var canalFunctionality=new ArrayList<String>();
            var paySendFunctionality=new ArrayList<String>();

            //CANAL+ PROCESS
            canalFunctionality.addAll(Arrays.asList(processTypeRepository.findFirstByType("FILE_UPLOAD").getType(),processTypeRepository.findFirstByType("TXT_SPLITTER").getType(),processTypeRepository.findFirstByType("ALLOW_DOWNLOAD").getType()));
            //HR PAY SENDING PROCESS
            paySendFunctionality.addAll(Arrays.asList(processTypeRepository.findFirstByType("FILE_UPLOAD").getType(),processTypeRepository.findFirstByType("VALIDATIONS").getType(),processTypeRepository.findFirstByType("ALLOW_MAIL_SENDING").getType()));
            //the developer should not forget that the above PROCESS_TYPES are mapped with the PROCESSING_STEPS described below
            //any chnages in the processes above should then be reflected in the processing steps because they are dependant on each other
            //for building the UI accordingly


            //here we get the list of finacle database fields to map and build the query to operate
            //A modifier quand on aura toutes les infos et la config ci-dessous sert de blueprint
            var canalDefaultMapToDbField=new HashMap<String, DbFieldsTranslation>();
            //here we loop on the db fields list provided as environment variable and set the default config for
            //CANAL+ text splitting meta parameters
            for(String e:canalDbFields){
                switch(e){
                    case "ACCOUNTNO":
                        canalDefaultMapToDbField.put(e,new DbFieldsTranslation(e,"ACCOUNT NUMBER"));
                        break;
                    case "AMOUNT":
                        canalDefaultMapToDbField.put(e,new DbFieldsTranslation(e,"AMOUNT"));
                        break;
                }
            }

            var canalMeta=new FileSplitterMetadata(canalDbFields,canalDefaultMapToDbField,null);
            /* here we define CANAL+ default configuration processing steps API
                Each processing steps is linked to a functionality type and should be sequentially inserted into the list
                with the id of each step so that the UI can properly build the forms and call the correct API endpoint when a submit
                button is pushed by a user
             */
            var canalProcessingSteps=new ArrayList<ProcessingSteps>();
            canalProcessingSteps.addAll(Arrays.asList(new ProcessingSteps(1,"UPLOADING FILE","/file-upload","POST",generateApiParams(1,"CANAL+"))
                    ,new ProcessingSteps(2,"START PROCESSING WITH CURRENT CONFIG","/txt-splitter/","GET",generateApiParams(2,"CANAL+")),
                    new ProcessingSteps(3,"REGISTERING SPLITTING CONFIGURATION","/txt-splitter","POST",generateApiParams(3,"CANAL+")),
                    new ProcessingSteps(4,"DOWNLOADING RESULT","/download/","GET",generateApiParams(4,"CANAL+"))));


            //Here we define PAYSEND HR default configuration processing API please follow the explanation given above before modifying the current
            //implementation
            var paySendProcessingSteps=new ArrayList<ProcessingSteps>();
            paySendProcessingSteps.addAll(Arrays.asList(new ProcessingSteps(1,"UPLOADING FILE","/file-upload","POST",generateApiParams(1,"PAYSEND")),
                    new ProcessingSteps(2,"START PROCESSING WITH CURRENT CONFIG","/xlsprocessing/","GET",generateApiParams(2,"PAYSEND")),
                    new ProcessingSteps(3,"START THE VALIDATION PROCEDURE","/validate","POST",generateApiParams(3,"PAYSEND")),
                    new ProcessingSteps(4,"SENDING THE FINAL MAIL","/mail","POST",generateApiParams(4,"PAYSEND"))));





            //Setting the accepted file type and size for the processing
            var canalFileTypeandSize=new HashMap<String,Object>();
            canalFileTypeandSize.put("type","txt");
            canalFileTypeandSize.put("size",10);
            canalFileTypeandSize.put("space_in_memory","mb");
            var paySendFileTypeandSize=new HashMap<String,Object>();
            paySendFileTypeandSize.put("type","xlsx");
            paySendFileTypeandSize.put("size",10);
            paySendFileTypeandSize.put("space_in_memory","mb");
            var canalConfig=new ProcessConfig("CANAL+",canalFunctionality,canalMeta,canalProcessingSteps,canalFileTypeandSize);
            var paySendConfig=new ProcessConfig("PAYSEND",paySendFunctionality,null,paySendProcessingSteps,paySendFileTypeandSize);

            //inserting the default configs now
            processConfigRepository.deleteAll();
            processConfigRepository.save(canalConfig);
            processConfigRepository.save(paySendConfig);
            System.out.println("ProcessConfig for CANAL+ and PAYSEND inserted in the ProcessConfig collection");


        }


    }
}
