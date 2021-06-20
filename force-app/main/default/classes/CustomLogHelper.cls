/**
 * @description Class to save information about migrations, batch classes, others
 */
public with sharing class CustomLogHelper {
    public static List<Custom_Log__c> stagedLogs = new List<Custom_Log__c>();

    private static String fixTitle(String title) {
        return title.length() > 100 ? title.substring(0, 100) : title;
    }

    public static void insertNewLog(String title) {
        insertNewLog(title, 'Debug');
    }

    public static void insertNewLog(String title, String level) {
        insertNewLog(title, level, null);
    }

    public static void insertNewLog(String title, String level, String className) {
        insertNewLog(title, level, className, null);
    }

    public static void insertNewLog(String title, String level, String className, String stackTrace) {
        insertNewLog(title, level, className, stackTrace, null);
    }

    public static void insertNewLog(String title, String level, String className, String stackTrace, String body) {
        insert new Custom_Log__c(
            Title__c = fixTitle(title),
            Level__c = level,
            Class__c = className,
            Body__c = body,
            Stack_Trace__c = stackTrace
        );
    }

    public static void stageNewLog(String title) {
        stageNewLog(title, 'Debug');
    }

    public static void stageNewLog(String title, String level) {
        stageNewLog(title, level, null);
    }

    public static void stageNewLog(String title, String level, String className) {
        stageNewLog(title, level, className, null);
    }

    public static void stageNewLog(String title, String level, String className, String stackTrace) {
        stageNewLog(title, level, className, stackTrace, null);
    }

    public static void stageNewLog(String title, String level, String className, String stackTrace, String body) {
        stagedLogs.add(
            new Custom_Log__c(
                Title__c = fixTitle(title),
                Level__c = level,
                Class__c = className,
                Body__c = body,
                Stack_Trace__c = stackTrace
            )
        );
    }

    public static void savePendingLogs() {
        upsert stagedLogs;
        stagedLogs = new List<Custom_Log__c>();
    }
}