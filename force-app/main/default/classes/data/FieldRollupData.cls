public inherited sharing class FieldRollupData {
    
    private static final List<String> FIELDS = new List<String>{
        'Id', 'Name', 'ParentObjectName__c', 'ChildObjectName__c',
        'ChildRelationshipName__c', 'RollupFieldName__c', 'RollupType__c'
    };

    public static List<FieldRollup__c> getFieldRollupsByParentObject(String objectName) {
        String query = 'SELECT ' + String.join(FIELDS, ', ') + ' FROM FieldRollup__c';
        query += ' WHERE ParentObjectName__c = :objectName ORDER BY CreatedDate DESC';
        return (List<FieldRollup__c>) Database.query(query);
    }

    public static FieldRollup__c getFieldRollupById(Id recordId) {
        String query = 'SELECT ' + String.join(FIELDS, ', ') + ' FROM FieldRollup__c';
        query += ' WHERE Id = :recordId';
        List<FieldRollup__c> fieldRollups = (List<FieldRollup__c>) Database.query(query);
        return !fieldRollups.isEmpty() ? fieldRollups[0] : null;
    }
}
