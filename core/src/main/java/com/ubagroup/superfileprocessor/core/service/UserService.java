package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.User;
import com.ubagroup.superfileprocessor.core.repository.mongodb.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserService implements UserInterface {
    @Autowired
    private UserRepository userRepository;
    @Override
    public List<User> getAll() {
        return userRepository.findAll();
    }

    @Override
    public List<User> get(String mailourole) {
        List<User> l=new ArrayList<>();
        if(mailourole.contains("@")) {
            l.add(userRepository.findFirstByUsername(mailourole));
            return l;
        }
        return userRepository.findByRole(mailourole);
    }


    @Override
    public User storeUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public void deleteUser(User user) {
        userRepository.delete(user);
    }
}
