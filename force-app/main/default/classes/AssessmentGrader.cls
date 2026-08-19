public with sharing class AssessmentGrader {

    public static void gradeSubmission(Id submissionId) {
        Submission__c sub = [
            SELECT Id, Score__c, Assignment__r.Module__r.Course__r.Name
            FROM Submission__c WHERE Id = :submissionId
        ];

        List<Assessment_Answer_Key__mdt> answerKeys = [
            SELECT Question_Id__c, Correct_Answer__c
            FROM Assessment_Answer_Key__mdt
            WHERE Assessment_Name__c = :sub.Assignment__r.Module__r.Course__r.Name
        ];

        Integer correctCount = 0;

        Decimal pct = totalQuestions == 0 ? 0 : (correctCount * 100.0 / totalQuestions);
        sub.Score__c = pct.setScale(2);
        update sub;
    }
}