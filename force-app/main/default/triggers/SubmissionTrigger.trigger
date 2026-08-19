trigger SubmissionTrigger on Submission__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            SubmissionTriggerHandler.handleAfterUpsert(Trigger.new, Trigger.oldMap);
        }
    }
}