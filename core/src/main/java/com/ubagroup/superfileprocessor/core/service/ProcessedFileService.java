package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.ProcessConfig;
import com.ubagroup.superfileprocessor.core.entity.ProcessedFile;
import com.ubagroup.superfileprocessor.core.processors.Processors;
import com.ubagroup.superfileprocessor.core.repository.model.Line;
import com.ubagroup.superfileprocessor.core.repository.mongodb.ProcessedFileRepository;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ProcessedFileService implements ProcessedFileInterface {
    @Autowired
    private ProcessedFileRepository processedFileRepository;
    @Autowired
    private ProcessConfigService processConfigService;

    @Override
    public List<ProcessedFile> getAll(boolean between, boolean byDate, boolean treated,
                                      boolean processingStatus, Date one, Date two, Date when, String userId, String configName,String fileId)
            throws IllegalArgumentException {
        if (between) {
            //we check between a period
            if (userId.isEmpty() || configName.isEmpty()) {
                if (one == null || two == null) {
                    throw new IllegalArgumentException("you have to enter a period to search in between");
                }
                return processedFileRepository.findByDateProcessedBetween(one, two);
            }
            if (one == null || two == null) {
                throw new IllegalArgumentException("you have to enter a period to search in between");
            }
            return processedFileRepository.findByUserIdAndConfigNameAndDateProcessedIsBetween(userId, configName, one, two);
        } else if (byDate) {
            //we check where date is
            if (when == null) {
                throw new IllegalArgumentException("Please provide a valid date");
            }
            if (!userId.isEmpty()) {
                return processedFileRepository.findByUserIdAndDateProcessed(userId, when);
            }
            return processedFileRepository.findByDateProcessed(when);
        } else if (treated) {
            //we check for all that are treated
            if (!userId.isEmpty() && configName.isEmpty()) {
                return processedFileRepository.findByUserIdAndProcessingStatus(userId, processingStatus);
            } else if (userId.isEmpty() && !configName.isEmpty()) {
                return processedFileRepository.findByConfigNameAndProcessingStatus(configName, processingStatus);
            } else if (!userId.isEmpty() && !configName.isEmpty()) {
                return processedFileRepository.findByUserIdAndConfigName(userId, configName);
            }else if(userId.isEmpty() && configName.isEmpty() && !fileId.isEmpty()){
                return processedFileRepository.findByProcessingId(fileId);
            }
            return processedFileRepository.findByProcessingStatus(processingStatus);
        }
        else {
            //return everything
            return processedFileRepository.findAll();
        }
    }

    @Override
    public void delete(Map<String, Object> arg) {
        //arg is in the form of a where {"K":"V"}
        for (Map.Entry<String, Object> element : arg.entrySet()) {
            switch (element.getKey()) {
                case "fileId":
                    processedFileRepository.deleteById((String) element.getValue());
                    break;
                case "userId":
                    processedFileRepository.deleteAllByUserId((String) element.getValue());
                    break;
                case "processingStatus":
                    processedFileRepository.deleteAllByProcessingStatus((boolean) element.getValue());
                    break;
                case "dateProcessed":
                    processedFileRepository.deleteAllByDateProcessed((Date) element.getValue());
                    break;
            }
        }
    }

    @Override
    public boolean saveProcessedFile(List<ProcessedFile> files) {
        var saves = new ArrayList<>();
        for (var f : files) {
            saves.add(processedFileRepository.save(f));
        }
        if (saves.size() == files.size()) {
            return true;
        }
        return false;
    }

    @Override
    public List<ProcessedFile> processFiles(List<MultipartFile> files, String userId, String configName, String appmode) throws ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        Class<?> processClass = Class.forName("com.ubagroup.superfileprocessor.core.processors.Processors");
        Method process = processClass.getDeclaredMethod(configName.toLowerCase() + "Processor", List.class, String.class, String.class, String.class);
        List<ProcessedFile> treated = (List<ProcessedFile>) process.invoke(new Processors(), files, userId, configName, appmode);
        if (treated.size() > 0) {
            processedFileRepository.saveAll(treated);
        }
        return treated;
    }

    private void sortSheet(Sheet sheet, int column, int rowStart) {
        System.out.println("sorting the sheet ");
        boolean sorting = true;
        int lastrow = sheet.getLastRowNum();
        while (sorting) {

            for (Row row : sheet) {
                if (row.getRowNum() < rowStart) continue;
                if (lastrow == row.getRowNum()) break;
                Row nextRow = sheet.getRow(row.getRowNum() + 1);
                if (nextRow == null) continue;
                String debcred1 = row.getCell(column).getStringCellValue();
                String debcred2 = nextRow.getCell(column).getStringCellValue();
                System.out.println("next row val is " + debcred2 + " and row val is " + debcred1);

                if (debcred2.compareTo(debcred1) < 0) {
                    sheet.shiftRows(nextRow.getRowNum(), nextRow.getRowNum(), -1);
                    sheet.shiftRows(row.getRowNum(), row.getRowNum(), 1);
                }
            }
            sorting = false;
        }
    }

    /**
     * inSertRow inserts a new row in between existing ones in an excel file
     *
     * @param sheet
     * @param column
     * @param whereRow
     */
    private void insertRow(Sheet sheet, int column, int whereRow, Object value) {
        Row newRow = sheet.getRow(whereRow);
        if (newRow != null) {
            sheet.shiftRows(whereRow, sheet.getLastRowNum(), 1);
        } else {
            newRow = sheet.createRow(whereRow);
        }
        Cell total = newRow.createCell(column);
        if (value instanceof Integer) {
            total.setCellValue((Integer) value);
        } else if (value instanceof Double) {
            total.setCellValue((Double) value);
        } else if (value instanceof Date) {
            total.setCellValue((Date) value);
        } else {
            total.setCellValue((String) value);
        }

    }

    public List<String> generateFilePaths(String configName, String userId) {
        //get the files which are done processing for this user
        ProcessConfig laConfig = processConfigService.get(configName);
        List<ProcessedFile> lesFichiers = processedFileRepository.findByUserIdAndConfigNameAndProcessingStatus(userId, configName, true);
        //since there is a logic bug which happens when writing the headers to the file
        //then we prepend the lines with a header line
        var m = new HashMap<String, Object>();
        //m.put("LINENO~0","");
        if (laConfig.getConfigName().equalsIgnoreCase("SAGE")) {
            m.put("NAME~1", "");
            m.put("ACCOUNT NO~2", "");
            m.put("AMOUNT~3", "");
            m.put("NARRATION~4", "");
            m.put("sol id~5", "");
            m.put("TRAN TYPE~6", "");
            m.put("currency~7", "");
            m.put("report code~8", "");
        }


        return lesFichiers.stream()
                .parallel()
                .map(f -> {
                    String fileName = "";
                    System.out.println("checking config type " + laConfig.getFileTypeAndSizeInMB().get("type").toString().equalsIgnoreCase("CSV"));
                    if (laConfig.getFileTypeAndSizeInMB().get("type").toString().equalsIgnoreCase("CSV")) {
                        System.out.println("creating the excel files");
                        XSSFWorkbook workbook = new XSSFWorkbook();
                        XSSFSheet sheet = workbook.createSheet("Feuille 1");

                        int rowCount = 0;
                        List<Line> leFichier = new ArrayList<>();
                        f.getOutFile().stream()
                                .parallel()
                                .forEachOrdered(l -> {
                                    try {
                                        var ligne = l.clone();
                                        ligne.getLigne().remove("LINENO~0");
                                        var sorted = Processors.sortedLines(ligne.getLigne());
                                        leFichier.add(new Line(sorted));
                                    } catch (CloneNotSupportedException e) {
                                        e.printStackTrace();
                                    }
                                });

                        leFichier.add(0, new Line(Processors.sortedLines(m)));

                        for (var ligne : leFichier) {
                            Row row = sheet.createRow(rowCount);
                            int columnCount = 0;
                            for (Map.Entry<String, Object> entry : ligne.getLigne().entrySet()) {
                                Cell cell = row.createCell(columnCount);
                                if (rowCount == 0) {
                                    //we first fill in the header
                                    var header = entry.getKey().replaceAll("\\d", "").replaceAll("~", "");
                                    cell.setCellValue((String) header);
                                } else {

                                    //we can store the data
                                    if (entry.getValue() instanceof String) {
                                        cell.setCellValue((String) entry.getValue());
                                    } else if (entry.getValue() instanceof Integer) {
                                        cell.setCellValue((Integer) entry.getValue());
                                    }
                                }
                                columnCount++;
                            }
                            rowCount++;
                        }
                        //we sort the lines generated based on debit credit D/C
                        sortSheet(sheet, 5, 1);
                        //we calculate the sum and totals
                        int lastDebitRowIndex = 0;
                        int lastCreditRowIndex = 0;
                        int totalDebitOps = 0;
                        int totalCreditOps = 0;
                        for (Row row : sheet) {
                            if (row.getCell(5).getStringCellValue().equalsIgnoreCase("D")) {
                                totalDebitOps += Integer.parseInt(row.getCell(2).getStringCellValue());
                                lastDebitRowIndex = row.getRowNum();
                            } else if (row.getCell(5).getStringCellValue().equalsIgnoreCase("C")) {
                                totalCreditOps += Integer.parseInt(row.getCell(2).getStringCellValue());
                                lastCreditRowIndex = row.getRowNum();
                            }
                        }
                        //we insert the total of debit operations
                        if (totalDebitOps > 0) {
                            insertRow(sheet, 2, lastDebitRowIndex+1, totalDebitOps);
                        }
                        if (totalCreditOps > 0) {
                            insertRow(sheet, 2, lastCreditRowIndex+1, totalCreditOps);

                        }
                        //now we create the file
                        Object s = f.hashCode();
                        File file = new File(s + ".xlsx");
                        try {
                            FileOutputStream fileOut = new FileOutputStream(file);
                            workbook.write(fileOut);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        fileName = file.getName();

                    }
                    return fileName;
                })
                .collect(Collectors.toList());
    }
}
