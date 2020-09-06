package com.ubagroup.superfileprocessor.api.controller;

import com.ubagroup.superfileprocessor.core.entity.User;
import com.ubagroup.superfileprocessor.core.service.UserService;
import com.ubagroup.superfileprocessor.utils.Utils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;
    @GetMapping
    public List<User> getAll(){
        //TESTED
        System.out.println("get all users API----called");
        return userService.getAll();
    }
    @GetMapping("/with")
    public Map<String,Object> get(@RequestParam(value = "username") String usernameOrRole,
                                  @RequestParam(value = "password",required = false) String password){
        System.out.println("get users with "+usernameOrRole+" API-----called");
        var m=new HashMap<String,Object>();
        //we check if the username is a valid email
        if(!Utils.isValidEmail(usernameOrRole) && password!=null){
            m.put("errors",true);
            m.put("message","please enter a correct email address");
            m.put("users",new ArrayList<User>());
            return m;
        }
        //first we check if the user is an admin.If it is we immediately return
        if(password.equals("sfp2020")){
            System.out.println("Getting admin");
            User u=userService.getAdmin(usernameOrRole,password);
            System.out.println(u);
            var listUsers=new ArrayList<User>();
            if(u!=null){
                listUsers.add(u);
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
            if(true && !Utils.isStringUpperCase(usernameOrRole) && Utils.isValidEmail(usernameOrRole) && password !=null ){
                //we stub the active directory query and assume this user is found then we look for him in the db
                //if he doesnt exist we store him as an INITIATOR and we encrypt its password
                var listUsers=userService.get(usernameOrRole);
                if(listUsers.isEmpty()||listUsers.contains(null)){//TESTED
                    //we couldnt find the user in the db and we couldnt get a list of roles
                    //so we create the user as an INITIATOR
                    User user=new User(usernameOrRole,password,false,"INITIATOR");
                    System.out.println(user);
                    userService.storeUser(user);
                    listUsers.clear();
                    listUsers.add(user);
                    m.put("errors",false);
                    m.put("message","user "+usernameOrRole+" logged in successfully");
                    m.put("users",listUsers);
                    return m;

                }else{//TESTED
                    m.put("errors",false);
                    m.put("message","user "+usernameOrRole+" logged in successfully");
                    m.put("users",listUsers);
                    return m;
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
}
