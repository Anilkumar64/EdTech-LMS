public with sharing class CertificateService {

    public static void evaluateAndIssue(Set<Id> enrollmentIds) {
        List<Enrollment__c> enrollments = [
            SELECT Id, Progress__c, Status__c,
                   (SELECT Id FROM Certificates__r LIMIT 1)
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds AND Progress__c = 100
        ];

        List<Certificate__c> toInsert = new List<Certificate__c>();

        for (Enrollment__c enr : enrollments) {
            if (enr.Certificates__r.isEmpty()) {
                toInsert.add(new Certificate__c(
                    Enrollment__c = enr.Id,
                    Issued_Date__c = System.today()
                ));
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
            // Queueable handles PDF gen + email async
            System.enqueueJob(new CertificatePDFGenerator(new List<Id>((Set<Id>) new Map<Id,Certificate__c>(
                [SELECT Id FROM Certificate__c WHERE Id IN :toInsert]
            ).keySet())));
        }
    }
}
