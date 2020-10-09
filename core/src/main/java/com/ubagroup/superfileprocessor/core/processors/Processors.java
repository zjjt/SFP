package com.ubagroup.superfileprocessor.core.processors;

import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.repository.model.Line;
import com.ubagroup.superfileprocessor.core.repository.oracle.Queries;
import com.ubagroup.superfileprocessor.core.utils.OracleDBConfig;
import com.ubagroup.superfileprocessor.core.utils.Utils;
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
import org.json.simple.parser.JSONParser;
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import java.io.*;
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

    public List<ProcessedFile> canalProcessor(List<MultipartFile> files, String userId, String configName, String appmode) {
        List<ProcessedFile> treatedFiles = new ArrayList<>();
        System.out.println("in canal+ processor processing " + files.size() + " files for " + configName + " with userId " + userId);
        files.stream()
                .parallel()
                .forEach((file) -> {
                    //first we create a new instance of processedFile so that we can store the initial filein binary format in mongo
                    ProcessedFile f = new ProcessedFile(null, null, userId, configName, false, false, false, new Date(0), new Date(0), new Date(), null);
                    List<Line> lignesInitiales = readTXT(file, configName);
                    for (var l : lignesInitiales) {
                        l.removeKey("process_done~18");
                        // System.out.println("removing process_done");
                    }
                    //we store then the initial file lines
                    f.setInFile(lignesInitiales);
                    //we get the details from the database and proceed with the direct debit
                    List<Line> lignesProcessing;
                    lignesProcessing = appmode.equalsIgnoreCase("test")||appmode.equalsIgnoreCase("prod")?getSolde(lignesInitiales):getSoldeFromJson(lignesInitiales);
                    try {
                        lignesProcessing = doCanalDebit(lignesProcessing);
                    } catch (CloneNotSupportedException e) {
                        System.out.println("EXCEPTION----");
                        System.out.println("Exception Cause : " + e.getCause());
                        System.out.println("Exception Message : " + e.getMessage());
                        e.printStackTrace();
                    }
                    //we reorder the processing lines based on the initial list
                    lignesProcessing.sort(Comparator.comparing(l->(Integer)l.getLigne().get("LINENO~0")));
                    lignesProcessing.add(0, lignesInitiales.get(0));
                    lignesProcessing.add(lignesInitiales.get(lignesInitiales.size() - 1));
                    //we then update the processing lines
                    f.setFileLines(lignesProcessing);
                    //reconcile with original file
                    List<Line> lignesGenerated = reconcileCanal(lignesProcessing, lignesInitiales);
                    f.setOutFile(lignesGenerated);
                    //if today's date is before to the 25th we set the 25th of the current month
                    //else we set today's date
                    Date dateDebutCron=new GregorianCalendar(Calendar.getInstance().get(Calendar.YEAR),
                            Calendar.getInstance().get(Calendar.MONTH),
                            25).getTime();
                    if(new Date().before(dateDebutCron)){
                        System.out.println("the next execution will run on the 25th of the current month");
                        f.setNextExecution(dateDebutCron);
                    }else{
                        System.out.println("the next execution will run from today "+dateDebutCron);
                        f.setNextExecution(new Date());
                    }

                    treatedFiles.add(f);
                    System.out.println("INITIAL lines " + lignesInitiales.size() + " column count" + lignesInitiales.get(2).getLigne().entrySet().size());
                    System.out.println("PROCESSING lines " + lignesProcessing.size() + " column count" + lignesProcessing.get(2).getLigne().entrySet().size());
                    System.out.println("GENERATED lines " + lignesGenerated.size() + " column count" + lignesGenerated.get(2).getLigne().entrySet().size());


                });
        return treatedFiles;
    }

    //this method processes an Excel file list via multithreading

    public List<ProcessedFile> sageProcessor(List<MultipartFile> files, String userId, String configName, String appmode) {
        List<ProcessedFile> treatedFiles = new ArrayList<>();
        System.out.println("in sage processor processing " + files.size() + " files for " + configName + " with userId " + userId);
        files.stream()
                .parallel()
                .forEach((file) -> {
                    //first we create a new instance of processedFile so that we can store the initial file in binary format in mongo
                    ProcessedFile f = new ProcessedFile(null, null, userId, configName, false, false, false, new Date(0), new Date(0), new Date(0), null);

                    try {
                        System.out.println("original filename is " + file.getOriginalFilename());
                        List<Line> lignes = readCSV(file,configName);
                        f.setInFile(lignes);
                        //now we process the different lines to apply fincon transforms
                        f.setFileLines(processSage(lignes));
                        f.setOutFile(processSage(lignes));
                        f.setProcessingStatus(true);
                        f.setDateProcessed(new Date());
                        treatedFiles.add(f);
                    } catch ( Exception e) {
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

    public List<Line> getSoldeFromJson(List<Line> lignesDuFichier) {
        System.out.println("Traitement a partir de JSON MOCK DATA");
        List<Line> newList = new ArrayList<>();
        //1- we get the statuses of the accounts
        //2- we store it in memory
        //3 we proceed to debit and update the debited account immediately with the solde
        JSONParser parser=new JSONParser();
        try {
            String jsonData="{\"rows\":\n" +
                    "[\n" +
                    "{\"foracid\":\"101010002896\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"M\\/MME NIAMIEN JEAN CLAUDE\",\"schm_code\":\"CAC01\",\"solde\":9363331,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010005626\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"TANOH MICHEL\",\"schm_code\":\"CAC01\",\"solde\":920733,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010006883\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"DIARRA DRAMANE\",\"schm_code\":\"CAC01\",\"solde\":148790,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010012172\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"AKUE COME ADOVI\",\"schm_code\":\"CAC01\",\"solde\":576009,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010019355\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"WODJE LOUIS TEHOUA PRIVAT\",\"schm_code\":\"CAC01\",\"solde\":706983,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010019386\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"BOGUIFO AURELIA CLAUDE DESIRE NESSA\",\"schm_code\":\"CACDB\",\"solde\":-5185,\"acct_status\":\"A\",\"schm_desc\":\"CREANCES DOUTEUSES OU LI\"},\n" +
                    "{\"foracid\":\"101010029231\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"TOURE AMINATA\",\"schm_code\":\"CAC01\",\"solde\":211740,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010032026\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"GUEYE MONIQUE EPSE OBRE\",\"schm_code\":\"CAC01\",\"solde\":2695728,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010032613\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"BROU ASSOUA DIDIER HERVE\",\"schm_code\":\"CAC01\",\"solde\":691334,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010033221\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"KOUAME KOUASSI  LETONDAL\",\"schm_code\":\"CAC01\",\"solde\":69135,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010035881\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"KOUAKOU AFFOUA\",\"schm_code\":\"CACDB\",\"solde\":-5504,\"acct_status\":\"A\",\"schm_desc\":\"CREANCES DOUTEUSES OU LI\"},\n" +
                    "{\"foracid\":\"101010037267\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"LOUA ROJAS\",\"schm_code\":\"CAC01\",\"solde\":110666,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101010037908\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"KONE CHEICK MOHAMED ABDEL KADER\",\"schm_code\":\"CAC01\",\"solde\":9900,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101020000017\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"ASSOUA SANDRINE KOUAME\",\"schm_code\":\"CAC02\",\"solde\":1692040,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PERSONNEL\"},\n" +
                    "{\"foracid\":\"101020000299\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"AKA ASSOMAN GILBERT\",\"schm_code\":\"CAC02\",\"solde\":804842,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PERSONNEL\"},\n" +
                    "{\"foracid\":\"101070000294\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"CABINET THEODORE HOEGAH\",\"schm_code\":\"CAC07\",\"solde\":3631198,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE ENT.INDIV.\"},\n" +
                    "{\"foracid\":\"101070002685\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"ETUDE DE MAITRE KOUAKOU LILIANE SAINT PIERRE\",\"schm_code\":\"CAC07\",\"solde\":1002764017,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE ENT.INDIV.\"},\n" +
                    "{\"foracid\":\"101070003736\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"EREF-CI\",\"schm_code\":\"CAC07\",\"solde\":3690089,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE ENT.INDIV.\"},\n" +
                    "{\"foracid\":\"101070004850\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"PRESTIGE LOCATION DE VOITURE\",\"schm_code\":\"CAC07\",\"solde\":655949,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE ENT.INDIV.\"},\n" +
                    "{\"foracid\":\"101090003110\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"MSTB-CI (MULTI SERVICES TECHNIQUES ET BUREAUTIQUES EN CI)\",\"schm_code\":\"CAC09\",\"solde\":6187782,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE SA & SARL\"},\n" +
                    "{\"foracid\":\"101090005604\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"ASSUREUR CONSEIL ARMOO\",\"schm_code\":\"CAC34\",\"solde\":27630,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE ENT.SARL & SAS-FTC\"},\n" +
                    "{\"foracid\":\"101090006065\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"INTELLIGENCE\",\"schm_code\":\"CAC09\",\"solde\":14910794,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE SA & SARL\"},\n" +
                    "{\"foracid\":\"101200000066\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"SAM LAURENT-SAMUEL\",\"schm_code\":\"CAC01\",\"solde\":4171238,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PARICULIER\"},\n" +
                    "{\"foracid\":\"101200000330\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"KOUAKOU KOUABENAN ADJEHI JULIEN\",\"schm_code\":\"CAC20\",\"solde\":83425,\"acct_status\":\"A\",\"schm_desc\":\"CAC20 INDIV. FTC 2000XOF\"},\n" +
                    "{\"foracid\":\"101210000036\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"OUEDRAOGO SALIF ISSA\",\"schm_code\":\"CAC21\",\"solde\":1504894,\"acct_status\":\"A\",\"schm_desc\":\"CAC21 INDIV.FTC 2500 XOF\"},\n" +
                    "{\"foracid\":\"102630000396\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"SIDIBE DJINABOU ALIDA NADEGE\",\"schm_code\":\"SAC63\",\"solde\":110359,\"acct_status\":\"A\",\"schm_desc\":\"COMPTE XPARGNE UBA LIBER\"},\n" +
                    "{\"foracid\":\"299020000408\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"THOMPSON SOLANGE\",\"schm_code\":\"CAC02\",\"solde\":135115,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PERSONNEL\"},\n" +
                    "{\"foracid\":\"299020000590\",\"frez_code\":\" \",\"frez_reason_code\":null,\"acc_close_date\":null,\"acct_name\":\"BAKARE LATIF\",\"schm_code\":\"CAC02\",\"solde\":508112,\"acct_status\":\"A\",\"schm_desc\":\"CPTE ORDINAIRE PERSONNEL\"}\n" +
                    "]}";
            Object obj= parser.parse(jsonData);
            JSONObject jsonObject=(JSONObject)obj;
            JSONArray rows=(JSONArray) jsonObject.get("rows");
            for(int index=0;index<rows.size();index++){
                for (int i = 0; i < lignesDuFichier.size(); i++) {
                    //we purposely skip the first and last line
                    if (i == 0 || i == lignesDuFichier.size() - 1) {
                        continue;
                    }
                    var laligne = lignesDuFichier.get(i).clone();
                    JSONObject json=(JSONObject)rows.get(index);
                    if (laligne.getLigne().get("ACCOUNT~4").equals(json.get("foracid"))) {
                       // System.out.println(laligne.getLigne().get("CUSTOMER_NAME~5") + "--" + json.get("foracid") + "--" + i);
                        laligne.getLigne().put("LINENO~0", i);
                        laligne.getLigne().put("ACCT_STATUS~11", json.get("acct_status"));
                        laligne.getLigne().put("BALANCE~12", json.get("solde"));
                        laligne.getLigne().put("FREEZECODE~13", json.get("frez_code"));
                        laligne.getLigne().put("FREEZEREASON~14", json.get("frez_reason_code"));
                        laligne.getLigne().put("ACCOUNTCLOSEDATE~15", json.get("acc_close_date"));
                        laligne.getLigne().put("SCHM_CODE~16", json.get("schm_code"));
                        laligne.getLigne().put("SCHM_DESC~17", json.get("schm_desc"));
                        newList.add(laligne);

                    }
                    // System.out.println("index "+i);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            System.out.println("newList is " + newList.size());
        }


        return newList;
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

        //we remove canal account from the list of account
        listAccount.remove(0);


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
                        laligne.getLigne().put("LINENO~0", i);
                        laligne.getLigne().put("ACCT_STATUS~11", rs.getString("ACCT_STATUS"));
                        laligne.getLigne().put("BALANCE~12", rs.getString("SOLDE"));
                        laligne.getLigne().put("FREEZECODE~13", rs.getString("FREZ_CODE"));
                        laligne.getLigne().put("FREEZEREASON~14", rs.getString("FREZ_REASON_CODE"));
                        laligne.getLigne().put("ACCOUNTCLOSEDATE~15", rs.getString("account_close_date"));
                        laligne.getLigne().put("SCHM_CODE~16", rs.getString("SCHM_CODE"));
                        laligne.getLigne().put("SCHM_DESC~17", rs.getString("SCHM_DESC"));
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

            if (processingLines.get(i).getLigne().get("ACCT_STATUS~11").equals("A")
                    || processingLines.get(i).getLigne().get("ACCT_STATUS~11").equals("I")) {

                int amountToDebit = Integer.parseInt(processingLines.get(i).getLigne().get("AMOUNT_TO_DEBIT~9").toString().trim());
                int currentBalance = Integer.parseInt(processingLines.get(i).getLigne().get("BALANCE~12").toString().trim());
                System.out.println("solde: " + currentBalance + "\n debiter " + amountToDebit + "\n solde>debit ?" + (currentBalance >= amountToDebit));
                //System.out.println(processingLines.get(i).getLigne().get("FREEZECODE~12").toString().isBlank());
                if (currentBalance >= amountToDebit
                        && processingLines.get(i).getLigne().get("FREEZECODE~13").toString().isBlank()
                        && processingLines.get(i).getLigne().get("FREEZEREASON~14") == null
                        && processingLines.get(i).getLigne().get("ACCOUNTCLOSEDATE~15") == null
                ) {

                    if (processingLines.get(i).getLigne().containsKey("process_done~18")
                            && processingLines.get(i).getLigne().get("process_done~18").toString().equalsIgnoreCase("false")
                            && !processingLines.get(i).getLigne().get("status_code~19").toString().equalsIgnoreCase("00")
                    ) {
                        System.out.println("we debit");
                        processingLines.get(i).getLigne().put("process_done~18", true);
                        processingLines.get(i).getLigne().put("status_code~19", "00");
                    } else {
                        System.out.println("we debit");
                        processingLines.get(i).getLigne().put("process_done~18", true);
                        processingLines.get(i).getLigne().put("status_code~19", "00");
                    }

                } else {
                    if (processingLines.get(i).getLigne().get("ACCOUNTCLOSEDATE~15") != null) {
                        System.out.println("we cant debit");
                        processingLines.get(i).getLigne().put("process_done~18", false);
                        processingLines.get(i).getLigne().put("status_code~19", "04");
                    } else {
                        System.out.println("we cant debit");
                        processingLines.get(i).getLigne().put("process_done~18", false);
                        processingLines.get(i).getLigne().put("status_code~19", "06");
                    }
                }
            } else {
                System.out.println("we cant debit account isnt active " + processingLines.get(i).getLigne().get("ACCT_STATUS~10"));
                processingLines.get(i).getLigne().put("process_done~18", false);
                processingLines.get(i).getLigne().put("status_code~19", "06");

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
                                        + afterDebit.get(index).getLigne().get("status_code~19"));
                    }
                    var m = done.get(index).getLigne();
                    done.get(index).setLigne(sortedLines(m));
                });

        return done;
    }

    //#########   SAGE processing
    private List<Line> processSage(List<Line> lines){
        System.out.println("Sagefile processing from FINCON journal data");
        List<Line> newList = new ArrayList<>();
        //1- we get the statuses of the accounts
        //2- we store it in memory
        //3 we proceed to debit and update the debited account immediately with the solde
        JSONParser parser=new JSONParser();
        try {
            String jsonData = "{\n" +
                    "    \"rows\": [\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64110\",\n" +
                    "            \"CODE_LP\": \"52\",\n" +
                    "            \"COMPTE_FINCON\": \"6411009526299006\",\n" +
                    "            \"LABEL\": \"AVANTAGES NATURE ENSEMBLE DU PERSONNEL\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64111\",\n" +
                    "            \"CODE_LP\": \"+10\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299001\",\n" +
                    "            \"LABEL\": \"salaire de base\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64112\",\n" +
                    "            \"CODE_LP\": \"+20/+40/+151/+684/+777/+778\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299009\",\n" +
                    "            \"LABEL\": \"sursalaire\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"641131\",\n" +
                    "            \"CODE_LP\": \"+76/+89/-644/+694\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299006\",\n" +
                    "            \"LABEL\": \"idemnité eau/élect/tél\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"641132\",\n" +
                    "            \"CODE_LP\": \"+88\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299002\",\n" +
                    "            \"LABEL\": \"indemnité de logement\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64114\",\n" +
                    "            \"CODE_LP\": \"+686\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299017\",\n" +
                    "            \"LABEL\": \"indemnité de fonction non imposable\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64115\",\n" +
                    "            \"CODE_LP\": \"NA\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299003\",\n" +
                    "            \"LABEL\": \"PRIMES DE SCOLARITE\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64116\",\n" +
                    "            \"CODE_LP\": \"+612\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299004\",\n" +
                    "            \"LABEL\": \"prime de transport non imposable\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"641171\",\n" +
                    "            \"CODE_LP\": \"+788\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299004\",\n" +
                    "            \"LABEL\": \"indemnité de transport /véhicule imposable\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"641172\",\n" +
                    "            \"CODE_LP\": \"+108\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299004\",\n" +
                    "            \"LABEL\": \"indemnité de carburant\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64118\",\n" +
                    "            \"CODE_LP\": \"+102/+119\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299008\",\n" +
                    "            \"LABEL\": \"gratification 13è mois\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64120\",\n" +
                    "            \"CODE_LP\": \"+160\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299006\",\n" +
                    "            \"LABEL\": \"autres indemnités\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64121\",\n" +
                    "            \"CODE_LP\": \"+47/+64/+66/+68/+132\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299006\",\n" +
                    "            \"LABEL\": \"autres primes\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64123\",\n" +
                    "            \"CODE_LP\": \"+41/+42/+43/+44\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299009\",\n" +
                    "            \"LABEL\": \"heures supplémentaires\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64125\",\n" +
                    "            \"CODE_LP\": \"+793/+794\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299007\",\n" +
                    "            \"LABEL\": \"congés payés\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"64126\",\n" +
                    "            \"CODE_LP\": \"-3800  /+ 3802\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299017\",\n" +
                    "            \"LABEL\": \"arrondi de paie\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"6421\",\n" +
                    "            \"CODE_LP\": \"+280/+285/+286\",\n" +
                    "            \"COMPTE_FINCON\": \"6420009526299001\",\n" +
                    "            \"LABEL\": \"charges sociales/cnps\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"641129\",\n" +
                    "            \"CODE_LP\": \"+155/+157/+159\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299020\",\n" +
                    "            \"LABEL\": \"séparations imposables\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"641130\",\n" +
                    "            \"CODE_LP\": \"+640/+650\",\n" +
                    "            \"COMPTE_FINCON\": \"6410009526299021\",\n" +
                    "            \"LABEL\": \"séparation non imposables\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"642000\",\n" +
                    "            \"CODE_LP\": \"+776\",\n" +
                    "            \"COMPTE_FINCON\": \"6420009526299002\",\n" +
                    "            \"LABEL\": \"cotisation crrae\"\n" +
                    "        },\n" +
                    "        {\n" +
                    "            \"COMPTE_LP\": \"63111\",\n" +
                    "            \"CODE_LP\": \"+210/+282/+283/+284\",\n" +
                    "            \"COMPTE_FINCON\": \"6311009526299001\",\n" +
                    "            \"LABEL\": \"charges patronales\"\n" +
                    "        }\n" +
                    "    ]\n" +
                    "}";
            Object obj = parser.parse(jsonData);
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray rows = (JSONArray) jsonObject.get("rows");
            for(int index=0;index<rows.size();index++){
                for(int i=0;i<lines.size();i++){
                    if(i==0) continue;
                    JSONObject json=(JSONObject) rows.get(index);
                    Map<String,Object>m=new HashMap<>();
                    if(lines.get(i).getLigne().get("COMPTE_LP~4").equals(json.get("COMPTE_LP"))
                            &&(!lines.get(i).getLigne().get("STATUS~5").equals("")
                            && !lines.get(i).getLigne().get("ENCODAGE~6").equals("")) ){
                        //we have found the account in the journal we get
                        m.put("LINENO~0",Integer.toString(i));
                        m.put("NAME~1",json.get("LABEL"));
                        m.put("ACCOUNT_NO~2",json.get("COMPTE_FINCON"));
                        m.put("AMOUNT~3",lines.get(i).getLigne().get("MONTANT~11"));
                        m.put("NARRATION~4", Utils.getCurrentMonth()+Calendar.getInstance().get(Calendar.YEAR)+"SALARY");
                        m.put("sol_id~5","");
                        m.put("TRAN_TYPE~6",lines.get(i).getLigne().get("OP_FINCON~10"));
                        m.put("currency~7","");
                        m.put("report_code~8",lines.get(i).getLigne().get("ENCODAGE~6"));
                        newList.add(new Line(sortedLines(m)));
                    }
                }
            }
        }catch (Exception e){
            e.printStackTrace();
        }

        return newList;
    }

    private List<Line> readCSV(MultipartFile file,String configName){
        List<Line> lignes = new ArrayList<>();
        try(var theCSV = new BufferedReader(new InputStreamReader(file.getInputStream()));
            var reader= new CSVReader(theCSV)) {
          String[] nextLine;
          int i=0;
          while((nextLine=reader.readNext())!=null){
              for(var e:nextLine){
                  Map<String,Object> m=new HashMap<>();
                  switch(configName){
                      case "SAGE":
                          if(!e.contains(";")){
                              //we are on the first line
                              m.put("LINENO~0",Integer.toString(i));
                              m.put("CODESAGE~1",e.replaceAll("\"","").trim());
                              lignes.add(new Line(sortedLines(m)));
                          }else{
                              //we are on the other lines
                              m.put("LINENO~0",Integer.toString(i));
                              String[] elements=e.split(";");
                              for(int j=0;j<elements.length;j++){
                               switch(j){
                                   case 0:
                                       m.put("CODESAGE~1",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 1:
                                       m.put("CODEOP~2",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 2:
                                       m.put("OP_SAGE~3",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 3:
                                       m.put("COMPTE_LP~4",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 4:
                                       m.put("STATUS~5",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 5:
                                       m.put("ENCODAGE~6",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 6:
                                       m.put("OP_PERIOD~7",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 7:
                                       m.put("LABEL_OP~8",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 8:
                                       m.put("S~9",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 9:
                                       m.put("OP_FINCON~10",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 10:
                                       m.put("MONTANT~11",elements[j].replaceAll("\"","").trim());
                                       break;
                                   case 11:
                                       m.put("CODE_FIN~12",elements[j].replaceAll("\"","").trim());
                                       break;
                               }
                              }
                              lignes.add(new Line(sortedLines(m)));
                          }
                          break;
                      default:
                          break;
                  }

              }
              i++;
          }
        }catch (IOException | CsvValidationException e){
            e.printStackTrace();

        }
        return lignes;
    }
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

    public static Map<String, Object> sortedLines(Map<String, Object> m) {
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
