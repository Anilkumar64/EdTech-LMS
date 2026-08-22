public with sharing class StudentProgressController {

    @AuraEnabled(cacheable=true)
    public static List<EnrollmentWrapper> getMyProgress() {
        User currentUser = [
            SELECT Email 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];

        if (String.isBlank(currentUser.Email)) {
            return new List<EnrollmentWrapper>();
        }

        List<Contact> contacts = [
            SELECT Id 
            FROM Contact 
            WHERE Email = :currentUser.Email 
            LIMIT 1
        ];

        if (contacts.isEmpty()) {
            return new List<EnrollmentWrapper>();
        }

        List<Enrollment__c> enrollments = [
            SELECT Id, Name, Progress__c, Status__c,
                   Course__r.Name, Course__r.Level__c
            FROM Enrollment__c
            WHERE Student__c = :contacts[0].Id
            ORDER BY CreatedDate DESC
        ];

        List<EnrollmentWrapper> result = new List<EnrollmentWrapper>();

        for (Enrollment__c e : enrollments) {
            EnrollmentWrapper w = new EnrollmentWrapper();
            w.enrollmentId   = e.Id;
            w.courseName     = e.Course__r.Name;
            w.level          = e.Course__r.Level__c;
            w.progress       = e.Progress__c != null ? e.Progress__c : 0;
            w.status         = e.Status__c;
            result.add(w);
        }
        return result;
    }

    public class EnrollmentWrapper {
        @AuraEnabled public Id enrollmentId;
        @AuraEnabled public String courseName;
        @AuraEnabled public String level;
        @AuraEnabled public Decimal progress;
        @AuraEnabled public String status;
    }
}