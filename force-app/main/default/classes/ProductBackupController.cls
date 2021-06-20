public with sharing class ProductBackupController {
    
    @AuraEnabled(cacheable=true)
    public static string getProductId(String productBackupId){
        try {
            String productSearched = [SELECT Product_External_Id__c FROM ProductBackup__c WHERE Id=: productBackupId LIMIT 1].Product_External_Id__c;
            Id prefixId = [SELECT Id FROM Product2 LIMIT 1].Id;
            String fullId = string.valueOf(prefixId).substring(0, 5) + productSearched;

            String productId =  [SELECT Id FROM Product2 WHERE Id=:fullId LIMIT 1].Id;

            return productId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
