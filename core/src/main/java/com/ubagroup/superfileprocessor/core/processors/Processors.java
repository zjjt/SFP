package com.ubagroup.superfileprocessor.core.processors;

import java.io.InputStream;
import java.util.List;

/**
 * Processors are methods paired with the actual processing configuration parametrized to handle the file processings
 * this class methods should all be suffixed with  "Processor" so that java's reflection mechanism can find the right
 * processor for the files uploaded
 */
public class Processors {

    public boolean canalProcessor(List<InputStream> files){
        System.out.println("in canal+ processor processing "+files.size()+" files");
        for(int i=0;i<files.size();i++){
            break;
        }
        return true;
    }
    public boolean paysendProcessor(List<InputStream> files) {
        System.out.println("in paysend processor processing " + files.size() + " files");
        return true;
    }


}
