public with sharing class LWCFieldRollupController {
    @AuraEnabled
    public static List<FieldRollup> getFieldRollups(Id recordId) {
        try {
            return FieldRollupSvc.getFieldRollupsBySObjectId(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
