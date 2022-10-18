public inherited sharing class ParentChildData {

    private static final String CHILD_QUERY_TEMPLATE = '(SELECT {0} FROM {1})';
    
    public static List<SObject> getParentChildDataByParentId(
        String parentObject,
        Id parentId,
        Map<String, Set<String>> childRelationshipToFieldsMap
    ) {
        List<String> subQueries = new List<String>();
        for (String childRelationship : childRelationshipToFieldsMap.keySet()) {
            List<String> fields = new List<String>(childRelationshipToFieldsMap.get(childRelationship));
            subQueries.add(String.format(
                CHILD_QUERY_TEMPLATE, new List<String>{String.join(fields, ', '), childRelationship}
            ));
        }

        String query = 'SELECT Id, ' + String.join(subQueries, ', ') + ' FROM ' + parentObject + ' WHERE Id = :parentId';
        return Database.query(query);
    }

    public static List<SObject> getParentChildData(FieldRollup__c fieldRollup) {
        String subQuery = String.format(
            CHILD_QUERY_TEMPLATE, new List<String>{FieldRollupSvc.getRollupFieldName(fieldRollup), fieldRollup.ChildRelationshipName__c}
        );
        String query = 'SELECT Id, ' + subQuery + ' FROM ' + fieldRollup.ParentObjectName__c + ' LIMIT 1';
        return Database.query(query);
    }
}
