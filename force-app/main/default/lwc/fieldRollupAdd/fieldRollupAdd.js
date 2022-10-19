import { track, wire } from 'lwc';
import BaseComponent from 'c/baseComponent';
import { EVENT_TYPES } from 'c/constants';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ROLLUP_TYPE_FIELD from '@salesforce/schema/FieldRollup__c.RollupType__c';

const ROLLUP_TYPE_COUNT = 'COUNT';

export default class FieldRollupAdd extends BaseComponent {
    @track fieldRollup = {};
    rollupTypeOptions = [];
    
    labels = {
        label: 'Label',
        childObjectName: 'Child Object API Name',
        childRelationshipName: 'Child Relationship Name',
        rollupType: 'Rollup Type',
        rollupFieldName: 'Rollup Field API Name',
        cancel: 'Cancel',
        save: 'Save',
    };


    get isRollupFieldDisabled() {
        return this.fieldRollup.rollupType === ROLLUP_TYPE_COUNT;
    }

    get isSaveDisabled() {
        return !this.isRollupFilled;
    }

    get isRollupFilled() {
        return this.fieldRollup &&
            this.fieldRollup.label &&
            this.fieldRollup.childObjectName &&
            this.fieldRollup.childRelationshipName &&
            this.fieldRollup.rollupType &&
            (this.isRollupFieldDisabled || this.fieldRollup.rollupFieldName);
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ROLLUP_TYPE_FIELD })
    processResponse({ data, error }) {
        if (data) {
            this.rollupTypeOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
            this.fieldRollup.rollupType = this.rollupTypeOptions.find(option => option.value === ROLLUP_TYPE_COUNT)?.value;
        }
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
        this.fire(EVENT_TYPES.CANCEL);
    }

    handleSave() {
        this.fire(EVENT_TYPES.SAVE, this.fieldRollup);
    }
}