import { LightningElement, wire, api } from 'lwc';
import getProductId from "@salesforce/apex/ProductBackupController.getProductId";

export default class ProductBackup extends LightningElement {

    @api recordId;
    productId;

    @wire(getProductId, { productBackupId: "$recordId"})
    wiredResult(result) {
        if (result.data) {
          this.productId = result.data;
        } else if(result.error){
            console.error(result.error);
        }
      }
    
}