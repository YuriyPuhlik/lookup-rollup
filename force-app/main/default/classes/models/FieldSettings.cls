public with sharing class FieldSettings {
    
    @AuraEnabled
    public Schema.DisplayType type;
    @AuraEnabled
    public List<String> conditions;
    @AuraEnabled
    public List<PicklistOption> picklistOptions;

    public FieldSettings(Schema.DisplayType type, List<String> conditions) {
        this.type = type;
        this.conditions = conditions;
    }

    public FieldSettings(Schema.DisplayType type, List<String> conditions, List<PicklistOption> picklistOptions) {
        this(type, conditions);
        this.picklistOptions = picklistOptions;
    }

    public class PicklistOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public PicklistOption(Schema.PicklistEntry option) {
            this.label = option.getLabel();
            this.value = option.getValue();
        }
    }
}
