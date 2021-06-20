@isTest
public class CustomLogHelperTest {
    static final String CLASS_NAME = 'Account';

    @TestSetup
    static void setUp() {
        List<Account> accounts = new List<Account>();

        for (integer i = 1; i < 6; i++) {
            Account acc = new Account(Name = 'Test ' + i);
            accounts.add(acc);
        }

        insert accounts;
    }

    @isTest
    static void customLogHelperSuccess() {
        List<Account> accounts = selectAll();

        for (Account acc : accounts) {
            acc.Description = 'Test for CustomLogHelper';
        }

        Test.startTest();
        createCustomLog(accounts, 'Success');
        Test.stopTest();
        Custom_Log__c customLog = [SELECT Title__c, Stack_Trace__c, Class__c FROM Custom_Log__c LIMIT 1];
        System.assertEquals('Success', customLog.Title__c, 'There must be a Custom Log that has registered all the changes.');
        System.assertEquals('Account', customLog.Class__c, 'The Custom Log must be related to Account Object');
        System.assertEquals('Total: 5. Succeeded: 5. Failed: 0', customLog.Stack_Trace__c, 'There should be no error log');
    }

    @isTest
    static void customLogHelperFailure() {
        List<Account> accounts = selectAll();

        for (Account acc : accounts) {
            acc.Name = null;
        }

        Test.startTest();
        createCustomLog(accounts, 'Error');
        Test.stopTest();

        List<Custom_Log__c> customLog = [SELECT Title__c, Stack_Trace__c, Class__c FROM Custom_Log__c WHERE Title__c = 'Error'];
        System.assertEquals('Total: 5. Succeeded: 0. Failed: 5', customLog[0].Stack_Trace__c, 'There must be a Custom Log that has registered all the Exceptions.');
        System.assertEquals('Account', customLog[0].Class__c, 'The Custom Log must be related to Account Object');
    }

    @isTest
    static void insertNewLogTest() {
        
        Test.startTest();
        CustomLogHelper.insertNewLog('Test title');
        Test.stopTest();

        List<Custom_Log__c> customLog = [SELECT Title__c, Stack_Trace__c, Class__c FROM Custom_Log__c WHERE Title__c = 'Test title'];
        System.assertEquals(1, customLog.size(), 'There must be a Custom Log created.'
        );
    }
    
    @isTest
    static void stageNewLog2Test() {
        CustomLogHelper.stageNewLog('Test title');
        List<Custom_Log__c> customLog = [SELECT Title__c, Stack_Trace__c, Class__c FROM Custom_Log__c WHERE Title__c = 'Test title'];
        System.assertEquals(0, customLog.size(), 'There must be a Custom Log created.');
        Test.startTest();
        CustomLogHelper.savePendingLogs();
        Test.stopTest();

        customLog = [ SELECT Title__c, Stack_Trace__c, Class__c FROM Custom_Log__c WHERE Title__c = 'Test title'];
        System.assertEquals(1, customLog.size(), 'There must be a Custom Log created.');
    }

    private static void createCustomLog(List<Account> accounts, String title) {
        Integer totals = accounts.size();
        Integer totalSucceedRecords = 0;
        Integer totalFailedRecords = 0;
        for (Database.SaveResult ur : Database.update(accounts, false)) {
            if (ur.success) {
                totalSucceedRecords++;
            } else {
                totalFailedRecords++;
            }
        }
        CustomLogHelper.stageNewLog(title, 'Debug', CLASS_NAME, 'Total: ' + totals + '. Succeeded: ' + totalSucceedRecords + '. Failed: ' + totalFailedRecords);
        CustomLogHelper.savePendingLogs();
    }

    private static List<Account> selectAll(){
        return [SELECT Id, Description FROM Account];
    }
}
