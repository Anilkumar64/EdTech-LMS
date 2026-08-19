public with sharing class SubmissionTriggerHandler {

    private static Boolean isHandling = false;

    public static void handleAfterUpsert(List<Submission__c> newSubs, Map<Id, Submission__c> oldMap) {
        if (isHandling) {
            return;
        }
        isHandling = true;
        try {
            Set<Id> enrollmentIds = new Set<Id>();

            for (Submission__c sub : newSubs) {
                Submission__c oldSub = (oldMap == null) ? null : oldMap.get(sub.Id);

                Boolean scoreChanged = oldSub == null || sub.Score__c != oldSub.Score__c;
                Boolean enrollmentChanged = oldSub != null && sub.Enrollment__c != oldSub.Enrollment__c;

                if (sub.Score__c != null && scoreChanged && sub.Enrollment__c != null) {
                    enrollmentIds.add(sub.Enrollment__c);
                }
                if (enrollmentChanged) {
                    if (sub.Enrollment__c != null) {
                        enrollmentIds.add(sub.Enrollment__c);
                    }
                    if (oldSub != null && oldSub.Enrollment__c != null) {
                        enrollmentIds.add(oldSub.Enrollment__c);
                    }
                }
            }

            if (!enrollmentIds.isEmpty()) {
                ProgressCalculator.recalculateProgress(enrollmentIds);
            }
        } finally {
            isHandling = false;
        }
    }
}
