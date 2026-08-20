trigger SubmissionTrigger on Submission__c (after insert, after update) {
    SubmissionTriggerHandler.handle(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
}
