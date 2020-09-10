package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.LogEntry;
import com.ubagroup.superfileprocessor.core.entity.User;
import com.ubagroup.superfileprocessor.core.service.LogEntryService;
import com.ubagroup.superfileprocessor.core.service.UserService;
import com.ubagroup.superfileprocessor.utils.Utils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.util.*;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;
    @Autowired
    private LogEntryService logEntryService;
    @Value("#{'${application.mode}'}")
    private  String appmode;
    @GetMapping
    public List<User> getAll(){
        //TESTED
        System.out.println("get all users API----called");
        return userService.getAll();
    }
    @GetMapping("/with")
    public Map<String,Object> get(@RequestParam(value = "username") String usernameOrRole,
                                  @RequestParam(value = "tp",required = false) String password, HttpServletRequest request){
        System.out.println("get users with "+usernameOrRole+" API-----called");
        List<LogEntry>log=new ArrayList<>();
        var m=new HashMap<String,Object>();
        //we check if the username is a valid email
        if(!Utils.isValidEmail(usernameOrRole) && password!=null){
            m.put("errors",true);
            m.put("message","please enter a correct email address");
            m.put("users",new ArrayList<User>());
            return m;
        }
        //first we check if the user is an admin.If it is we immediately return
        if(usernameOrRole.contains("admin")|| password.equals("sfp2020")){
            System.out.println("Getting admin");
            User u=userService.getAdmin(usernameOrRole,password);
            System.out.println(u);
            var listUsers=new ArrayList<User>();
            if(u!=null){
                listUsers.add(u);
                log.add(new LogEntry(u.getUsername()+"|"+ request.getRemoteAddr(),"log in"));
                logEntryService.saveLogs(log);
                m.put("errors",false);
                m.put("message","admin connected successfully");
                m.put("users",listUsers);
                return m;
            }else{
                m.put("errors",true);
                m.put("message","please re verify your credentials");
                m.put("users",new ArrayList<User>());
                return m;
            }
        }else{
            //second we log in to the Active Directory service to ensure this user is part of the domain
            if(!password.isEmpty()){
                //here we decode the base64 encoded password string
                System.out.println("encrypted password: "+password);
                byte[] decodedBytes= Base64.getDecoder().decode(password);
                password=new String(decodedBytes);
                System.out.println("decrypted password: "+password);
            }
            if(!Utils.isStringUpperCase(usernameOrRole) && Utils.isValidEmail(usernameOrRole) && password !=null ){
                //we stub the active directory query and assume this user is found then we look for him in the db
                List<User> listUsers;
                //here if we are in dev mode we dont use the AD
                switch(appmode){
                    case "dev":
                        //if he doesnt exist we store him as an INITIATOR and we encrypt its password
                        listUsers=userService.get(usernameOrRole);
                        if(listUsers.isEmpty()||listUsers.contains(null)){//TESTED
                            //we couldnt find the user in the db and we couldnt get a list of roles
                            //so we create the user as an INITIATOR
                            User user=new User(usernameOrRole,password, null, "INITIATOR");
                            System.out.println(user);
                            userService.storeUser(user);
                            listUsers.clear();
                            listUsers.add(user);
                            log.add(new LogEntry(user.getUsername()+"|"+ request.getRemoteAddr(),"created user in db and log in"));
                            logEntryService.saveLogs(log);
                            m.put("errors",false);
                            m.put("message","user "+usernameOrRole+" logged in successfully");
                            m.put("users",listUsers);
                            return m;

                        }else{//TESTED
                            log.add(new LogEntry(usernameOrRole+"|"+ request.getRemoteAddr(),"log in"));
                            logEntryService.saveLogs(log);
                            m.put("errors",false);
                            m.put("message","user "+usernameOrRole+" logged in successfully");
                            m.put("users",listUsers);
                            return m;
                        }
                    case "test":
                    case"prod":
                        if(authAD(usernameOrRole,password)){
                            //if he doesnt exist we store him as an INITIATOR and we encrypt its password
                            listUsers=userService.get(usernameOrRole);
                            if(listUsers.isEmpty()||listUsers.contains(null)){//TESTED
                                //we couldnt find the user in the db and we couldnt get a list of roles
                                //so we create the user as an INITIATOR
                                User user=new User(usernameOrRole,password,null, "INITIATOR");
                                System.out.println(user);
                                userService.storeUser(user);
                                listUsers.clear();
                                listUsers.add(user);
                                log.add(new LogEntry(user.getUsername()+"|"+ request.getRemoteAddr(),"created user in db and log in"));
                                logEntryService.saveLogs(log);
                                m.put("errors",false);
                                m.put("message","user "+usernameOrRole+" logged in successfully");
                                m.put("users",listUsers);
                                return m;

                            }else{//TESTED
                                log.add(new LogEntry(usernameOrRole+"|"+ request.getRemoteAddr(),"log in"));
                                logEntryService.saveLogs(log);
                                m.put("errors",false);
                                m.put("message","user "+usernameOrRole+" logged in successfully");
                                m.put("users",listUsers);
                                return m;
                            }
                        }
                            break;
                }

            }else{
                //it it gets here that means the username entered isnt a user at all but a role
                //roles should be in all caps if so we return the list otherwise we return an error
                if(Utils.isStringUpperCase(usernameOrRole)){//TESTED
                    //then we have a role search
                    var listUsers=userService.get(usernameOrRole);
                    if(listUsers.isEmpty()||listUsers.contains(null)){//TESTED
                        m.put("errors",true);
                        m.put("message","please re verify your search params");
                        m.put("users",new ArrayList<User>());
                        return m;
                    }
                    //TESTED

                    m.put("errors",false);
                    m.put("message","list of all the users with role "+usernameOrRole);
                    m.put("users",listUsers);
                    return m;
                }else{
                    //TESTED
                    m.put("errors",true);
                    m.put("message","please re verify your credentials");
                    m.put("users",new ArrayList<User>());
                    return m;
                }
            }
        }
        return m;
    }
    @GetMapping("/logout")
    public boolean logOut(@RequestParam(value="username") String username,HttpServletRequest request){
        List<LogEntry> log=new ArrayList<>();
        log.add(new LogEntry(username+"|"+ request.getRemoteAddr(),"disconnection"));
        return logEntryService.saveLogs(log);
    }
    @PostMapping("/update")
    public Map<String,Object> updateUser(@RequestBody User user){
        var m=new HashMap<String,Object>();
        userService.storeUser(user);
        m.put("errors",false);
        m.put("message","user "+user.getUsername()+" updated successfully");
        m.put("users",user);
        return m;
    }
    //authenticating via UBA Active Directory
    public boolean authAD(String username,String password){
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

                    while ((line = reader.readLine()) != null){
                        result.append(line);
                    }
                    System.out.println("VALEUR =" + result.toString().trim());

                    if(result.toString().equals("true") || result.toString().equalsIgnoreCase("true")){
                        checker = true;
                    }

                } catch (Exception ex) {
                    System.out.println("CAUSE ERROR : " + ex.getCause());
                    System.out.println("MESSAGE ERROR : " + ex.getMessage());
                }

            return checker;
    }
}
