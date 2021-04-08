package com.zoundz.bean;

import com.zoundz.util.Global;

import java.io.Serializable;
/*
 * Copyright Subcodevs, Inc. 2021
 */
public class UserBean implements Serializable {

    private String userID;
    private String name;
    private String firstname;
    private String lastname;
    private String email;
    private String subscriptionType;
    private String accountType;
    private String profileImage;
    private String subscriptionExpiresIn;

    public String getUserID() {
        return userID;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getName() {

        String name = "";

        if(firstname != null) {
            name += Global.capsFirstChar(firstname);
        }
        if(lastname != null) {
            name += " "+Global.capsFirstChar(lastname);
        }
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSubscriptionType() {
        return subscriptionType;
    }

    public void setSubscriptionType(String subscriptionType) {
        this.subscriptionType = subscriptionType;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }

    public String getSubscriptionExpiresIn() {
        return subscriptionExpiresIn;
    }

    public void setSubscriptionExpiresIn(String subscriptionExpiresIn) {
        this.subscriptionExpiresIn = subscriptionExpiresIn;
    }
}
