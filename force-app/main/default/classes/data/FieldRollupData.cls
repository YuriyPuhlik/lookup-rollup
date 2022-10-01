public inherited sharing class FieldRollupData {
    
    private static final List<String> FIELDS = new List<String>{
        'Id', 'Name', 'ParentObjectName__c', 'ChildObjectName__c',
        'ChildRelationshipName__c', 'RollupFieldName__c', 'RollupType__c'
    };

    public static List<FieldRollup__c> getFieldRollupsByParentObject(String objectName) {
        String query = 'SELECT ' + String.join(FIELDS, ', ') + ' FROM FieldRollup__c';
        query += ' WHERE ParentObjectName__c = :objectName';
        return (List<FieldRollup__c>) Database.query(query);
    }
}
