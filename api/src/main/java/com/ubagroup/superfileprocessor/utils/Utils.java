package com.ubagroup.superfileprocessor.utils;

import org.apache.commons.validator.routines.EmailValidator;

public class Utils {
    public static boolean isValidEmail(String email){
        EmailValidator validator=EmailValidator.getInstance();
        return validator.isValid(email);
    }
    public static boolean isStringUpperCase(String str){
        char[] charArray=str.toCharArray();
        for(int i=0;i<charArray.length;i++){
            if(!Character.isUpperCase(charArray[i]))
                return false;
        }
        return true;
    }
    public static String decodePwd(String pwd){
        return"";
    }
}
