public with sharing class EnrollmentController {

    @AuraEnabled
    public static Id enrollStudent(Id courseId) {
        if (courseId == null) {
            throw new AuraHandledException('Course Id is required');
        }

        // Get current user's Contact
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (u.ContactId == null) {
            throw new AuraHandledException('No Contact linked to this user. Student must have a Contact.');
        }

        // Check if already enrolled
        List<Enrollment__c> existing = [
            SELECT Id FROM Enrollment__c 
            WHERE Student__c = :u.ContactId AND Course__c = :courseId
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            throw new AuraHandledException('You are already enrolled in this course');
        }

        Enrollment__c enroll = new Enrollment__c(
            Student__c = u.ContactId,
            Course__c = courseId,
            Status__c = 'Active',
            Payment_Status__c = 'Paid',
            Enrollment_Date__c = Date.today(),
            Progress__c = 0
        );
        insert enroll;
        return enroll.Id;
    }
}