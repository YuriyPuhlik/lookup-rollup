public with sharing class FieldRollup {
    
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public Object value;
    @AuraEnabled
    public String formattedValue;
    @AuraEnabled
    public Boolean isCurrency;

    public String parentId;
    public String parentObjectName;
    public String childObjectName;
    public String childRelationshipName;
    public String rollupType;
    public String rollupFieldName;

    public FieldRollup() {}

    public FieldRollup(Id id, String label, Object value, Schema.DisplayType fieldType) {
        this.id = id;
        this.label = label;
        this.value = value;
        this.isCurrency = isCurrency(fieldType);
        if (this.value != null && !this.isCurrency) {
            this.formattedValue = formatValue(value, fieldType);
        }
    }

    public FieldRollup__c convertToSF() {
        return new FieldRollup__c(
            Name = this.label,
            ParentObjectName__c = parentObjectName,
            ChildObjectName__c = this.childObjectName,
            ChildRelationshipName__c = this.childRelationshipName,
            RollupType__c = this.rollupType,
            RollupFieldName__c = this.rollupFieldName
        );
    }

    private Boolean isCurrency(Schema.DisplayType fieldType) {
        return fieldType == Schema.DisplayType.currency;
    }

    private String formatValue(Object value, Schema.DisplayType fieldType) {
        switch on fieldType {
            when Date {
                return ((Date) value).format();
            }
            when DateTime {
                return ((DateTime) value).format();
            }
            when Percent {
                return String.valueOf(value) + '%';
            }
            when else {
                return String.valueOf(value);
            }
        }
    }
}
