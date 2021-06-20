@isTest
public with sharing class ProductBackupBatchTest {
    @TestSetup
    static void createData(){
        Product2 product = new Product2(
            Name = 'Testing Product',
            Price__c = 5000,
            IsActive = true
        );

        insert product;
    }

    @IsTest
    static void runBatch(){

        Integer beforeRunBatch = [SELECT Count() FROM ProductBackup__c];
        
        Test.startTest();
        Database.executebatch(new ProductBackupBatch());
        Test.stopTest();

        Integer afterRunBatch = [SELECT Count() FROM ProductBackup__c];

        System.assertEquals(0, beforeRunBatch, 'Before executing the batch, there should be no records.');
        System.assertEquals(1, afterRunBatch, 'After the batch is run there should be a record.');
        
    }
}
