package com.ubagroup.superfileprocessor.core.utils;

import java.util.Calendar;

public  class Utils {
    public static String getCurrentMonth(){
        String[] months={"JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"};
        Calendar cal= Calendar.getInstance();
        String month=months[cal.get(Calendar.MONTH)];
        return month;
    }
}
