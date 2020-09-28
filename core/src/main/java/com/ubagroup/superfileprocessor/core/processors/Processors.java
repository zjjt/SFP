package com.ubagroup.superfileprocessor.core.processors;

import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.repository.model.Line;
import com.ubagroup.superfileprocessor.core.repository.oracle.Queries;
import com.ubagroup.superfileprocessor.core.utils.OracleDBConfig;
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
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.*;
import java.util.*;
import java.util.Date;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * Processors are methods paired with the actual processing configuration parametrized to handle the file processings
 * this class methods should all be suffixed with  "Processor" so that java's reflection mechanism can find the right
 * processor for the files uploaded
 */
public class Processors {

    public List<ProcessedFile> canalProcessor(List<MultipartFile> files, String userId, String configName) {
        List<ProcessedFile> treatedFiles = new ArrayList<>();
        System.out.println("in canal+ processor processing " + files.size() + " files for " + configName + " with userId " + userId);
        files.stream()
                .parallel()
                .forEach((file) -> {
                    //first we create a new instance of processedFile so that we can store the initial filein binary format in mongo
                    ProcessedFile f = new ProcessedFile(null, null, userId, configName, false, false, new Date(0), new Date(0), new Date(), null);
                    List<Line> lignesInitiales = readTXT(file, configName);
                    for (var l : lignesInitiales) {
                        l.removeKey("process_done~17");
                        // System.out.println("removing process_done");
                    }
                    //we store then the initial file lines
                    f.setInFile(lignesInitiales);
                    //we get the details from the database and proceed with the direct debit
                    List<Line> lignesProcessing;
                    lignesProcessing = getSolde(lignesInitiales);
                    try {
                        lignesProcessing = doCanalDebit(lignesProcessing);
                    } catch (CloneNotSupportedException e) {
                        System.out.println("EXCEPTION----");
                        System.out.println("Exception Cause : " + e.getCause());
                        System.out.println("Exception Message : " + e.getMessage());
                        e.printStackTrace();
                    }
                    lignesProcessing.add(0, lignesInitiales.get(0));
                    lignesProcessing.add(lignesInitiales.get(lignesInitiales.size() - 1));
                    //we then update the processing lines
                    f.setFileLines(lignesProcessing);
                    //#TODO reconcile with original file
                    List<Line> lignesGenerated = reconcileCanal(lignesProcessing, lignesInitiales);
                    f.setOutFile(lignesGenerated);
                    treatedFiles.add(f);
                    System.out.println("INITIAL lines " + lignesInitiales.size() + " column count" + lignesInitiales.get(2).getLigne().entrySet().size());
                    System.out.println("PROCESSING lines " + lignesProcessing.size() + " column count" + lignesProcessing.get(2).getLigne().entrySet().size());
                    System.out.println("GENERATED lines " + lignesGenerated.size() + " column count" + lignesGenerated.get(2).getLigne().entrySet().size());


                });
        return treatedFiles;
    }

    //this method processes an Excel file list via multithreading

    public List<ProcessedFile> sageProcessor(List<MultipartFile> files, String userId, String configName) {
        List<ProcessedFile> treatedFiles = new ArrayList<>();
        System.out.println("in sage processor processing " + files.size() + " files for " + configName + " with userId " + userId);
        files.stream()
                .parallel()
                .forEach((file) -> {
                    //first we create a new instance of processedFile so that we can store the initial file in binary format in mongo
                    ProcessedFile f = new ProcessedFile(null, null, userId, configName, false, false, new Date(0), new Date(0), new Date(0), null);

                    try {
                        System.out.println("original filename is " + file.getOriginalFilename());
                        List<Line> lignes = readXlsx(OPCPackage.open(file.getInputStream()));
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
        List<Line> lignes = new ArrayList<>();
        try {
            List<String> theTXT = new BufferedReader(new InputStreamReader(file.getInputStream())).lines().collect(Collectors.toList());
            AtomicInteger index = new AtomicInteger();
            theTXT.parallelStream()
                    .map(line -> line.split("\\s+"))//split line into individual words
                    .parallel()
                    .forEachOrdered(lineArr -> {
                        Line ligne = new Line(new HashMap<>());
                        Map<String, Object> m = new TreeMap<>();
                        Arrays.stream(lineArr)
                                .parallel()
                                .forEachOrdered(word -> {
                                    // System.out.println("word is "+word);
                                    switch (configName) {
                                        case "CANAL":
                                            //here we check that we are on the last line
                                            if (index.get() == theTXT.size() - 1) {
                                                // System.out.println("on the last line of the file "+word);
                                                if (!m.containsKey("lastline".toUpperCase())) {
                                                    m.put("lastline".toUpperCase(), word);
                                                } else {
                                                    //   System.out.println("lastline already exist so"+m.get("lastline".toUpperCase())+"\t"+word);
                                                    m.put("lastline".toUpperCase(), m.get("lastline".toUpperCase()) + "\t" + word);
                                                }

                                                return;
                                            }
                                            if (word.matches("^[0-9].*[a-zA-Z].*+$")) {
                                                // we get the first part and here we split it between the first part
                                                // and the name

                                                var nameStart = word.replaceAll("\\d", "");
                                                var firstNoPart = word.replaceAll("[A-Z]", "");
                                                firstNoPart = firstNoPart.replaceAll("\\+", "");
                                                //System.out.println("nameStart "+nameStart+"\n firstnumpart "+firstNoPart);
                                                m.put("inc~1".toUpperCase(), firstNoPart.substring(0, 6));
                                                m.put("date_debit~2".toUpperCase(), firstNoPart.substring(8, 14));
                                                m.put("bank_code~3".toUpperCase(), firstNoPart.substring(14, 22));
                                                m.put("account~4".toUpperCase(), firstNoPart.substring(nameStart.contentEquals("CANAL+") ? 23 : 22));
                                                m.put("customer_name~5".toUpperCase(), nameStart);
                                                return;
                                            }
                                            //check if we are dealing with customer's other's name so we can update the map
                                            //if not it then its the UBA label
                                            if (word.matches("^[a-zA-Z]*$") || word.contains("-")) {
                                                // System.out.println("the word is"+word);
                                                if (word.contains("UBA") && !word.contentEquals("UBA")) {
                                                    var lastname = word.replaceAll("UBA", "");
                                                    m.put("customer_name~5".toUpperCase(), m.get("customer_name~5".toUpperCase()) + " " + lastname);
                                                    m.put("uba_bank~6".toUpperCase(), "UBA");
                                                    // System.out.println("name is mixed with UBA for "+m.get("customer_name~5".toUpperCase()));
                                                    return;
                                                }
                                                if (word.contentEquals("UBA")) {
                                                    m.put("uba_bank~6".toUpperCase(), word);
                                                    return;
                                                }
                                                m.put("customer_name~5".toUpperCase(), m.get("customer_name~5".toUpperCase()) + " " + word);
                                            }
                                            //storing canalreference
                                            if (word.matches("^[A-Z].*[0-9]$") && word.contains("CANAL")) {
                                                m.put("canal_ref~7".toUpperCase(), word);
                                            }
                                            //storing the date_payment
                                            if (word.matches("^[0-9].*$") && word.length() == 6) {
                                                m.put("date_pay~8".toUpperCase(), word);
                                            }
                                            //storing the amount
                                            if (word.matches("^[0-9].*$") && word.length() > 6) {
                                                m.put("amount_to_debit~9".toUpperCase(), word);
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
                        ligne.setLigne(sortedLines(m));
                        lignes.add(ligne);
                        // System.out.println("content of m:\n "+m);
                        // System.out.println("\n");
                    });

        } catch (IOException e) {
            e.printStackTrace();
        }
        return lignes;
    }

    public List<Line> getSolde(List<Line> lignesDuFichier) {
        List<Line> newList = new ArrayList<>();
        //1- we get the statuses of the accounts
        //2- we store it in memory
        //3 we proceed to debit and update the debited account immediately with the solde
        var listAccount = lignesDuFichier.stream()
                .parallel()
                .flatMap(line -> line.getLigne().entrySet().parallelStream())
                .filter(l -> l.getKey().equalsIgnoreCase("ACCOUNT~4"))
                .map(Map.Entry::getValue)
                .collect(Collectors.toList());


        try (Connection connection = DriverManager.getConnection(OracleDBConfig.URL,
                OracleDBConfig.USER,
                OracleDBConfig.PASSWORD);
             Statement st = connection.createStatement();
        ) {
            System.out.println("in here trying to execute sql");
            Class.forName(OracleDBConfig.ORACLE_DRIVER);
            ResultSet rs = st.executeQuery(Queries.getAccountStatus(listAccount));

            while (rs.next()) {
                //System.out.println("length of lines for sql read "+lignesDuFichier.size());
                for (int i = 0; i < lignesDuFichier.size(); i++) {
                    //we purposely skip the first and last line
                    if (i == 0 || i == lignesDuFichier.size() - 1) {
                        continue;
                    }
                    var laligne = lignesDuFichier.get(i).clone();
                    if (laligne.getLigne().get("ACCOUNT~4").equals(rs.getString("FORACID"))) {
                        //System.out.println(laligne.get("CUSTOMER_NAME~5") + "--" + rs.getString("FORACID") + "--" + i);
                        laligne.getLigne().put("ACCT_STATUS~10", rs.getString("ACCT_STATUS"));
                        laligne.getLigne().put("BALANCE~11", rs.getString("SOLDE"));
                        laligne.getLigne().put("FREEZECODE~12", rs.getString("FREZ_CODE"));
                        laligne.getLigne().put("FREEZEREASON~13", rs.getString("FREZ_REASON_CODE"));
                        laligne.getLigne().put("ACCOUNTCLOSEDATE~14", rs.getString("account_close_date"));
                        laligne.getLigne().put("SCHM_CODE~15", rs.getString("SCHM_CODE"));
                        laligne.getLigne().put("SCHM_DESC~16", rs.getString("SCHM_DESC"));
                        newList.add(laligne);

                    }
                    // System.out.println("index "+i);
                }
            }
            if (rs != null) {
                rs.close();
            }
        } catch (ClassNotFoundException | SQLException | CloneNotSupportedException e) {
            System.out.println("EXCEPTION----");
            System.out.println("Exception Cause : " + e.getCause());
            System.out.println("Exception Message : " + e.getMessage());
            e.printStackTrace();
        } finally {
            System.out.println("newList is " + newList.size());
        }
        return newList;
    }

    public List<Line> doCanalDebit(List<Line> processingLines) throws CloneNotSupportedException {
        for (int i = 0; i < processingLines.size(); i++) {
            System.out.println("length of lines is " + processingLines.size());
            //we purposely skip the first and last line
            System.out.println("index is " + i + "\n" + processingLines.get(i).getLigne());

            if (processingLines.get(i).getLigne().get("ACCT_STATUS~10").equals("A")
                    || processingLines.get(i).getLigne().get("ACCT_STATUS~10").equals("I")) {

                int amountToDebit = Integer.parseInt(processingLines.get(i).getLigne().get("AMOUNT_TO_DEBIT~9").toString().trim());
                int currentBalance = Integer.parseInt(processingLines.get(i).getLigne().get("BALANCE~11").toString().trim());
                System.out.println("solde: " + currentBalance + "\n debiter " + amountToDebit + "\n solde>debit ?" + (currentBalance >= amountToDebit));
                //System.out.println(processingLines.get(i).getLigne().get("FREEZECODE~12").toString().isBlank());
                if (currentBalance >= amountToDebit
                        && processingLines.get(i).getLigne().get("FREEZECODE~12").toString().isBlank()
                        && processingLines.get(i).getLigne().get("FREEZEREASON~13") == null
                        && processingLines.get(i).getLigne().get("ACCOUNTCLOSEDATE~14") == null
                ) {

                    if (processingLines.get(i).getLigne().containsKey("process_done~17")
                            && processingLines.get(i).getLigne().get("process_done~17").toString().equalsIgnoreCase("false")
                            && !processingLines.get(i).getLigne().get("status_code~18").toString().equalsIgnoreCase("00")
                    ) {
                        System.out.println("we debit");
                        processingLines.get(i).getLigne().put("process_done~17", true);
                        processingLines.get(i).getLigne().put("status_code~18", "00");
                    }else{
                        System.out.println("we debit");
                        processingLines.get(i).getLigne().put("process_done~17", true);
                        processingLines.get(i).getLigne().put("status_code~18", "00");
                    }

                } else {
                    if (processingLines.get(i).getLigne().get("ACCOUNTCLOSEDATE~14") != null) {
                        System.out.println("we cant debit");
                        processingLines.get(i).getLigne().put("process_done~17", false);
                        processingLines.get(i).getLigne().put("status_code~18", "04");
                    } else {
                        System.out.println("we cant debit");
                        processingLines.get(i).getLigne().put("process_done~17", false);
                        processingLines.get(i).getLigne().put("status_code~18", "06");
                    }
                }
            } else {
                System.out.println("we cant debit account isnt active " + processingLines.get(i).getLigne().get("ACCT_STATUS~10"));
                processingLines.get(i).getLigne().put("process_done~17", false);
                processingLines.get(i).getLigne().put("status_code~18", "06");

            }
            //we reorder the map
            var m = processingLines.get(i).clone();
            var sorted = sortedLines(m.getLigne());
            System.out.println("sorted " + sorted);
            processingLines.get(i).setLigne(sorted);
        }
        return processingLines;
    }

    public List<Line> reconcileCanal(List<Line> afterDebit, List<Line> initialLines) {
        List<Line> done = new ArrayList<>();
        initialLines.stream()
                .forEachOrdered(line -> {
                    try {
                        done.add(line.clone());
                    } catch (CloneNotSupportedException e) {
                        e.printStackTrace();
                    }
                });
        IntStream.range(0, afterDebit.size())
                .parallel()
                .forEachOrdered(index -> {
                    System.out.println("index " + index);
                    if (index != 0 && index != afterDebit.size() - 1) {
                        done.get(index).getLigne().put("AMOUNT_TO_DEBIT~9",
                                done.get(index).getLigne().get("AMOUNT_TO_DEBIT~9").toString()
                                        + afterDebit.get(index).getLigne().get("status_code~18"));
                    }
                    var m = done.get(index).getLigne();
                    done.get(index).setLigne(sortedLines(m));
                });

        return done;
    }

    //#########   SAGE processing
    private List<Line> readXlsx(OPCPackage file) {

        DataFormatter dataFormatter = new DataFormatter();
        List<Line> lignes = new ArrayList<>();
        try {
            XSSFWorkbook workbook = new XSSFWorkbook(file);
            XSSFSheet sheet = workbook.getSheetAt(0);
            XSSFRow row;
            XSSFCell cell;
            Iterator rows = sheet.rowIterator();
            List<String> header = new ArrayList<>();
            while (rows.hasNext()) {
                Line ligne = new Line(new HashMap<>());
                Map<String, Object> lamap = new HashMap<>();
                row = (XSSFRow) rows.next();
                if (row.getRowNum() == 0) {
                    //here then we have the header row,we create a new Line and append to our list under the key headers
                    Iterator cells = row.cellIterator();
                    while (cells.hasNext()) {
                        cell = (XSSFCell) cells.next();
                        header.add(dataFormatter.formatCellValue(cell));
                        System.out.println(header);
                    }

                } else {
                    //from the second line of the excel doc
                    if (!header.isEmpty()) {
                        Iterator cells = row.cellIterator();
                        int index = 0;
                        while (cells.hasNext()) {
                            cell = (XSSFCell) cells.next();
                            var i = cell.getColumnIndex();
                            lamap.put(header.get(index).trim().toUpperCase() + "~" + (++i), dataFormatter.formatCellValue(cell));
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
        DataFormatter dataFormatter = new DataFormatter();
        List<Line> lignes = new ArrayList<>();
        try {
            HSSFWorkbook workbook = new HSSFWorkbook(file);
            HSSFSheet sheet = workbook.getSheetAt(0);
            HSSFRow row;
            HSSFCell cell;
            Iterator rows = sheet.rowIterator();
            List<String> header = new ArrayList<>();
            while (rows.hasNext()) {
                Line ligne = new Line(new HashMap<>());
                Map<String, Object> lamap = new HashMap<>();
                row = (HSSFRow) rows.next();
                if (row.getRowNum() == 0) {
                    //here then we have the header row,we create a new Line and append to our list under the key headers
                    Iterator cells = row.cellIterator();
                    while (cells.hasNext()) {
                        cell = (HSSFCell) cells.next();
                        header.add(dataFormatter.formatCellValue(cell));
                        System.out.println(header);
                    }
                    //adding order to the headers so the Frontend know in which order proceed to the displaying of the file
                    for (int i = 1; i <= header.size(); i++) {
                        header.set(i, header.get(i) + "~" + i);
                    }
                } else {
                    //from the second line of the excel doc
                    if (!header.isEmpty()) {
                        Iterator cells = row.cellIterator();
                        int index = 0;
                        while (cells.hasNext()) {
                            cell = (HSSFCell) cells.next();
                            lamap.put(header.get(index), dataFormatter.formatCellValue(cell));
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

    private Map<String, Object> sortedLines(Map<String, Object> m) {
        Comparator<String> c = Comparator.comparingInt(k -> Integer.parseInt(k.split("~")[1]));
        Map<String, Object> sorted = m.keySet()
                .stream()
                .sorted(c)
                .collect(Collectors.toMap(key -> key, key -> m.get(key) != null ? m.get(key) : ""
                        , (key, value) -> value
                        , LinkedHashMap::new));
        return sorted;
    }
}
