package com.ubagroup.superfileprocessor.jobs;

import com.cronutils.descriptor.CronDescriptor;
import com.cronutils.model.CronType;
import com.cronutils.model.definition.CronDefinition;
import com.cronutils.model.definition.CronDefinitionBuilder;
import com.cronutils.model.time.ExecutionTime;
import com.cronutils.parser.CronParser;
import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;
import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.processors.Processors;
import com.ubagroup.superfileprocessor.core.repository.model.Line;
import com.ubagroup.superfileprocessor.core.service.ProcessConfigService;
import com.ubagroup.superfileprocessor.core.service.ProcessedFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.swing.*;
import java.text.SimpleDateFormat;
import java.time.ZonedDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Component
public class CronJob {
    @Autowired
    ProcessedFileService processedFileService;
    @Autowired
    ProcessConfigService processConfigService;
    private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    @Value("#{'${application.mode}'}")
    private String appmode;

    @Scheduled(cron = "#{@getCanalCronTime}")
    public void processCanalTask() {
        System.out.println("############## CANAL+ TASK RUNNING ##############");
        CronParser cronParser = new CronParser(CronDefinitionBuilder.instanceDefinitionFor(CronType.SPRING));
        CronDescriptor descriptor = CronDescriptor.instance(Locale.UK);
        ProcessConfig canalConfig = processConfigService.get("CANAL");
        String description = descriptor.describe(cronParser.parse(canalConfig.getMetaparameters().getExecutionTime()));
        System.out.println("JOB DESCRIPTION TIME: " + description);
        Date dateFinCron = new GregorianCalendar(Calendar.getInstance().get(Calendar.YEAR),
                Calendar.getInstance().get(Calendar.MONTH)+1,
                06).getTime();
        Date dateDebutCron = new GregorianCalendar(Calendar.getInstance().get(Calendar.YEAR),
                Calendar.getInstance().get(Calendar.MONTH),
                24).getTime();
        System.out.println("job must be running before "+ dateFinCron+"\nand starting after the "+dateDebutCron+" \n is today between the processing period ? "+(new Date().before(dateFinCron) && new Date().after(dateDebutCron)));
        List<ProcessedFile> listofFiles = processedFileService.getAll(false, false,
                true, false, new Date(), new Date(), new Date(), "", "CANAL","");
        if (true/*new Date().before(dateFinCron) && new Date().after(dateDebutCron)*/) {
            System.out.println("Step 1: checking if there are some file left to process");
            System.out.println(listofFiles.size() + " files remaining to process\n Step 1 done");
            System.out.println("Step 2: Processing " + listofFiles.size() + " files now");
            if (listofFiles.size() > 0) {
                listofFiles.stream()
                        .parallel()
                        .map(f -> {
                            //we
                            Processors processor = new Processors();
                            System.out.println("...getting account balance");
                            if (appmode.equalsIgnoreCase("dev")) {
                                f.setFileLines(processor.getSoldeFromJson(f.getFileLines()));
                            } else {
                                f.setFileLines(processor.getSolde(f.getFileLines()));
                            }
                            try {
                                System.out.println("...starting the debit procedure");
                                f.setFileLines(processor.doCanalDebit(f.getFileLines()));
                            } catch (CloneNotSupportedException e) {
                                System.out.println("EXCEPTION----");
                                System.out.println("Exception Cause : " + e.getCause());
                                System.out.println("Exception Message : " + e.getMessage());
                                e.printStackTrace();
                            }
                            //we reorder the processing lines based on the initial list
                            f.getFileLines().sort(Comparator.comparing(l->(Integer)l.getLigne().get("LINENO~0")));
                            f.getFileLines().add(0, f.getInFile().get(0));
                            f.getFileLines().add(f.getInFile().get(f.getInFile().size() - 1));
                            System.out.println("...generating the status codes");
                            List<Line> lignesGenerated = processor.reconcileCanal(f.getFileLines(), f.getInFile());
                            f.setOutFile(lignesGenerated);
                            System.out.println("...end of file processing");
                            System.out.println("INITIAL lines " + f.getInFile().size() + " column count" + f.getInFile().get(2).getLigne().entrySet().size());
                            System.out.println("PROCESSING lines " + f.getFileLines().size() + " column count" + f.getFileLines().get(2).getLigne().entrySet().size());
                            System.out.println("GENERATED lines " + f.getOutFile().size() + " column count" + f.getOutFile().get(2).getLigne().entrySet().size());

                            return f;
                        })
                        .collect(Collectors.toList());
                System.out.println("Step 3 generating the final file and saving into the database");
                //Here we update everything and the config
                //get next execution time
                // Get date for last execution
                ZonedDateTime now = ZonedDateTime.now();
                ExecutionTime executionTime = ExecutionTime.forCron(cronParser.parse(canalConfig.getMetaparameters().getExecutionTime()));
                ZonedDateTime lastExecution = executionTime.lastExecution(now).get();
                // Get date for next execution
                ZonedDateTime nextExecution = executionTime.nextExecution(now).get();
                System.out.println("Last execution: " + lastExecution + " next execution: " + nextExecution);
                listofFiles.stream()
                        .parallel()
                        .map(f -> {
                            f.setLastExecution(Date.from(lastExecution.toInstant()));
                            f.setNextExecution(Date.from(nextExecution.toInstant()));
                            f.setHasBeenExecutedOnce(true);
                            return f;
                        })
                        .collect(Collectors.toList());
                //now we update the properties on the file
                if (processedFileService.saveProcessedFile(listofFiles)) {
                    System.out.println("the files have been properly saved");
                } else {
                    System.out.println("the files couldnt be saved properly check the code");
                }
            } else {
                System.out.println("---there is no files to process ---");
            }
        }else if(new Date().compareTo(dateFinCron)==0){
            System.out.println("---the CANAL+ file processing is done---");
            listofFiles.stream()
                    .parallel()
                    .map(f->{
                        f.setLastExecution(new Date(0));
                        f.setNextExecution(new Date(0));
                        f.setCanBeRemoved(true);
                        f.setProcessingStatus(true);
                        return f;
                    })
                    .collect(Collectors.toList());
            if(processedFileService.saveProcessedFile(listofFiles)){
                System.out.println("files saved properly now the user can download them");
            }else{
                System.out.println("there was a problem saving the files");
            }
        } else {
            System.out.println("---Waiting for the day to start CANAL+ ----");

        }
        System.out.println("Scheduler processCanalTask task with duration : " + sdf.format(new Date()) + "\n\n################ End of CANAL+ JOB ################");

    }
}
