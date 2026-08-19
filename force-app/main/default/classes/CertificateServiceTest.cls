@isTest
private class CertificateServiceTest {

    private class TwilioMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"sid":"SM_test","status":"queued"}');
            return res;
        }
    }

    @isTest
    static void testCertificateIssuedAt100Percent() {
        Test.setMock(HttpCalloutMock.class, new TwilioMock());
        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Advanced');
        Module__c module1 = TestDataFactory.createModule(course.Id, 1);
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        Assignment__c assign = TestDataFactory.createAssignment(module1.Id);

        Test.startTest();
        TestDataFactory.createSubmission(assign.Id, enr.Id, 95);
        Test.stopTest();

        List<Certificate__c> certs = [SELECT Id, Enrollment__c FROM Certificate__c WHERE Enrollment__c = :enr.Id];
        System.assertEquals(1, certs.size(), 'A certificate should be created when progress hits 100%');
    }

    @isTest
    static void testNoDuplicateCertificate() {
        Test.setMock(HttpCalloutMock.class, new TwilioMock());
        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Advanced');
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        // Force progress to 100 so evaluate would try to issue
        enr.Progress__c = 100;
        update enr;
        insert new Certificate__c(Enrollment__c = enr.Id, Issued_Date__c = System.today());

        Test.startTest();
        CertificateService.evaluateAndIssue(new Set<Id>{ enr.Id });
        Test.stopTest();

        List<Certificate__c> certs = [SELECT Id FROM Certificate__c WHERE Enrollment__c = :enr.Id];
        System.assertEquals(1, certs.size(), 'Should not create a second certificate for the same enrollment');
    }
}
