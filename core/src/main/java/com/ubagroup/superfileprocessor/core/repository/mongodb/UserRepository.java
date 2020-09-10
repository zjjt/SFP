package com.ubagroup.superfileprocessor.core.repository.mongodb;

import com.ubagroup.superfileprocessor.core.entity.User;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface UserRepository extends MongoRepository<User,String> {
    //SELECT
     List<User> findByRole(String role);
     User findFirstByUsername(String mail);
     User findFirstByUsernameAndPassword(String username,String password);

}
