package com.ubagroup.superfileprocessor.core.service;

import com.ubagroup.superfileprocessor.core.entity.User;

import java.util.List;

public interface UserInterface {
    List<User> getAll();
    List<User> get(String usernameouRole);
    User getAdmin(String admin,String password);
    User storeUser(User user);
    void deleteUser(User user);
}
