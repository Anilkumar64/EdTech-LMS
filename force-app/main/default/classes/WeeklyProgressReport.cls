public with sharing class WeeklyProgressReport implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, 
                   Student__r.Email, 
                   Student__r.Name,
                   Course__r.Name, 
                   Progress__c
            FROM Enrollment__c
            WHERE Status__c = 'Active'
              AND Student__r.Email != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Enrollment__c> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Enrollment__c enroll : scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { enroll.Student__r.Email });
            mail.setSubject('Weekly Progress Report - ' + enroll.Course__r.Name);

            String body = 'Hello ' + enroll.Student__r.Name + ',\n\n'
                        + 'Your current progress for ' + enroll.Course__r.Name + ' is '
                        + (enroll.Progress__c != null ? enroll.Progress__c : 0) + '%.\n\n'
                        + 'Keep going!\n\n'
                        + 'Regards,\nBrightMinds Academy';

            mail.setPlainTextBody(body);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('WeeklyProgressReport finished successfully.');
    }
}