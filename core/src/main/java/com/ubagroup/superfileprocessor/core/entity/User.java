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
    private String mail;
    @Indexed(unique = true)
    private String otp;
    /**
     * The default roles are ADMIN,INITIATOR and VALIDATORS# where # represents a number that can be incremented indefinitely
     * In the DB only the admin account will be permanently stored.The other types of user will be only present in the collection
     * only for the duration of the process
     */
    private String role;

    public User(String mail, String otp, String role) {
        this.mail = mail;
        this.otp = otp;
        this.role = role;
    }

    @Override
    public String toString() {
        return String.format("User:[id:%s\n,mail:%s\n,otp:%s\n,role:%s]",id,mail,otp,role);
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getMail() {
        return mail;
    }

    public void setMail(String mail) {
        this.mail = mail;
    }

    public String getOtp() {
        return otp;
    }

    public void setOtp(String otp) {
        this.otp = otp;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
