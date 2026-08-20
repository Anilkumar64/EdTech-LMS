@isTest
private class CertificateServiceTest {

    @TestSetup
    static void setup() {
        Instructor__c inst = TestDataFactory.createInstructor();
        Course__c course = TestDataFactory.createCourse(inst.Id);
        Module__c mod = TestDataFactory.createModule(course.Id);
        TestDataFactory.createAssignment(mod.Id);
        Contact student = TestDataFactory.createStudent();
        TestDataFactory.createEnrollment(student.Id, course.Id);
    }

    @isTest
    static void testCertificateCreatedWhenProgress100() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];

        Test.startTest();
        TestDataFactory.createSubmission(assignment.Id, enrollment.Id, 100);
        Test.stopTest();

        List<Certificate__c> certs = [
            SELECT Id FROM Certificate__c WHERE Enrollment__c = :enrollment.Id
        ];
        System.assertEquals(1, certs.size(), 'Certificate should be created when progress reaches 100%');
    }

    @isTest
    static void testNoDuplicateCertificate() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];

        TestDataFactory.createSubmission(assignment.Id, enrollment.Id, 100);

        Test.startTest();
        CertificateService.checkEligibility(new Set<Id>{ enrollment.Id });
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM Certificate__c WHERE Enrollment__c = :enrollment.Id];
        System.assertEquals(1, count, 'Should not create duplicate certificates');
    }
}