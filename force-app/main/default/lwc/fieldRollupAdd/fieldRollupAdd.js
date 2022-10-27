import { track, wire } from 'lwc';
import BaseComponent from 'c/baseComponent';
import { EVENT_TYPES } from 'c/constants';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import FIELD_ROLLUP_OBJECT from '@salesforce/schema/FieldRollup__c';
import ROLLUP_TYPE_FIELD from '@salesforce/schema/FieldRollup__c.RollupType__c';
import { BUTTONS } from 'c/labels';

const ROLLUP_TYPE_COUNT = 'COUNT';

const FIELD_ROLLUP_FIELDS = [
    { name: 'label', fieldName: 'Name', isRequired: true },
    { name: 'childObjectName', fieldName: 'ChildObjectName__c', isRequired: true },
    { name: 'childRelationshipName', fieldName: 'ChildRelationshipName__c', isRequired: true },
    { name: 'rollupType', fieldName: 'RollupType__c', isPicklist: true, isRequired: true },
    { name: 'rollupFieldName', fieldName: 'RollupFieldName__c', isRequired: false  },
];

export default class FieldRollupAdd extends BaseComponent {
    @track fields = {};

    fieldsInited = false;
    rollupTypeOptions = [];
    fieldRollupObjectFields;
    defaultRecordTypeId;
    
    buttons = {
        cancel: BUTTONS.CANCEL,
        save: BUTTONS.SAVE,
    };

    get fieldsArr() {
        return this.fields && Object.values(this.fields);
    }

    get isSaveDisabled() {
        return !this.isRollupFilled;
    }

    get isRollupFilled() {
        return this.fieldsArr.length && (
            !this.fieldsArr.find(field => field.isRequired && !field.value) &&
            (this.isRollupFieldDisabled || this.fields.rollupFieldName.value)
        );
    }

    get isRollupFieldDisabled() {
        return this.fields?.rollupType?.value === ROLLUP_TYPE_COUNT;
    }

    @wire(getObjectInfo, { objectApiName: FIELD_ROLLUP_OBJECT })
    processObjectInfoResponse({ data }) {
        if (data) {
            this.fieldRollupObjectFields = data.fields;
            this.defaultRecordTypeId = data.defaultRecordTypeId;
            this.initFields();
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: ROLLUP_TYPE_FIELD
    })
    processPicklistValuesResponse({ data }) {
        if (data) {
            this.rollupTypeOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
            this.initFields();
        }
    }

    initFields() {
        if (this.fieldRollupObjectFields && this.rollupTypeOptions.length && !this.fieldsInited) {
            const fields = {};
            FIELD_ROLLUP_FIELDS.forEach(field => {
                const fieldData = this.fieldRollupObjectFields[field.fieldName];
                const isRollupType = field.isPicklist && field.fieldName === ROLLUP_TYPE_FIELD.fieldApiName;
                fields[field.name] = {
                    ...field,
                    label: fieldData.label,
                    value: isRollupType ? ROLLUP_TYPE_COUNT : null,
                    picklistOptions: isRollupType ? this.rollupTypeOptions : null
                };
            });
            this.fields = fields;
            this.disableRollupFieldName();
            this.fieldsInited = true;
        }
    }

    disableRollupFieldName() {
        const isDisabled = this.isRollupFieldDisabled;
        this.fields.rollupFieldName.isDisabled = isDisabled;
        if (isDisabled) {
            this.fields.rollupFieldName.value = null;
        }
    }

    handleInputValueChange($event) {
        const value = $event.target.value;
        const fieldName = $event.target.name;
        this.fields[fieldName].value = value;
    }

    handlePicklistValueChange($event) {
        const fieldName = $event.target.name;
        if (fieldName === this.fields.rollupType.name) {
            this.handleRollupTypeChange($event.detail.value);
        }
    }

    handleRollupTypeChange(value) {
        this.fields.rollupType.value = value;
        this.disableRollupFieldName();
    }

    handleCancel() {
        this.fire(EVENT_TYPES.CANCEL);
    }

    handleSave() {
        const fieldRollup = {};
        this.fieldsArr.forEach(field => {
            fieldRollup[field.name] = field.value;
        })
        this.fire(EVENT_TYPES.SAVE, fieldRollup);
    }
}