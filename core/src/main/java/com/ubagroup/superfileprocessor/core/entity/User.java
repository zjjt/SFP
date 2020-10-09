package com.ubagroup.superfileprocessor.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * User represents a user in the DB
 */
@Document(collection="users")
public class User {
    @Id
    private String id;
    @Indexed(unique = true)
    private String username;

    @Indexed(unique = true)
    private String password;

    /**
     * The default roles are ADMIN,INITIATOR and VALIDATORS# where # represents a number that can be incremented indefinitely
     * In the DB only the admin account will be permanently stored.The other types of user will be only present in the collection
     * only for the duration of the process
     */
    private String role;
    private String creatorId;
    public User(String username, String password, String role, String creatorId) {
        this.username = username;
        this.password = password;
        this.role = role;
        this.creatorId = creatorId.equalsIgnoreCase("")?"SYSTEM":creatorId;
    }

    @Override
    public String toString() {
        return String.format("User:[id:%s\n,mail:%s\n,otp:%s\n,role:%s]",id,username,password,role);
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }


    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }


    public String getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(String creatorId) {
        this.creatorId = creatorId;
    }
}
