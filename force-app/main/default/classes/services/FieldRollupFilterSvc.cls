public with sharing class FieldRollupFilterSvc {

    public static FieldSettings getFieldSettings(String objectType, String fieldPath) {

        Schema.DescribeFieldResult fieldDescribe = Utils.getFieldDescribe(objectType, fieldPath);
        if (fieldDescribe == null) {
            ValidationException.throwException('Invalid field definition');
        }

        Schema.DisplayType fieldType = fieldDescribe.getType();
        if (!Constants.FIELD_TYPE_CONDITIONS_MAP.containsKey(fieldType)) {
            ValidationException.throwException('Unsupported field type');
        }

        if (Utils.isPicklist(fieldType)) {
            List<FieldSettings.PicklistOption> picklistOptions = new List<FieldSettings.PicklistOption>();
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) {
                    picklistOptions.add(new FieldSettings.PicklistOption(entry));
                }
            }
            return new FieldSettings(
                fieldType,
                Constants.FIELD_TYPE_CONDITIONS_MAP.get(fieldType),
                picklistOptions
            );
        }

        return new FieldSettings(fieldType, Constants.FIELD_TYPE_CONDITIONS_MAP.get(fieldType));
    }

}
