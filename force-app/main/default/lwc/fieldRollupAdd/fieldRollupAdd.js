import { LightningElement, track } from 'lwc';

export default class FieldRollupAdd extends LightningElement {
    @track fieldRollup = {
        rollupType: 'COUNT'
    };
    
    labels = {
        label: 'Label',
        childObjectName: 'Child Object API Name',
        childRelationshipName: 'Child Relationship Name',
        rollupType: 'Rollup Type',
        rollupFieldName: 'Rollup Field API Name',
        cancel: 'Cancel',
        save: 'Save',
    };

    rollupTypeOptions = [
        {
            label: 'COUNT',
            value: 'COUNT'
        },
        {
            label: 'SUM',
            value: 'SUM'
        },
        {
            label: 'MAX',
            value: 'MAX'
        },
        {
            label: 'MIN',
            value: 'MIN'
        },
    ];

    get isRollupFieldDisabled() {
        return this.fieldRollup.rollupType === 'COUNT';
    }

    handleInputValueChange($event) {
        const value = $event.target.value;
        const field = $event.target.name;
        this.fieldRollup[field] = value;
    }

    handleRollupTypeChange($event) {
        this.fieldRollup.rollupType = $event.detail.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('save', {
            detail: this.fieldRollup
        }));
    }
}