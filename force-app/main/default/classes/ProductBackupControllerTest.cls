@isTest
public with sharing class ProductBackupControllerTest {

    @TestSetup
    static void createData(){
        Product2 product = new Product2(
            Name = 'Testing Product',
            Price__c = 5000,
            IsActive = true
        );

        insert product;

        String productId = String.valueOf(product.Id).substring(5, 18);

        ProductBackup__c newProductBackup = new ProductBackup__c(
            Name = product.Name,
            Selling_Price__c = product.Price__c,
            Product_External_ID__c = productId
        );

        insert newProductBackup;
    }

    @IsTest
    static void getProductIdTest(){
        ProductBackup__c productBackup = [SELECT Id, Product_External_ID__c FROM ProductBackup__c LIMIT 1];
        
        Test.startTest();
        String productId = ProductBackupController.getProductId(productBackup.Id);
        Test.stopTest();

        System.assertNotEquals(null, productId, 'It should have returned the id of the related product.');
        System.assert(productId.contains(productBackup.Product_External_ID__c), 'The returned id does not match.');
    }

    @IsTest
    static void getProductIdFailTest(){
        String msg;

        Test.startTest();
        try{
            ProductBackupController.getProductId(null);
        }catch(Exception e){
            msg = e.getMessage();
        }
        Test.stopTest();

        System.assertNotEquals(null, msg, 'It should have returned an exception');
        
    }
}
