public with sharing class EnrollmentController {

    @AuraEnabled
    public static Id enrollStudent(Id courseId) {
        if (courseId == null) {
            throw new AuraHandledException('Course Id is required');
        }

        // Get current user's email
        User currentUser = [
            SELECT Id, Email 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];

        if (String.isBlank(currentUser.Email)) {
            throw new AuraHandledException('User email is missing');
        }

        // Find Contact by Email
        List<Contact> contacts = [
            SELECT Id 
            FROM Contact 
            WHERE Email = :currentUser.Email 
            LIMIT 1
        ];

        if (contacts.isEmpty()) {
            throw new AuraHandledException('No Contact found with email: ' + currentUser.Email + 
                '. Please create a Contact with the same email as the Student user.');
        }

        Id studentContactId = contacts[0].Id;

        // Check if already enrolled
        List<Enrollment__c> existing = [
            SELECT Id 
            FROM Enrollment__c 
            WHERE Student__c = :studentContactId 
              AND Course__c = :courseId
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            throw new AuraHandledException('You are already enrolled in this course');
        }

        // Create Enrollment
        Enrollment__c enroll = new Enrollment__c(
            Student__c          = studentContactId,
            Course__c           = courseId,
            Status__c           = 'Active',
            Payment_Status__c   = 'Paid',
            Enrollment_Date__c  = Date.today(),
            Progress__c         = 0
        );

        insert enroll;
        return enroll.Id;
    }
}