public with sharing class SubmissionTriggerHandler {

    public static void handle(List<Submission__c> newSubs, Map<Id, Submission__c> oldMap,
                               Boolean isInsert, Boolean isUpdate) {
        Set<Id> enrollmentIds = new Set<Id>();

        for (Submission__c sub : newSubs) {
            Boolean scoreChanged = isUpdate && sub.Score__c != oldMap.get(sub.Id).Score__c;
            if (isInsert || scoreChanged) {
                enrollmentIds.add(sub.Enrollment__c);
            }
        }

        if (!enrollmentIds.isEmpty()) {
            ProgressCalculator.recalculate(enrollmentIds);
        }
    }
}