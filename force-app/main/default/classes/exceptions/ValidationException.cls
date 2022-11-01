public with sharing class ValidationException extends Exception {
    public static void throwException(String msg) {
        throw new ValidationException(msg);
    }
}
