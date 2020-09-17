package com.ubagroup.superfileprocessor.core.processors;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.repository.model.Line;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.openxml4j.opc.OPCPackage;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.bson.BsonBinarySubType;
import org.bson.types.Binary;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

/**
 * Processors are methods paired with the actual processing configuration parametrized to handle the file processings
 * this class methods should all be suffixed with  "Processor" so that java's reflection mechanism can find the right
 * processor for the files uploaded
 */
public class Processors {


    public List<ProcessedFile> canalProcessor(List<MultipartFile>files, String userId, String configName) {
        List<ProcessedFile> treatedFiles=new ArrayList<>();
        System.out.println("in canal+ processor processing " + files.size() + " files for " + configName + " with userId " + userId);
        files.stream()
                .parallel()
                .forEach((file) -> {
                    //first we create a new instance of processedFile so that we can store the initial filein binary format in mongo
                    ProcessedFile f = new ProcessedFile(null, null, userId, configName, false, new Date(), null);
                        List<Line> lignes=readTXT(file,configName);
                        f.setFileLines(lignes);
                        f.setOutFile(lignes);
                        for(var l:lignes){
                            l.removeKey("process_done");
                        }
                        f.setInFile(lignes);
                        f.setOutFile(lignes);
                        treatedFiles.add(f);


                    //third we read each line and store them in the db
                    //we set a cron task for retrieving each line of the file and update it depending on the currentConfig
                    //another cron task will be responsible of monitoring when the previous one finishes to alert the UI
                });
        return treatedFiles;
    }

    //this method processes an Excel file list via multithreading

    public List<ProcessedFile> sageProcessor(List<MultipartFile> files, String userId, String configName) {
        List<ProcessedFile> treatedFiles=new ArrayList<>();
        System.out.println("in sage processor processing " + files.size() + " files for " + configName + " with userId " + userId);
        files.stream()
                .parallel()
                .forEach((file) -> {
                    //first we create a new instance of processedFile so that we can store the initial file in binary format in mongo
                    ProcessedFile f = new ProcessedFile(null, null, userId, configName, false, new Date(), null);

                    try {
                        System.out.println("original filename is "+file.getOriginalFilename());
                        List<Line> lignes=readXlsx(OPCPackage.open(file.getInputStream()));
                        f.setFileLines(lignes);
                        f.setInFile(lignes);
                        f.setOutFile(lignes);
                        treatedFiles.add(f);
                    } catch (IOException | InvalidFormatException e) {
                        e.printStackTrace();
                    }

                    //third we read each line and store them in the db


                    //we set a cron task for retrieving each line of the file and update it depending on the currentConfig
                });
        return treatedFiles;
    }

    private List<Line> readTXT(MultipartFile file, String configName) {
        List<Line> lignes=new ArrayList<>();
        try{
            List<String> theTXT=new BufferedReader(new InputStreamReader(file.getInputStream())).lines().collect(Collectors.toList());
            AtomicInteger index=new AtomicInteger();
            theTXT.parallelStream()
                    .map(line->line.split("\\s+"))//split line into individual words
                    .parallel()
                    .forEachOrdered(lineArr->{
                        Line ligne=new Line(new HashMap<>());
                        Map<String,Object> m=new TreeMap<>();
                        Arrays.stream(lineArr)
                                .parallel()
                                .forEachOrdered(word->{
                                    System.out.println("word is "+word);
                                    switch(configName){
                                        case "CANAL":
                                            //here we check that we are on the last line
                                            if(index.get()==theTXT.size()-1){
                                                System.out.println("on the last line of the file "+word);
                                                if(!m.containsKey("lastline".toUpperCase())){
                                                    m.put("lastline".toUpperCase(),word);
                                                }else{
                                                    System.out.println("lastline already exist so"+m.get("lastline".toUpperCase())+"\t"+word);
                                                    m.put("lastline".toUpperCase(),m.get("lastline".toUpperCase())+"\t"+word);
                                                }

                                                return;
                                            }
                                            if(word.matches("^[0-9].*[a-zA-Z].*+$")){
                                                // we get the first part and here we split it between the first part
                                                // and the name

                                               var nameStart=word.replaceAll("\\d","");
                                               var firstNoPart=word.replaceAll("[A-Z]","");
                                                firstNoPart=firstNoPart.replaceAll("\\+","");
                                                //System.out.println("nameStart "+nameStart+"\n firstnumpart "+firstNoPart);
                                               m.put("inc~1".toUpperCase(),firstNoPart.substring(0,6));
                                               m.put("date_debit~2".toUpperCase(),firstNoPart.substring(6,13));
                                               m.put("bank_code~3".toUpperCase(),firstNoPart.substring(13,21));
                                                m.put("account~4".toUpperCase(),firstNoPart.substring(nameStart.contentEquals("CANAL+")?22:21));
                                                m.put("customer_name~5".toUpperCase(),nameStart);
                                               return;
                                            }
                                            //check if we are dealing with customer's other's name so we can update the map
                                            //if not it then its the UBA label
                                            if(word.matches("^[a-zA-Z]*$")||word.contains("-")){
                                                System.out.println("the word is"+word);
                                                if(word.contains("UBA") && !word.contentEquals("UBA")){
                                                    var lastname=word.replaceAll("UBA","");
                                                    m.put("customer_name~5".toUpperCase(),m.get("customer_name~5".toUpperCase())+" "+lastname);
                                                    m.put("uba_bank~6".toUpperCase(),"UBA");
                                                    System.out.println("name is mixed with UBA for "+m.get("customer_name~5".toUpperCase()));
                                                    return;
                                                }
                                                if(word.contentEquals("UBA")){
                                                    m.put("uba_bank~6".toUpperCase(),word);
                                                    return;
                                                }
                                                m.put("customer_name~5".toUpperCase(),m.get("customer_name~5".toUpperCase())+" "+word);
                                            }
                                            //storing canalreference
                                            if(word.matches("^[A-Z].*[0-9]$") && word.contains("CANAL")){
                                                m.put("canal_ref~7".toUpperCase(),word);
                                            }
                                            //storing the date_payment
                                            if(word.matches("^[0-9].*$") && word.length()==6){
                                                m.put("date_pay~8".toUpperCase(),word);
                                            }
                                            //storing the amount
                                            if(word.matches("^[0-9].*$") && word.length()>6){
                                                m.put("amount_to_debit~9".toUpperCase(),word);
                                            }
                                            //here we deal with the remaining parts
                                            //System.out.println(word);
                                            break;
                                        default:
                                            break;
                                    }
                                });

                        index.getAndIncrement();
                        //we reorder the map
                        Comparator<String> c=(k1,k2)->Integer.parseInt(k1.split("~")[1]) - Integer.parseInt(k2.split("~")[1]);
                        Map<String,Object> sorted=m.keySet()
                                .stream()
                                .sorted(c)
                                .collect(Collectors.toMap(key->key,key->m.get(key),(key,value)->value,LinkedHashMap::new));
                        sorted.put("process_done",false);
                        ligne.setLigne(sorted);
                        lignes.add(ligne);
                        System.out.println("content of m:\n "+m);
                        System.out.println("\n");
                    });

        }catch (IOException e){
            e.printStackTrace();
        }
        return lignes;
    }

    private List<Line> readXlsx(OPCPackage file) {

        DataFormatter dataFormatter=new DataFormatter();
        List<Line> lignes=new ArrayList<>();
        try {
            XSSFWorkbook workbook = new XSSFWorkbook(file);
            XSSFSheet sheet = workbook.getSheetAt(0);
            XSSFRow row;
            XSSFCell cell;
            Iterator rows = sheet.rowIterator();
            List<String> header=new ArrayList<>();
            while (rows.hasNext()) {
                Line ligne=new Line(new HashMap<>());
                Map<String,Object> lamap=new HashMap<>();
                row = (XSSFRow) rows.next();
                if(row.getRowNum()==0){
                    //here then we have the header row,we create a new Line and append to our list under the key headers
                    Iterator cells = row.cellIterator();
                    while (cells.hasNext()) {
                        cell=(XSSFCell) cells.next();
                        header.add(dataFormatter.formatCellValue(cell));
                        System.out.println(header);
                    }

                }else{
                    //from the second line of the excel doc
                    if(!header.isEmpty()){
                        Iterator cells = row.cellIterator();
                        int index=0;
                        while (cells.hasNext()) {
                            cell=(XSSFCell) cells.next();
                            var i=cell.getColumnIndex();
                            lamap.put(header.get(index).trim().toUpperCase()+"~"+(++i),dataFormatter.formatCellValue(cell));
                            index++;
                        }
                    }
                }
                ligne.setLigne(lamap);
                lignes.add(ligne);

            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return lignes;
    }



    private List<Line> readXls(InputStream file) {
        DataFormatter dataFormatter=new DataFormatter();
        List<Line> lignes=new ArrayList<>();
        try {
            HSSFWorkbook workbook = new HSSFWorkbook(file);
            HSSFSheet sheet = workbook.getSheetAt(0);
            HSSFRow row;
            HSSFCell cell;
            Iterator rows = sheet.rowIterator();
            List<String> header=new ArrayList<>();
            while (rows.hasNext()) {
                Line ligne=new Line(new HashMap<>());
                Map<String,Object> lamap=new HashMap<>();
                row = (HSSFRow) rows.next();
                if(row.getRowNum()==0){
                    //here then we have the header row,we create a new Line and append to our list under the key headers
                    Iterator cells = row.cellIterator();
                    while (cells.hasNext()) {
                        cell=(HSSFCell) cells.next();
                        header.add(dataFormatter.formatCellValue(cell));
                        System.out.println(header);
                    }
                    //adding order to the headers so the Frontend know in which order proceed to the displaying of the file
                    for(int i=1;i<=header.size();i++){
                        header.set(i,header.get(i)+"~"+i);
                    }
                }else{
                    //from the second line of the excel doc
                    if(!header.isEmpty()){
                        Iterator cells = row.cellIterator();
                        int index=0;
                        while (cells.hasNext()) {
                            cell=(HSSFCell) cells.next();
                            lamap.put(header.get(index),dataFormatter.formatCellValue(cell));
                            index++;
                        }
                    }
                }
                ligne.setLigne(lamap);
                lignes.add(ligne);

            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return lignes;
    }
}
