import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastService extends LightningElement {
    
    static showToastError(title, message, context) {
        this.showToast(title, message, 'error', context);
    }

    static showToastSuccess(title, message, context) {
        this.showToast(title, message, 'success', context);
    }

    static showToast(title, message, variant, context) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable'
        });
        context.dispatchEvent(event);
    }
}