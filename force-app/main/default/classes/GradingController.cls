public with sharing class GradingController {

    @AuraEnabled(cacheable=true)
    public static List<Submission__c> getSubmissionsForAssignment(Id assignmentId) {
        if (assignmentId == null) {
            return new List<Submission__c>();
        }
        return [
            SELECT Id, Score__c, Feedback__c, Submitted_On__c,
                   Enrollment__r.Student__r.Name
            FROM Submission__c
            WHERE Assignment__c = :assignmentId
            ORDER BY Submitted_On__c DESC
        ];
    }

    @AuraEnabled
    public static void saveGrade(Id submissionId, Decimal score, String feedback) {
        if (submissionId == null) {
            return;
        }
        update new Submission__c(
            Id = submissionId,
            Score__c = score,
            Feedback__c = feedback
        );
    }
}