package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.LogEntry;
import com.ubagroup.superfileprocessor.core.entity.ProcessControlValidation;
import com.ubagroup.superfileprocessor.core.entity.ProcessValidation;
import com.ubagroup.superfileprocessor.core.entity.User;
import com.ubagroup.superfileprocessor.core.service.*;
import com.ubagroup.superfileprocessor.utils.Utils;
import org.bson.BsonBinarySubType;
import org.bson.types.Binary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.*;
import java.net.InetAddress;
import java.net.URL;
import java.net.URLEncoder;
import java.util.*;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    Environment environment;
    @Autowired
    private UserService userService;
    @Autowired
    private LogEntryService logEntryService;
    @Autowired
    private ProcessValidationService processValidationService;
    @Autowired
    private MailService mailService;
    @Autowired
    private ProcessControlValidationService processControlValidationService;
    @Autowired
    private ProcessedFileService processedFileService;

    @Value("#{'${application.mode}'}")
    private String appmode;
    @Value("#{'${smtp.host}'}")
    private String mailHost;

    @GetMapping
    public List<User> getAll() {
        //TESTED
        System.out.println("get all users API----called");
        return userService.getAll();
    }

    @PostMapping("/sendmail")
    public Boolean sendMail(@RequestParam(value = "configName") String configName,
                            @RequestParam(value = "username") String username,
                            @RequestParam(value = "userId") String userId,
                            @RequestParam(value = "to") String to,
                            @RequestParam(value = "copie[]") List<String> enCopie,
                            @RequestParam(value = "processingId[]") List<String> processingId,
                            HttpServletRequest request) throws IOException {
        System.out.println("sending final mail for "+configName+" to "+to+" and cc "+enCopie);
        List<LogEntry> log = new ArrayList<>();
        String subject = "MONTHLY SALARY PAY UBA COTE D'IVOIRE  / SALAIRE MENSUEL PAYE UBA COTE D'IVOIRE ";
        String message = "Dear all,<br/>Please find attached the file containing the monthly pay of UBA COTE D'IVOIRE employees form the current month.<br/><br/>This email has been auto generated.Please do not reply back to it.<br/><hr/><br/>Cher tous,<br/>Veuillez trouver joint à cet email, le fichier des salaires du mois en cours des employés de UBA COTE D'IVOIRE.<br/><br/>Cet email est autogénéré veuillez ne pas y répondre";
        var sendTo = new ArrayList<String>();
        sendTo.add(to);
        List<File> pj = new ArrayList<>();
        final String DEFAULT_DIR = new File("").getAbsolutePath();
        List<String> processedFiles = processedFileService.generateFilePaths(configName, userId);
        for (var filename : processedFiles) {
            File file = new File(DEFAULT_DIR + "/" + filename);
            if (file.exists()) {
                pj.add(file);
            }
        }
        if (mailService.sendMail(subject, sendTo, "simplefileprocessor@ubagroup.com", enCopie, pj, message, mailHost)) {
            log.add(new LogEntry(username + "|" + request.getRemoteAddr(), "sent the final mail for the " + configName + " configuration to " + to + " with CC " + enCopie));
            logEntryService.saveLogs(log);
            //here we proceed to clean everything up related to this processedfile
            //ie USERS,processedFiles...
            //delete processed file
            for(String p:processingId){
                processedFileService.delete(Collections.singletonMap("processingId",p));
                System.out.println("processed file with processing validation id "+p+" removed from the db");
            }
            //delete the physical files
            for (var filename : processedFiles) {
                File file = new File(DEFAULT_DIR + "/" + filename);
                if (file.exists()) {
                    if(file.delete()){
                        System.out.println("the file "+file.getName()+" has been deleted from file system");
                    }
                }
            }
            //here we delete the validators and the controllers
            processValidationService.deleteOne(configName,userId);
            processControlValidationService.deleteOne(configName,userId);
            //remove all users involved in the validation process
            userService.deleteAllByCreatorId(userId);
            //here we remove the user from the dataBase
            userService.deleteUserById(userId);
            return true;
        }
        return false;
    }

    @PostMapping("/createOrUpdateWithRole")
    public Map<String, Object> createUser(@RequestParam(value = "username") String username,
                                          @RequestParam(value = "userId") String userId,
                                          @RequestParam(value = "fileId") String fileIdToValidate,
                                          @RequestParam(value = "usermailtocreate[]") List<String> usermailtocreate,
                                          @RequestParam(value = "filenames[]", required = false) List<String> filenames,
                                          @RequestParam(value = "attachments[]", required = false) List<MultipartFile> attachments,
                                          @RequestParam(value = "role", required = false) String role,
                                          @RequestParam(value = "configName", required = false) String configName,

                                          HttpServletRequest request) throws IOException {
        System.out.println("creating users with " + username + "and role: " + role + " API-----called");

        var m = new HashMap<String, Object>();
        List<LogEntry> log = new ArrayList<>();
        List<User> userList = new ArrayList<>();
        List<File> pj = new ArrayList<>();

        for (int i = 0; i < usermailtocreate.size(); i++) {
            var mail = usermailtocreate.get(i);
            //we check if the username is a valid email
            if (!Utils.isValidEmail(username) && !Utils.isValidEmail(mail)) {
                m.put("errors", true);
                m.put("message", "please enter a correct email address");
                m.put("users", new ArrayList<User>());
                return m;
            }
            List<User> listUsers;

            listUsers = userService.get(mail);
            if (listUsers.isEmpty() || listUsers.contains(null) || (listUsers.size() > 0 && listUsers.get(i).getRole().equalsIgnoreCase("INITIATOR")) && !role.isEmpty()) {//TESTED
                //we couldnt find the user in the db and we couldnt get a list of roles
                //so we generate a OTP
                int randomPin = (int) (Math.random() * 9000) + 1000;
                String otp = String.valueOf(randomPin);
                User user = new User(mail, otp, fileIdToValidate, role, userId);
                System.out.println(user);
                var thisUser = userService.storeUser(user);
                //We immediately insert him in the validation process for the current config for this particular user who
                //initiated the file processing
                var processValidation = role.equalsIgnoreCase("VALIDATOR") ? processValidationService.getOne(configName, userId) : role.equalsIgnoreCase("CONTROLLER") ? processControlValidationService.getOne(configName, userId) : null;
                if (processValidation == null) {
                    var map = new HashMap<String, String>();
                    map.put(thisUser.getId(), "STANDBY");
                    var listOfAttachments = new ArrayList<Map<String, Object>>();
                    if (attachments != null) {
                        System.out.println("some files are joined as attachments " + attachments.size());
                        for (int j = 0; j < attachments.size(); j++) {
                            var addedF = new HashMap<String, Object>();
                            addedF.put("filename", filenames.get(j));
                            addedF.put("binary", new Binary(BsonBinarySubType.BINARY, attachments.get(j).getBytes()));
                            System.out.println("f is " + filenames.get(j) + "\n content of addedF " + addedF);
                            listOfAttachments.add(addedF);
                            if (pj.size() < attachments.size()) {
                                //here we create the files that would be sent via mail as attachements
                                final String DEFAULT_DIR = new File("").getAbsolutePath();
                                InputStream initialStream = attachments.get(j).getInputStream();
                                byte[] buffer = new byte[initialStream.available()];
                                initialStream.read(buffer);
                                File theFile = new File(DEFAULT_DIR + "/" + filenames.get(j));
                                try (OutputStream os = new FileOutputStream(theFile)) {
                                    os.write(buffer);
                                }
                                pj.add(theFile);
                            }
                        }
                    }
                    //here we add the processed file output if the role is CONTROLLER
                    if (role.equalsIgnoreCase("CONTROLLER")) {
                        final String DEFAULT_DIR = new File("").getAbsolutePath();
                        List<String> processedFiles = processedFileService.generateFilePaths(configName, userId);
                        for (var filename : processedFiles) {
                            File file = new File(DEFAULT_DIR + "/" + filename);
                            if (file.exists()) {
                                pj.add(file);
                            }
                        }

                    }

                    System.out.println("length of list of attachments " + listOfAttachments.size());
                    processValidation = role.equalsIgnoreCase("VALIDATOR") ? new ProcessValidation(configName, userId, listOfAttachments, map, null) : role.equalsIgnoreCase("CONTROLLER") ? new ProcessControlValidation(configName, userId, listOfAttachments, map, null) : null;
                    if (role.equalsIgnoreCase("VALIDATOR")) {
                        processValidationService.saveOne((ProcessValidation) processValidation);
                    } else if (role.equalsIgnoreCase("CONTROLLER")) {
                        processControlValidationService.saveOne((ProcessControlValidation) processValidation);
                    }
                } else {
                    //here we add the user to the current map of validators by downcasting to get the proper type we wish to update
                    var validationMap = role.equalsIgnoreCase("VALIDATOR") ? ((ProcessValidation) processValidation).getValidators() : role.equalsIgnoreCase("CONTROLLER") ? ((ProcessControlValidation) processValidation).getValidators() : null;
                    validationMap.put(thisUser.getId(), "STANDBY");
                    if (role.equalsIgnoreCase("VALIDATOR")) {
                        ((ProcessValidation) processValidation).setValidators(validationMap);
                        processValidationService.saveOne((ProcessValidation) processValidation);
                    } else if (role.equalsIgnoreCase("CONTROLLER")) {
                        ((ProcessControlValidation) processValidation).setValidators(validationMap);
                        processControlValidationService.saveOne((ProcessControlValidation) processValidation);

                    }


                }

                userList.add(user);

                //Send the notifications via mail
                String subject = "";
                String message = "";
                String appPort = environment.getProperty("local.server.port");

                List<String> to = new ArrayList<>();
                to.add(user.getUsername());

                if (role.equalsIgnoreCase("VALIDATOR")) {
                    subject = "THERE ARE SOME FILES NEEDING YOUR APPROVAL FOR THE " + configName + " CONFIGURATION";
                    message = "Dear user,<br/> You have been appointed as VALIDATOR for the file id " + fileIdToValidate + " of the " + configName + " file processing configuration.<br/><br/>The application is available <a href=\"http://" + InetAddress.getLocalHost().getHostAddress()+":"+appPort+"\">here</a><br/>Please find below your credentials<br/><br/>Username: <b>" + user.getUsername() + "</b><br/>Password: <b>" + user.getPassword() + "</b><br/><br/>Your credentials are only valid for this particular file.<br/><br/>Regards.";
                    System.out.println("Mail sent for a validator\n\n" + message);

                    if (mailService.sendMail(subject, to, "simplefileprocessor@ubagroup.com", new ArrayList<>(), pj, message, mailHost)) {
                        log.add(new LogEntry(username + "|" + request.getRemoteAddr(), "created user " + user.getUsername() + " with OTP " + user.getPassword() + " in db with role " + role + " and a mail has been sent to the created user to notice him."));
                        logEntryService.saveLogs(log);
                        //delete the physical files
                        deleteFiles(pj);

                    }

                } else if (role.equalsIgnoreCase("CONTROLLER")) {
                    subject = "THERE ARE SOME FILES NEEDING TO BE CONTROLLED FOR THE " + configName + " CONFIGURATION";
                    message = "Dear user,<br/> You have been appointed as CONTROLLER for the file id " + fileIdToValidate + " of the " + configName + " file processing configuration.<br/><br/>The application is available <a href=\"http://" + InetAddress.getLocalHost().getHostAddress() +":"+appPort+ "\">here</a><br/>Please find below your credentials<br/><br/>Username: <b>" + user.getUsername() + "</b><br/>Password: <b>" + user.getPassword() + "</b><br/><br/>Your credentials are only valid for this particular file.<br/><br/>Regards.";
                    System.out.println("length of to is " + pj.size());
                    System.out.println("Mail sent for a controller\n\n" + message);
                    if (mailService.sendMail(subject, to, "simplefileprocessor@ubagroup.com", new ArrayList<>(), pj, message, mailHost)) {
                        log.add(new LogEntry(username + "|" + request.getRemoteAddr(), "created user " + user.getUsername() + " with OTP " + user.getPassword() + " in db with role " + role + " and a mail has been sent to the created user to notice him."));
                        logEntryService.saveLogs(log);
                        //delete the physical files
                        deleteFiles(pj);

                    }
                }

            }
        }

        m.put("errors", false);
        m.put("message", "user list created successfully");
        m.put("users", userList);

        return m;

    }
    private boolean deleteFiles(List<File> files){
        List<Boolean> deleted=new ArrayList<>();
        for (var file : files) {
            if (file.exists()) {
                if(file.delete()){
                    deleted.add(true);
                    System.out.println("the file "+file.getName()+" has been deleted from file system");
                }else{
                    deleted.add(false);
                }
            }
        }
        if(deleted.stream().allMatch(d->d==true)){
            return true;
        }
        return false;
    }

    @PostMapping("/getvalidatorusernames")
    public Map<String, Object> getUserWithId(@RequestParam(value = "ids[]") List<String> ids) {
        System.out.println("get usernames for the ids " + ids);
        List<String> usernames = new ArrayList<>();
        var m = new HashMap<String, Object>();
        for (int i = 0; i < ids.size(); i++) {
            var user = userService.getById(ids.get(i));
            usernames.add(user.get().getUsername());
        }
        if (Objects.nonNull(usernames)) {
            m.put("errors", false);
            m.put("message", "found list of usernames validators");
            m.put("usernames", usernames);
            return m;
        }
        m.put("errors", true);
        m.put("message", "an error occured");
        m.put("usernames", new ArrayList<>());
        return m;
    }

    @GetMapping("/with")
    public Map<String, Object> get(@RequestParam(value = "username") String usernameOrRole,
                                   @RequestParam(value = "tp", required = false) String password, HttpServletRequest request) {
        System.out.println("get users with " + usernameOrRole + " API-----called");
        List<LogEntry> log = new ArrayList<>();
        var m = new HashMap<String, Object>();
        //we check if the username is a valid email
        if (!Utils.isValidEmail(usernameOrRole) && password != null) {
            m.put("errors", true);
            m.put("message", "please enter a correct email address");
            m.put("users", new ArrayList<User>());
            return m;
        }
        //first we check if the user is an admin.If it is we immediately return
        if (usernameOrRole.contains("admin") || password.equals("sfp2020")) {
            System.out.println("Getting admin");
            User u = userService.getAdmin(usernameOrRole, password);
            System.out.println(u);
            var listUsers = new ArrayList<User>();
            if (u != null) {
                listUsers.add(u);
                log.add(new LogEntry(u.getUsername() + "|" + request.getRemoteAddr(), "log in"));
                logEntryService.saveLogs(log);
                m.put("errors", false);
                m.put("message", "admin connected successfully");
                m.put("users", listUsers);
                return m;
            } else {
                m.put("errors", true);
                m.put("message", "please re verify your credentials");
                m.put("users", new ArrayList<User>());
                return m;
            }
        } else {
            //second we log in to the Active Directory service to ensure this user is part of the domain
            if (!password.isEmpty()) {
                //here we decode the base64 encoded password string
                System.out.println("encrypted password: " + password);
                byte[] decodedBytes = Base64.getDecoder().decode(password);
                password = new String(decodedBytes);
                System.out.println("decrypted password: " + password);
            }
            if (!Utils.isStringUpperCase(usernameOrRole) && Utils.isValidEmail(usernameOrRole) && password != null) {
                //we stub the active directory query and assume this user is found then we look for him in the db
                List<User> listUsers;
                //here if we are in dev mode we dont use the AD
                switch (appmode) {
                    case "dev":
                        //if he doesnt exist we store him as an INITIATOR and we encrypt its password
                        listUsers = userService.get(usernameOrRole);
                        if (listUsers.isEmpty() || listUsers.contains(null)) {//TESTED
                            //we couldnt find the user in the db and we couldnt get a list of roles
                            //so we create the user as an INITIATOR
                            User user = new User(usernameOrRole, password, "", "INITIATOR", "");
                            System.out.println(user);
                            userService.storeUser(user);
                            listUsers.clear();
                            listUsers.add(user);
                            log.add(new LogEntry(user.getUsername() + "|" + request.getRemoteAddr(), "created user in db and log in"));
                            logEntryService.saveLogs(log);
                            m.put("errors", false);
                            m.put("message", "user " + usernameOrRole + " logged in successfully");
                            m.put("users", listUsers);
                            return m;

                        } else {//TESTED
                            log.add(new LogEntry(usernameOrRole + "|" + request.getRemoteAddr(), "log in"));
                            logEntryService.saveLogs(log);
                            m.put("errors", false);
                            m.put("message", "user " + usernameOrRole + " logged in successfully");
                            m.put("users", listUsers);
                            return m;
                        }
                    case "test":
                    case "prod":
                        if (authAD(usernameOrRole, password)) {
                            //if he doesnt exist we store him as an INITIATOR and we encrypt its password
                            listUsers = userService.get(usernameOrRole);
                            if (listUsers.isEmpty() || listUsers.contains(null)) {//TESTED
                                //we couldnt find the user in the db and we couldnt get a list of roles
                                //so we create the user as an INITIATOR
                                User user = new User(usernameOrRole, password, "", "INITIATOR", "");
                                System.out.println(user);
                                userService.storeUser(user);
                                listUsers.clear();
                                listUsers.add(user);
                                log.add(new LogEntry(user.getUsername() + "|" + request.getRemoteAddr(), "created user in db and log in"));
                                logEntryService.saveLogs(log);
                                m.put("errors", false);
                                m.put("message", "user " + usernameOrRole + " logged in successfully");
                                m.put("users", listUsers);
                                return m;

                            } else {//TESTED
                                log.add(new LogEntry(usernameOrRole + "|" + request.getRemoteAddr(), "log in"));
                                logEntryService.saveLogs(log);
                                m.put("errors", false);
                                m.put("message", "user " + usernameOrRole + " logged in successfully");
                                m.put("users", listUsers);
                                return m;
                            }
                        } else {
                            //if it gets here that means the user entered a password that has been generated for a particular file
                            listUsers = userService.get(usernameOrRole);
                            if (listUsers.isEmpty() || listUsers.contains(null)) {
                                log.add(new LogEntry(usernameOrRole + "|" + request.getRemoteAddr(), "tried to log in but wasnt found in the database nor in the AD"));
                                logEntryService.saveLogs(log);
                                m.put("errors", true);
                                m.put("message", "user " + usernameOrRole + " not found");
                                m.put("users", listUsers);
                                return m;
                            } else {
                                log.add(new LogEntry(usernameOrRole + "|" + request.getRemoteAddr(), "has logged in successfully"));
                                logEntryService.saveLogs(log);
                                m.put("errors", false);
                                m.put("message", "user " + usernameOrRole + "logged in successfully");
                                m.put("users", listUsers);
                                return m;
                            }
                        }

                }

            } else {
                //it it gets here that means the username entered isnt a user at all but a role
                //roles should be in all caps if so we return the list otherwise we return an error
                if (Utils.isStringUpperCase(usernameOrRole)) {//TESTED
                    //then we have a role search
                    var listUsers = userService.get(usernameOrRole);
                    if (listUsers.isEmpty() || listUsers.contains(null)) {//TESTED
                        m.put("errors", true);
                        m.put("message", "please re verify your search params");
                        m.put("users", new ArrayList<User>());
                        return m;
                    }
                    //TESTED

                    m.put("errors", false);
                    m.put("message", "list of all the users with role " + usernameOrRole);
                    m.put("users", listUsers);
                    return m;
                } else {
                    //TESTED
                    m.put("errors", true);
                    m.put("message", "please re verify your credentials");
                    m.put("users", new ArrayList<User>());
                    return m;
                }
            }
        }
        return m;
    }

    @GetMapping("/logout")
    public boolean logOut(@RequestParam(value = "username") String username, HttpServletRequest request) {
        List<LogEntry> log = new ArrayList<>();
        log.add(new LogEntry(username + "|" + request.getRemoteAddr(), "disconnection"));
        return logEntryService.saveLogs(log);
    }

    @PostMapping("/update")
    public Map<String, Object> updateUser(@RequestBody User user) {
        var m = new HashMap<String, Object>();
        userService.storeUser(user);
        m.put("errors", false);
        m.put("message", "user " + user.getUsername() + " updated successfully");
        m.put("users", user);
        return m;
    }

    //authenticating via UBA Active Directory
    public boolean authAD(String username, String password) {
        boolean checker = false;
        try {

            String url = "http://10.100.5.195:8017/api/ADUser/AuthenticateUser";
            StringBuilder urlBuilder = new StringBuilder();
            urlBuilder.append(url);
            urlBuilder.append("?username=").append(URLEncoder.encode(username.trim(), "UTF-8")).append("&password=").append(URLEncoder.encode(password.trim(), "UTF-8"));
            String line = "";

            BufferedReader reader = new BufferedReader(new InputStreamReader(new URL(urlBuilder.toString()).openStream()));
            StringBuffer result = new StringBuffer();

            System.out.println("URL" + urlBuilder.toString());

            while ((line = reader.readLine()) != null) {
                result.append(line);
            }
            System.out.println("VALEUR =" + result.toString().trim());

            if (result.toString().equals("true") || result.toString().equalsIgnoreCase("true")) {
                checker = true;
            }

        } catch (Exception ex) {
            System.out.println("CAUSE ERROR : " + ex.getCause());
            System.out.println("MESSAGE ERROR : " + ex.getMessage());
        }

        return checker;
    }
}
