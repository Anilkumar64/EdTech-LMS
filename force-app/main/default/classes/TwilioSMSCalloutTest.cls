@isTest
private class TwilioSMSCalloutTest {

    private class TwilioMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"sent"}');
            return res;
        }
    }

    @isTest
    static void testSMSSend() {
        Test.setMock(HttpCalloutMock.class, new TwilioMock());

        // Setup Custom Setting
        LMS_Settings__c settings = LMS_Settings__c.getOrgDefaults();
        settings.Twilio_Endpoint__c = 'https://fake-twilio-endpoint.test/sms';
        settings.Sender_Number__c = '+15550001111';
        upsert settings;

        Test.startTest();
        SendSMSAsync.sendAsync('+15559998888', 'Your enrollment is confirmed!');
        Test.stopTest();

        System.assert(true, 'SMS callout completed without error');
    }
}