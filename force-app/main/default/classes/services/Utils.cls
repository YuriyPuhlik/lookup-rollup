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

    public static Schema.DisplayType getFieldType(String objectName, String fieldName) {
        if (!objectNameToFieldsMap.containsKey(objectName)) {
            SObjectType sObjectType = GlobalDescribeMap.get(objectName);
            objectNameToFieldsMap.put(objectName, sObjectType.getDescribe().fields.getMap());
        }
        return objectNameToFieldsMap.get(objectName).get(fieldName).getDescribe().getType();
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
}
