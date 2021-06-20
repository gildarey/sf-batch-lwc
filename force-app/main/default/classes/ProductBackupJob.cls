/**
 * @date: Jun 2021
 * @author: Gilda Rey
 *
 * @description: Class to schedule ProductBackupBatch
 */
global with sharing class ProductBackupJob implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        String firstExe = '0 41 9 ? * * *';
        String secondExe = '0 43 23 ? * * *';
        String name = 'Process product backup in queue on each day at ';

        ProductBackupBatch productBackupBacth = new ProductBackupBatch();
        //To execute every day at First Execution
        System.schedule(name + '9:41', firstExe, productBackupBacth);

        //To execute every day at second Execution
        System.schedule(name + '23:43', secondExe, productBackupBacth);

    }
}
