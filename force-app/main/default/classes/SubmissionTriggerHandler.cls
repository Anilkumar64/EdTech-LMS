public with sharing class SubmissionTriggerHandler {

    private static Boolean isHandling = false;

    public static void handleAfterUpsert(List<Submission__c> newSubs, Map<Id, Submission__c> oldMap) {
        if (isHandling) {
            return;
        }
        isHandling = true;

        Set<Id> enrollmentIds = new Set<Id>();

        for (Submission__c sub : newSubs) {
            Boolean scoreChanged = oldMap == null
                || sub.Score__c != oldMap.get(sub.Id).Score__c;
            if (sub.Score__c != null && scoreChanged && sub.Enrollment__c != null) {
                enrollmentIds.add(sub.Enrollment__c);
            }
        }

        if (!enrollmentIds.isEmpty()) {
            ProgressCalculator.recalculateProgress(enrollmentIds);
        }

        isHandling = false;
    }
}
