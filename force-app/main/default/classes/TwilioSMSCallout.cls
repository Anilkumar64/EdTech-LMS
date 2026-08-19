public with sharing class TwilioSMSCallout {

    // TODO: move to a Named Credential once created (Setup → Named Credentials → New,
    // name it "Twilio", point it at the real Twilio endpoint with Basic auth = SID/token).
    // Then swap the endpoint below for 'callout:Twilio/Messages.json'.
    private static final String TWILIO_ENDPOINT = 'callout:Twilio_API/Messages.json';
    @TestVisible public static String fromNumberOverride;

    public static void enqueueForEnrollments(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        for (Id enrollmentId : enrollmentIds) {
            sendSMSAsync(enrollmentId, 'Enrollment');
        }
    }

    public static List<Integer> sendForEnrollments(Set<Id> enrollmentIds) {
        List<Integer> statusCodes = new List<Integer>();
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return statusCodes;
        }

        for (Id enrollmentId : enrollmentIds) {
            Integer statusCode = sendSMS(enrollmentId, 'Enrollment');
            if (statusCode != null) {
                statusCodes.add(statusCode);
            }
        }
        return statusCodes;
    }

    @future(callout=true)
    public static void sendSMSAsync(Id recordId, String eventType) {
        sendSMS(recordId, eventType);
    }

    private static Integer sendSMS(Id recordId, String eventType) {
        String recipientNumber = getRecipientNumber(recordId);
        if (String.isBlank(recipientNumber)) {
            return null;
        }

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TWILIO_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(10000);

        String body = 'To=' + EncodingUtil.urlEncode(recipientNumber, 'UTF-8')
            + '&From=' + EncodingUtil.urlEncode(getFromNumber(), 'UTF-8')
            + '&Body=' + EncodingUtil.urlEncode(getMessageBody(eventType), 'UTF-8');
        req.setBody(body);

        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() >= 300) {
                System.debug('Twilio SMS failed: ' + res.getBody());
            }
            return res.getStatusCode();
        } catch (CalloutException ex) {
            System.debug('Twilio SMS exception: ' + ex.getMessage());
            return null;
        }
    }

    private static String getFromNumber() {
        if (fromNumberOverride != null) {
            return fromNumberOverride;
        }

        List<Twilio_SMS_Setting__mdt> settings = [
            SELECT From_Number__c FROM Twilio_SMS_Setting__mdt LIMIT 1
        ];
        return settings.isEmpty() ? '+10000000000' : settings[0].From_Number__c;
    }

    private static String getRecipientNumber(Id recordId) {
        if (recordId == null) {
            return null;
        }

        List<Enrollment__c> enrollments = [
            SELECT Student__r.MobilePhone, Student__r.Phone
            FROM Enrollment__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        if (enrollments.isEmpty()) {
            return null;
        }

        Contact student = enrollments[0].Student__r;
        if (student == null) {
            return null;
        }
        return String.isNotBlank(student.MobilePhone) ? student.MobilePhone : student.Phone;
    }

    private static String getMessageBody(String eventType) {
        Map<String, String> templates = new Map<String, String>{
            'Enrollment'   => 'Thanks for enrolling at BrightMinds Academy!',
            'Certificate'  => 'Congratulations! Your certificate has been issued.'
        };
        return templates.containsKey(eventType) ? templates.get(eventType) : 'Notification from BrightMinds Academy';
    }
}
