public with sharing class FieldRollupSvc {
    
    public static List<FieldRollup> getFieldRollupsBySObjectId(Id recordId) {
        List<FieldRollup> resultList = new List<FieldRollup>();
        String sObjectType = recordId.getSObjectType().getDescribe().getName();
        List<FieldRollup__c> fieldRollups = FieldRollupData.getFieldRollupsByParentObject(sObjectType);
        if (fieldRollups.isEmpty()) {
            return resultList;
        }

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
            childRelationshipToFieldsMap.get(relationshipName).add(
                isCount(fieldRollup.RollupType__c) ? 'Id' : fieldRollup.RollupFieldName__c
            );
        }

        if (childRelationshipToRollupFieldsMap.isEmpty()) {
            return resultList;
        }

        List<SObject> sObjects = ParentChildData.getParentChildDataByParentId(
            sObjectType, recordId, childRelationshipToFieldsMap
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
                    : null;
                resultList.add(new FieldRollup(
                    fieldRollup.Name,
                    value,
                    !isCount(fieldRollup.RollupType__c) 
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

    private static Boolean isCount(String rollupType) {
        return rollupType == 'COUNT';
    }
}
