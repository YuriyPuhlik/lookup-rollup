public with sharing class FieldRollup {
    
    @AuraEnabled
    public String label;
    @AuraEnabled
    public Object value;
    @AuraEnabled
    public String formattedValue;
    @AuraEnabled
    public Boolean isCurrency;

    public FieldRollup(String label, Object value, Schema.DisplayType fieldType) {
        this.label = label;
        this.value = value;
        this.isCurrency = isCurrency(fieldType);
        if (this.value != null && !this.isCurrency) {
            this.formattedValue = formatValue(value, fieldType);
        }
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
