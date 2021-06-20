import { LightningElement, wire, api } from 'lwc';
import getProductId from "@salesforce/apex/ProductBackupController.getProductId";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import IS_ACTIVE from '@salesforce/schema/Product2.IsActive';

export default class ProductBackup extends LightningElement {

    @api recordId;
    productId;

    @wire(getProductId, { productBackupId: "$recordId" })
    wiredResult(result) {
        if (result.data) {
            this.productId = result.data;
        } else if (result.error) {
            console.error(result.error);
        }
    }

    @wire(getRecord, { recordId: "$productId", fields: [IS_ACTIVE] })
    product2;

    get isActive(){
        let isActive = getFieldValue(this.product2.data, IS_ACTIVE);
        return isActive ? 'Yes' : 'No';
    }

}