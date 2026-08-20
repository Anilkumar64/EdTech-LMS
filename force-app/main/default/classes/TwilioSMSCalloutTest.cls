@IsTest
private class TwilioSMSCalloutTest {
    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assertEquals('POST', request.getMethod());
            System.assertEquals('callout:Twilio_API/Messages.json', request.getEndpoint());
            System.assert(request.getBody().contains('To='));
            System.assert(request.getBody().contains('From='));
            System.assert(request.getBody().contains('Body='));

            HttpResponse response = new HttpResponse();
            response.setStatusCode(201);
            response.setBody('{"sid":"SM123"}');
            return response;
        }
    }

    private class FailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"message":"Bad request"}');
            return response;
        }
    }

    private class ExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('Timeout');
        }
    }

    @IsTest
    static void sendsSuccessfulTwilioRequest() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('TW1', 0, 0, false);
        TwilioSMSCallout.fromNumberOverride = '+15555550199';

        Test.startTest();
        List<Integer> codes = TwilioSMSCallout.sendForEnrollments(new Set<Id>{ data.enrollment.Id });
        Test.stopTest();

        System.assertEquals(new List<Integer>{ 201 }, codes);
    }

    @IsTest
    static void handlesFailedTwilioResponse() {
        Test.setMock(HttpCalloutMock.class, new FailureMock());
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('TW2', 0, 0, false);
        TwilioSMSCallout.fromNumberOverride = '+15555550199';

        Test.startTest();
        List<Integer> codes = TwilioSMSCallout.sendForEnrollments(new Set<Id>{ data.enrollment.Id });
        Test.stopTest();

        System.assertEquals(new List<Integer>{ 400 }, codes);
    }

    @IsTest
    static void handlesCalloutException() {
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('TW3', 0, 0, false);
        TwilioSMSCallout.fromNumberOverride = '+15555550199';

        Test.startTest();
        List<Integer> codes = TwilioSMSCallout.sendForEnrollments(new Set<Id>{ data.enrollment.Id });
        Test.stopTest();

        System.assertEquals(0, codes.size());
    }

    @IsTest
    static void skipsMissingPhoneNumber() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('TW4', 0, 0, false);
        data.student.MobilePhone = null;
        data.student.Phone = null;
        update data.student;
        TwilioSMSCallout.fromNumberOverride = '+15555550199';

        Test.startTest();
        List<Integer> codes = TwilioSMSCallout.sendForEnrollments(new Set<Id>{ data.enrollment.Id });
        Test.stopTest();

        System.assertEquals(0, codes.size());
    }

    @IsTest
    static void supportsMultipleEnrollmentsAndQueueableEntryPoint() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        TwilioSMSCallout.fromNumberOverride = '+15555550199';
        LmsTestDataFactory.Scenario first = LmsTestDataFactory.createScenario('TW5A', 0, 0, false);
        LmsTestDataFactory.Scenario second = LmsTestDataFactory.createScenario('TW5B', 0, 0, false);

        Test.startTest();
        TwilioSMSCallout.enqueueForEnrollments(new Set<Id>{ first.enrollment.Id, second.enrollment.Id });
        Test.stopTest();

        System.assert(true, 'Queueable completed without throwing.');
    }
}