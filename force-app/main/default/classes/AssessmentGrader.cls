public with sharing class AssessmentGrader {

    public static void grade(List<Submission__c> submissions) {
        if (submissions == null || submissions.isEmpty()) {
            return;
        }

        List<Submission__c> toUpdate = new List<Submission__c>();

        for (Submission__c sub : submissions) {
            if (String.isNotBlank(sub.Feedback__c) && sub.Score__c == null) {
                // Create a new sObject with only Id + Score to avoid FLS issues
                toUpdate.add(new Submission__c(
                    Id = sub.Id,
                    Score__c = 100
                ));
            }
        }

        if (!toUpdate.isEmpty()) {
            // Use system mode style update
            update toUpdate;
        }
    }
}