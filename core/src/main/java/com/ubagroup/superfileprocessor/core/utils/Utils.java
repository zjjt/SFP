package com.ubagroup.superfileprocessor.core.utils;

import java.util.Calendar;

public  class Utils {
    public static String getCurrentMonth(){
        String[] months={"JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"};
        Calendar cal= Calendar.getInstance();
        String month=months[cal.get(Calendar.MONTH)];
        return month;
    }
    public static String getRandomString(int n){
        String AlphaNumString="ABCDEFGHIJKLMNOPQRSTUVWXYZ"+"0123456789"+"abcdefghijklmnopqrstuvwxyz";
        StringBuilder stringBuilder=new StringBuilder(n);
        for(int i=0;i<n;i++){
            int index=(int)(AlphaNumString.length()*Math.random());
            stringBuilder.append(AlphaNumString.charAt(index));
        }
        return stringBuilder.toString();
    }
    public static boolean isNumeric(String strNum) {
        if (strNum == null) {
            return false;
        }
        try {
            double d = Double.parseDouble(strNum);
        } catch (NumberFormatException nfe) {
            return false;
        }
        return true;
    }
}
