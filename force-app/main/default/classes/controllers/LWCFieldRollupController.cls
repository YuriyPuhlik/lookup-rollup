public with sharing class LWCFieldRollupController {

    @AuraEnabled
    public static List<FieldRollup> getFieldRollups(Id parentId) {
        try {
            return FieldRollupSvc.getFieldRollupsByParentId(parentId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static FieldRollup saveFieldRollup(String request) {
        try {
            FieldRollup fieldRollup = (FieldRollup) JSON.deserialize(request, FieldRollup.Class);
            Id fieldRollupId = FieldRollupSvc.saveFieldRollup(fieldRollup);
            return FieldRollupSvc.getFieldRollupById(fieldRollupId, fieldRollup.parentId);
        } catch (Exception e) {
            if (Test.isRunningTest()) {
                throw e;
            }
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void removeFieldRollup(Id fieldRollupId) {
        try {
            FieldRollupSvc.removeFieldRollup(fieldRollupId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static FieldSettings getFieldSettings(String request) {
        try {
            FieldSettingsRequest req = (FieldSettingsRequest) JSON.deserialize(request, FieldSettingsRequest.Class);
            return FieldRollupFilterSvc.getFieldSettings(req.objectType, req.fieldPath);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FieldSettingsRequest {
        public String objectType;
        public String fieldPath;
    }
}
