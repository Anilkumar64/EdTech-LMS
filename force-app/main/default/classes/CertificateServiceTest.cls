@isTest
private class CertificateServiceTest {

    @isTest
    static void testCertificateIssuedAt100Percent() {
        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Advanced');
        Module__c module1 = TestDataFactory.createModule(course.Id, 1);
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        Assignment__c assign = TestDataFactory.createAssignment(module1.Id);

        Test.startTest();
        TestDataFactory.createSubmission(assign.Id, enr.Id, 95); // triggers 100% completion → cert issuance
        Test.stopTest();

        List<Certificate__c> certs = [SELECT Id, Enrollment__c FROM Certificate__c WHERE Enrollment__c = :enr.Id];
        System.assertEquals(1, certs.size(), 'A certificate should be created when progress hits 100%');
    }

    @isTest
    static void testNoDuplicateCertificate() {
        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Advanced');
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        insert new Certificate__c(Enrollment__c = enr.Id, Issued_Date__c = System.today());

        Test.startTest();
        CertificateService.evaluateAndIssue(new Set<Id>{ enr.Id });
        Test.stopTest();

        List<Certificate__c> certs = [SELECT Id FROM Certificate__c WHERE Enrollment__c = :enr.Id];
        System.assertEquals(1, certs.size(), 'Should not create a second certificate for the same enrollment');
    }
}