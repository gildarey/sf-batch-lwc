/**
 * @date: Jun 2021
 * @author: Gilda Rey
 *
 * @description: Class to backup Product2
 */
global class ProductBackupBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{

    public Integer successCounter = 0;
    public  Integer failureCounter = 0;
    public  Integer count = 0;
    global static final String CLASS_NAME = 'ProductBackupBatch';

    /**
     * @description
     */
    global void execute(SchedulableContext SC) {
        database.executebatch(new ProductBackupBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Price__c FROM Product2 WHERE IsActive = true'
        );
    }

    /**
     * @description
     */
    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        Map<String, Product2> mapProduct = new Map<String, Product2>();
        Map<String, ProductBackup__c> mapProductBackup = new Map<String, ProductBackup__c>();
        
        Set<String> productsId = new Set<String>();
        
        try {
            for (Product2 product : scope) {
                String productId = string.valueOf(product.Id);
                /**
                 * Observation: Since the exercise requires using a unique 13 character id, the first 13 of 
                 * the product record may throw an error because most are the same 13 characters.
                 * The number of standard characters for an id in salesforce is equal to 18, but 
                 * it is also valid to use the first 15, in that case, the commented line must be uncommented. 
                 * Otherwise the last 13 characters are used.
                 */
                // productId = productId.length() > 15 ? productId.substring(0, 15) : productId;
                productId = productId.length() > 13 ? productId.substring(5, 18) : productId;

                mapProduct.put(productId, product);
                mapProductBackup.put(productId, null);
                productsId.add(productId);
            }

            Integer limitQuery = scope.size();
            count = limitQuery;

            for (ProductBackup__c productBackup : [SELECT Id, Product_External_ID__c, Selling_Price__c FROM ProductBackup__c WHERE Product_External_ID__c IN:productsId LIMIT:limitQuery]) {
                Product2  tmpProduct = mapProduct.get(productBackup.Product_External_ID__c);
                productBackup.Selling_Price__c = tmpProduct.Price__c;
                mapProductBackup.put(string.valueOf(productBackup.Product_External_ID__c), productBackup);
            }
            
            for(String key : mapProductBackup.keySet()){ 
                Product2  tmpProduct = mapProduct.get(key);
                String productId = key;
                if(mapProductBackup.get(key) == null ){
                    ProductBackup__c newProductBackup = new ProductBackup__c(
                        Name = tmpProduct.Name,
                        Selling_Price__c = tmpProduct.Price__c,
                        /**
                         * Observation: Since the exercise requires using a unique 13 character id, the first 13 of 
                         * the product record may throw an error because most are the same 13 characters.
                         * The number of standard characters for an id in salesforce is equal to 18, but 
                         * it is also valid to use the first 15, in that case, the commented line must be uncommented. 
                         * Otherwise the last 13 characters are used.
                         */
                        // Product_External_ID__c = productId.length() > 15 ? productId.substring(0, 15) : productId;
                        Product_External_ID__c = productId
                    );
                    mapProductBackup.put(key, newProductBackup);
               }
            }

            for (Database.UpsertResult ur : Database.upsert(mapProductBackup.values(), false)) {
                if (ur.success) {
                    successCounter++;
                } else {
                    failureCounter++;
                    for (Database.Error de : ur.getErrors()) {
                        CustomLogHelper.stageNewLog('Error on Upsert ProductBackup execution.', 'Batch', CLASS_NAME, de.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            CustomLogHelper.stageNewLog('Error on ProductBackup execution.', 'Batch', CLASS_NAME, e.getStackTraceString(), e.getLineNumber() + ' - ' + e.getMessage());
        }
        CustomLogHelper.savePendingLogs();
    }

    /**
     * @description
     */
    global void finish(Database.BatchableContext bc) {
        CustomLogHelper.stageNewLog(
            'Total Records',
            'Batch',
            CLASS_NAME,
            'Total: ' +
            count +
            '. Succeeded: ' +
            successCounter +
            '. Failed: ' +
            failureCounter
        );
        CustomLogHelper.savePendingLogs();

        if(checkDeliverability()){
            sendResultEmail(count, failureCounter);
        }
    }
    
    @TestVisible
    private static void sendResultEmail(Integer total, Integer failureCounter) {
        List<ApexEmailNotification> emailToNotificate = [SELECT Email FROM ApexEmailNotification WHERE Email != null];

        if(!emailToNotificate.isEmpty()){
            List<String> emails = new List<String>();
            for (ApexEmailNotification email : emailToNotificate) {
                emails.add(email.Email);
            }
            String emailSubject = String.valueOf(Date.today()) + ' - Daily Product Backup execution: ' + total + ' Records. ';
            emailSubject += failureCounter == 0 ? ' Success' : ' Failed, ' + failureCounter + ' records failed.';
    
            String body = emailSubject + '. For more details go to Custom Log Object.';
    
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emails;
            message.subject = emailSubject;
            message.plainTextBody = body;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    
            if (!results[0].success){
                CustomLogHelper.stageNewLog('The email failed to send.', 'Debug', CLASS_NAME, results[0].errors[0].message);
            }
        }

    }

    private static Boolean checkDeliverability(){
        try {
            Messaging.reserveSingleEmailCapacity(0);
            return true;
        } catch (System.NoAccessException e) {
            return false;
        }
    }
}
