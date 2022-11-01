public inherited sharing class Utils {
    
    private static Map<String, Schema.SObjectType> GlobalDescribeMap {
        get {
            if (GlobalDescribeMap == null) {
                GlobalDescribeMap = Schema.getGlobalDescribe();
            }
            return GlobalDescribeMap;
        }
        private set;
    }
    
    private static Map<String, Map<String, Schema.SObjectField>> objectNameToFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();

    public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldPath) {
        if (!objectNameToFieldsMap.containsKey(objectName)) {
            SObjectType sObjectType = GlobalDescribeMap.get(objectName);
            objectNameToFieldsMap.put(objectName, sObjectType.getDescribe().fields.getMap());
        }
        if (!fieldPath.contains('.')) {
            return objectNameToFieldsMap.get(objectName).get(fieldPath).getDescribe();
        }
        
        String parentRelationship = fieldPath.substringBefore('.');
        String parentFieldName = getParentField(parentRelationship);
        Schema.SObjectField parentField = objectNameToFieldsMap.get(objectName).get(parentFieldName);
        if (parentField == null) {
            return null;
        }
        String parentType = parentField.getDescribe().getReferenceTo()[0].getDescribe().getName();
        return getFieldDescribe(parentType, fieldPath.substringAfter('.'));
    }

    public static Schema.DisplayType getFieldType(String objectName, String fieldPath) {
        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectName, fieldPath);
        return fieldDescribe != null ? fieldDescribe.getType() : null;
    }

    public static List<SObject> removeNulls(List<SObject> records, String fieldName) {
        List<SObject> resultList = new List<SObject>();
        for (SObject record : records) {
            if (record.get(fieldName) != null) {
                resultList.add(record);
            }
        }
        return resultList;
    }

    public static Boolean isObjectTypeValid(String objectType) {
        return GlobalDescribeMap.containsKey(objectType);
    }

    public static Boolean isPicklist(Schema.DisplayType displayType) {
        return displayType == Schema.DisplayType.Picklist || displayType == Schema.DisplayType.MultiPicklist;
    }

    private static String getParentField(String parentRelationship) {
        return parentRelationship.endsWith('__r')
            ? parentRelationship.replace('__r', '__c')
            : parentRelationship + 'Id';
    }
}
