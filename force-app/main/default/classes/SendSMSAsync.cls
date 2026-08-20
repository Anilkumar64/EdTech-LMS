public with sharing class SendSMSAsync {
    @future(callout=true)
    public static void sendAsync(String toNumber, String message) {
        TwilioSMSCallout.send(toNumber, message);
    }
}
