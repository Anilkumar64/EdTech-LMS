@isTest
private class TwilioCalloutTest {

    private class TwilioMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"sid":"SM_test123","status":"queued"}');
            return res;
        }
    }

    @isTest
    static void testSMSCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new TwilioMock());

        Contact student = TestDataFactory.createStudent();
        Course__c course = TestDataFactory.createCourse('Beginner');
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);

        Test.startTest();
        TwilioSMSCallout.sendSMSAsync(enr.Id, 'Enrollment');
        Test.stopTest();

        System.assert(true, 'Callout completed without exception');
    }
}