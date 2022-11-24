public with sharing class FieldRollupSvc {

    public class ValidationException extends Exception {}

    public static final String INVALID_ROLLUP_CONFIGURATION_MESSAGE = Label.Invalid_Rollup_Configuration_Message;
    public static final String INVALID_ROLLUP_FIELD_TYPE_MESSAGE = Label.Invalid_Rollup_Field_Type_Message;

    public static Id saveFieldRollup(FieldRollup fieldRollup) {
        FieldRollup__c rollupToSave = fieldRollup.convertToSF();
        validateRollup(rollupToSave);
        insert rollupToSave;
        return rollupToSave.Id;
    }

    public static void removeFieldRollup(Id fieldRollupId) {
        FieldRollup__c fieldRollup = FieldRollupData.getFieldRollupById(fieldRollupId);
        if (fieldRollup != null) {
            delete fieldRollup;
        }
    }
    
    public static FieldRollup getFieldRollupById(Id fieldRollupId, Id parentId) {
        FieldRollup__c fieldRollup = FieldRollupData.getFieldRollupById(fieldRollupId);
        if (fieldRollup == null) {
            return null;
        }
        List<FieldRollup> rollups = calculateRollups(new List<FieldRollup__c>{fieldRollup}, fieldRollup.ParentObjectName__c, parentId);
        return rollups[0];
    }
    
    public static List<FieldRollup> getFieldRollupsByParentId(Id parentId) {
        String parentObjectType = parentId.getSObjectType().getDescribe().getName();
        List<FieldRollup__c> fieldRollups = FieldRollupData.getFieldRollupsByParentObject(parentObjectType);
        if (fieldRollups.isEmpty()) {
            return new List<FieldRollup>();
        }
        return calculateRollups(fieldRollups, parentObjectType, parentId);
    }

    public static String getRollupFieldName(FieldRollup__c fieldRollup) {
        return isCount(fieldRollup) ? 'Id' : fieldRollup.RollupFieldName__c;
    }

    private static void validateRollup(FieldRollup__c fieldRollup) {
        if (
            !Utils.isObjectTypeValid(fieldRollup.ParentObjectName__c) ||
            !Utils.isObjectTypeValid(fieldRollup.ChildObjectName__c)
        ) {
            throwValidationException(INVALID_ROLLUP_CONFIGURATION_MESSAGE);
        }
        try {
            ParentChildData.getParentChildData(fieldRollup);
        } catch (QueryException e) {
            throwValidationException(INVALID_ROLLUP_CONFIGURATION_MESSAGE);
        }
        if (isCount(fieldRollup)) {
            return;
        }
        Schema.DisplayType fieldType = Utils.getFieldType(fieldRollup.ChildObjectName__c, fieldRollup.RollupFieldName__c);
        if (
            !Constants.ROLLUP_TYPE_TO_FIELD_TYPE_MAP.containsKey(fieldRollup.RollupType__c) ||
            !Constants.ROLLUP_TYPE_TO_FIELD_TYPE_MAP.get(fieldRollup.RollupType__c).contains(fieldType)
        ) {
            throwValidationException(INVALID_ROLLUP_FIELD_TYPE_MESSAGE);
        }
    }

    private static List<FieldRollup> calculateRollups(List<FieldRollup__c> fieldRollups, String parentObjectType, Id parentId) {
        List<FieldRollup> resultList = new List<FieldRollup>();
        Map<String, List<FieldRollup__c>> childRelationshipToRollupFieldsMap = new Map<String, List<FieldRollup__c>>();
        Map<String, Set<String>> childRelationshipToFieldsMap = new Map<String, Set<String>>();
        for (FieldRollup__c fieldRollup : fieldRollups) {
            String relationshipName = fieldRollup.ChildRelationshipName__c;
            if (!childRelationshipToRollupFieldsMap.containsKey(relationshipName)) {
                childRelationshipToRollupFieldsMap.put(relationshipName, new List<FieldRollup__c>());
            }
            childRelationshipToRollupFieldsMap.get(relationshipName).add(fieldRollup);
            if (!childRelationshipToFieldsMap.containsKey(relationshipName)) {
                childRelationshipToFieldsMap.put(relationshipName, new Set<String>());
            }
            childRelationshipToFieldsMap.get(relationshipName).add(getRollupFieldName(fieldRollup));
        }

        if (childRelationshipToRollupFieldsMap.isEmpty()) {
            return resultList;
        }

        List<SObject> sObjects = ParentChildData.getParentChildDataByParentId(
            parentObjectType, parentId, childRelationshipToFieldsMap
        );
        if (sObjects.isEmpty()) {
            return resultList;
        }

        SObject mainRecord = sObjects[0];
        for (String childRelationship : childRelationshipToRollupFieldsMap.keySet()) {
            List<SObject> childRecords = mainRecord.getSObjects(childRelationship);
            List<FieldRollup__c> childFieldRollups = childRelationshipToRollupFieldsMap.get(childRelationship);
            for (FieldRollup__c fieldRollup : childFieldRollups) {
                Object value = childRecords != null && !childRecords.isEmpty() 
                    ? calculateRollupValue(childRecords, fieldRollup.RollupFieldName__c, fieldRollup.RollupType__c)
                    : isCount(fieldRollup) ? 0 : null;
                resultList.add(new FieldRollup(
                    fieldRollup.Id,
                    fieldRollup.Name,
                    value,
                    !isCount(fieldRollup)
                        ? Utils.getFieldType(fieldRollup.ChildObjectName__c, fieldRollup.RollupFieldName__c)
                        : null
                ));
            }
        }
        return resultList;
    }

    private static Object calculateRollupValue(List<SObject> records, String fieldName, String rollupType) {
        switch on rollupType {
            when 'COUNT' {
                return records.size();
            }
            when 'SUM' {
                return getSum(records, fieldName);
            }
            when 'MAX' {
                return getMax(records, fieldName);
            }
            when 'MIN' {
                return getMin(records, fieldName);
            }
            when else {
                return null;
            }
        }
    }

    private static Decimal getSum(List<SObject> records, String fieldName) {
        Decimal sumValue = 0;
        for (SObject record : records) {
            sumValue += record.get(fieldName) != null ? (Decimal) record.get(fieldName) : 0;
        }
        return sumValue;
    }

    private static Object getMax(List<SObject> records, String fieldName) {
        return getMaxMinValue(records, fieldName, true);
    }

    private static Object getMin(List<SObject> records, String fieldName) {
        return getMaxMinValue(records, fieldName, false);
    }

    private static Object getMaxMinValue(List<SObject> records, String fieldName, Boolean isMax) {
        records = Utils.removeNulls(records, fieldName);
        if (records.isEmpty()) {
            return null;
        }
        Object value = records[0].get(fieldName);
        if (records.size() > 1) {
            for (Integer i = 1; i < records.size(); i++) {
                value = compareValue(value, records[i].get(fieldName), isMax);
            }
        }
        return value;
    }

    private static Object compareValue(Object currentValue, Object newValue, Boolean isMax) {
        if (currentValue instanceOf Date && newValue instanceOf Date) {
            Date currentDate = (Date) currentValue;
            Date newDate = (Date) newValue;
            if ((isMax && newDate > currentDate) || (!isMax && newDate < currentDate)) {
                return newDate;
            } 
            return currentDate;
        } else if (currentValue instanceOf DateTime && newValue instanceOf DateTime) {
            DateTime currentDateTime = (DateTime) currentValue;
            DateTime newDateTime = (DateTime) newValue;
            if ((isMax && newDateTime > currentDateTime) || (!isMax && newDateTime < currentDateTime)) {
                return newDateTime;
            } 
            return currentDateTime;
        } else {
            Decimal currentNumber = (Decimal) currentValue;
            Decimal newNumber = (Decimal) newValue;
            if ((isMax && newNumber > currentNumber) || (!isMax && newNumber < currentNumber)) {
                return newNumber;
            } 
            return currentNumber;
        }
    }

    private static Boolean isCount(FieldRollup__c fieldRollup) {
        return fieldRollup.RollupType__c == Constants.ROLLUP_TYPE_COUNT;
    }

    private static void throwValidationException(String message) {
        throw new ValidationException(message);
    }
}
