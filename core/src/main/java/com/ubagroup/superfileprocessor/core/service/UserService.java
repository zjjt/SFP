package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.User;
import com.ubagroup.superfileprocessor.core.repository.mongodb.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
public class UserService implements UserInterface {
    @Autowired
    private UserRepository userRepository;
    @Override
    public List<User> getAll() {
        return userRepository.findAll();
    }
    @Override
    public Optional<User> getById(String id){
        var user=userRepository.findById(id);

        return user;
    }

    @Override
    public List<User> get(String usernameouRole) {
        List<User> l=new ArrayList<>();
      if(usernameouRole.contains("@")) {
            l.add(userRepository.findFirstByUsername(usernameouRole));
            return l;
        }
        return userRepository.findByRole(usernameouRole);
    }

    @Override
    public User getAdmin(String admin,String password){
            return userRepository.findFirstByUsernameAndPassword(admin,password);
    }


    @Override
    public User storeUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public void deleteUser(User user) {
        userRepository.delete(user);
    }
    public void deleteUserById(String userId){userRepository.deleteById(userId);}
    public void deleteAllByCreatorId(String userId){userRepository.deleteAllByCreatorId(userId);}

}
