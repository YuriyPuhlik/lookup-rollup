import { LightningElement, api } from 'lwc';
import getFieldRollups from '@salesforce/apex/LWCFieldRollupController.getFieldRollups';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';

export default class FieldRollups extends LightningElement {
    @api recordId;
    fieldRollups = [];
    labels = {
        title: 'Field Rollups',
    };

    connectedCallback() {
        getFieldRollups({recordId: this.recordId})
            .then(result => {
                this.fieldRollups = result.map(fieldRollup => {
                    if (!fieldRollup.value) {
                        fieldRollup.formattedValue = '-';
                    } else if (fieldRollup.isCurrency) {
                        fieldRollup.formattedValue = new Intl.NumberFormat(LOCALE, {
                            style: 'currency',
                            currency: CURRENCY,
                            currencyDisplay: 'symbol',
                        }).format(fieldRollup.value)
                    }
                    return fieldRollup;
                });
                console.log({fieldRollups: JSON.parse(JSON.stringify(this.fieldRollups))})
            })
            .catch(error => {
                console.error(error)
            });
        
    }
}