package com.ubagroup.superfileprocessor.core.repository.model;

/**
 * ApiParameterConstraints class represents the different parameters of an API endpoint and the different constraints on each
 * parameters so that the ui can properly build and auto implement client side validation of the fields
 * I have chosen here the Object types instead of the primitive ones so that fields which aren't used can be nullable
 */
public class ApiParameterConstraints {
    private boolean shouldNotBeNull;
    private boolean shouldNotBeEmpty;
    private boolean shouldBeNumeric;
    private int maxSizeInMB;
    private int maxLength;
    private int minLength;
    private boolean shouldBeEmail;
    private boolean shouldBeArray;
    private boolean shouldBeMap;
    private boolean shouldBeFile;

    public ApiParameterConstraints(boolean shouldNotBeNull, boolean shouldNotBeEmpty, boolean shouldBeNumeric, int maxSizeInMB, int maxLength, int minLength, boolean shouldBeEmail, boolean shouldBeArray, boolean shouldBeMap,boolean shouldBeFile) {
        this.shouldNotBeNull = shouldNotBeNull;
        this.shouldNotBeEmpty = shouldNotBeEmpty;
        this.shouldBeNumeric = shouldBeNumeric;
        this.maxSizeInMB = maxSizeInMB;
        this.maxLength = maxLength;
        this.minLength = minLength;
        this.shouldBeEmail = shouldBeEmail;
        this.shouldBeArray = shouldBeArray;
        this.shouldBeMap = shouldBeMap;
        this.shouldBeFile=shouldBeFile;
    }

    public boolean isShouldNotBeNull() {
        return shouldNotBeNull;
    }

    public void setShouldNotBeNull(boolean shouldNotBeNull) {
        this.shouldNotBeNull = shouldNotBeNull;
    }

    public boolean isShouldNotBeEmpty() {
        return shouldNotBeEmpty;
    }

    public void setShouldNotBeEmpty(boolean shouldNotBeEmpty) {
        this.shouldNotBeEmpty = shouldNotBeEmpty;
    }

    public boolean isShouldBeNumeric() {
        return shouldBeNumeric;
    }

    public void setShouldBeNumeric(boolean shouldBeNumeric) {
        this.shouldBeNumeric = shouldBeNumeric;
    }

    public int getMaxLength() {
        return maxLength;
    }

    public void setMaxLength(int maxLength) {
        this.maxLength = maxLength;
    }

    public int getMinLength() {
        return minLength;
    }

    public void setMinLength(int minLength) {
        this.minLength = minLength;
    }

    public boolean isShouldBeEmail() {
        return shouldBeEmail;
    }

    public void setShouldBeEmail(boolean shouldBeEmail) {
        this.shouldBeEmail = shouldBeEmail;
    }

    public int getMaxSizeInMB() {
        return maxSizeInMB;
    }

    public void setMaxSizeInMB(int maxSizeInMB) {
        this.maxSizeInMB = maxSizeInMB;
    }

    public boolean isShouldBeArray() {
        return shouldBeArray;
    }

    public void setShouldBeArray(boolean shouldBeArray) {
        this.shouldBeArray = shouldBeArray;
    }

    public boolean isShouldBeMap() {
        return shouldBeMap;
    }

    public void setShouldBeMap(boolean shouldBeMap) {
        this.shouldBeMap = shouldBeMap;
    }

    public boolean isShouldBeFile() {
        return shouldBeFile;
    }

    public void setShouldBeFile(boolean shouldBeFile) {
        this.shouldBeFile = shouldBeFile;
    }
}
