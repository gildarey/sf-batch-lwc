@isTest
public with sharing class ProductBackupJobTest {

    @IsTest
    static void scheduleBatch(){
        ProductBackupJob productBackupJob = new ProductBackupJob();
        Integer beforeScheduled = [SELECT Count() FROM AsyncApexJob WHERE ApexClass.Name Like '%ProductBackupBatch%'];
        
        Test.startTest();
        productBackupJob.execute(null);
        Integer afterScheduled = [SELECT Count() FROM AsyncApexJob WHERE ApexClass.Name Like '%ProductBackupBatch%'];
        Test.stopTest();
        
        System.assertEquals(beforeScheduled + 2, afterScheduled, 'Two more scheduled jobs had to be scheduled.');
    }
}
