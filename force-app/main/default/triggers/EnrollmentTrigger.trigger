trigger EnrollmentTrigger on Enrollment__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        TwilioSMSCallout.enqueueForEnrollments(Trigger.newMap.keySet());
    }
}