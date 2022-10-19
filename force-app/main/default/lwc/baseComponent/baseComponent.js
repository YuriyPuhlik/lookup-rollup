import { LightningElement } from 'lwc';
import ToastService from 'c/toastService';

export default class BaseComponent extends LightningElement {

    fire(eventType, detail) {
        if (detail) {
            this.dispatchEvent(new CustomEvent(eventType, { detail }));
        } else {
            this.dispatchEvent(new CustomEvent(eventType));
        }
    }

    showToastError(message) {
        ToastService.showToastError('Error', message, this);
    }

    showToastSuccess(message) {
        ToastService.showToastSuccess('Success', message, this);
    }
    
}