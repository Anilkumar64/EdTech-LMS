public with sharing class WeeklyProgressReport implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Progress__c, Status__c,
                   Student__r.Email, Student__r.Name, Course__r.Name
            FROM Enrollment__c
            WHERE Status__c = 'Active'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Enrollment__c> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Enrollment__c enr : scope) {
            if (enr.Student__r.Email == null) continue;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ enr.Student__r.Email });
            mail.setSubject('Your Weekly Progress - ' + enr.Course__r.Name);
            mail.setPlainTextBody('Hi ' + enr.Student__r.Name + ',\n\n'
                + 'Your current progress in ' + enr.Course__r.Name + ' is '
                + (enr.Progress__c != null ? enr.Progress__c : 0) + '%.\n\n'
                + 'Keep going!\nBrightMinds Academy');
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('WeeklyProgressReport batch completed at ' + System.now());
    }
}