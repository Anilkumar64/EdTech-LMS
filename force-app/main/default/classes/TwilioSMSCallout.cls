public with sharing class TwilioSMSCallout {
    public static void send(String toNumber, String message) {
        LMS_Settings__c settings = LMS_Settings__c.getOrgDefaults();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(settings.Twilio_Endpoint__c);
        req.setMethod('POST');
        req.setBody('To=' + toNumber + '&Body=' + EncodingUtil.urlEncode(message, 'UTF-8')
                     + '&From=' + settings.Sender_Number__c);
        new Http().send(req);
    }

    // Called from EnrollmentTrigger (after insert). Triggers can't make HTTP callouts
    // directly, so this looks up what it needs synchronously (plain SOQL is fine here)
    // and hands the actual callout off to the @future method.
    public static void enqueueForEnrollments(Set<Id> enrollmentIds) {
        Map<Id, Enrollment__c> enrollments = new Map<Id, Enrollment__c>(
            [SELECT Id, Student__c, Course__c FROM Enrollment__c WHERE Id IN :enrollmentIds]
        );

        Set<Id> studentIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();
        for (Enrollment__c e : enrollments.values()) {
            if (e.Student__c != null) studentIds.add(e.Student__c);
            if (e.Course__c != null) courseIds.add(e.Course__c);
        }

        Map<Id, Contact> studentsById = new Map<Id, Contact>(
            [SELECT Id, Phone FROM Contact WHERE Id IN :studentIds]
        );
        Map<Id, Course__c> coursesById = new Map<Id, Course__c>(
            [SELECT Id, Name FROM Course__c WHERE Id IN :courseIds]
        );

        for (Enrollment__c e : enrollments.values()) {
            Contact student = studentsById.get(e.Student__c);
            Course__c course = coursesById.get(e.Course__c);

            if (student != null && String.isNotBlank(student.Phone)) {
                String courseName = (course != null) ? course.Name : 'your course';
                SendSMSAsync.sendAsync(student.Phone, 'You have successfully enrolled in ' + courseName + '!');
            }
        }
    }
}