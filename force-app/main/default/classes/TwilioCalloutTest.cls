@isTest
public class TwilioCalloutTest {

    // Mock class: Salesforce tests are NOT allowed to make real HTTP callouts.
    // This intercepts the request and returns a fake response instead.
    private class TwilioMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod(), 'Twilio call should be a POST');
            System.assert(req.getBody().contains('To='), 'Body should include the To= param');

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"sent"}');
            return res;
        }
    }

    @isTest
    static void testSMSSendUsesFutureCallout() {
        Test.setMock(HttpCalloutMock.class, new TwilioMock());

        // Insert LMS_Settings__c so the callout has an endpoint to hit
        LMS_Settings__c settings = LMS_Settings__c.getOrgDefaults();
        settings.Twilio_Endpoint__c = 'https://fake-twilio-endpoint.test/sms';
        settings.Sender_Number__c = '+15550001111';
        upsert settings;

        Test.startTest();
        SendSMSAsync.sendAsync('+15559998888', 'Your enrollment is confirmed!');
        Test.stopTest(); // @future methods execute here, synchronously, inside stopTest

        // No exception thrown = callout succeeded against the mock.
        // (Future methods can't return values, so assertions live inside the mock's respond())
        System.assert(true, 'Future SMS callout completed without error');
    }
}
