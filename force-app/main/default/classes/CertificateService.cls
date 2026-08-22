public with sharing class CertificateService {

    public static void checkEligibility(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        List<Enrollment__c> eligibleEnrollments = [
            SELECT Id
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
              AND Progress__c = 100
        ];

        if (eligibleEnrollments.isEmpty()) {
            return;
        }

        Set<Id> alreadyHasCertificate = new Set<Id>();
        for (Certificate__c c : [
            SELECT Enrollment__c
            FROM Certificate__c
            WHERE Enrollment__c IN :enrollmentIds
        ]) {
            alreadyHasCertificate.add(c.Enrollment__c);
        }

        List<Certificate__c> certsToInsert = new List<Certificate__c>();
        for (Enrollment__c e : eligibleEnrollments) {
            if (!alreadyHasCertificate.contains(e.Id)) {
                certsToInsert.add(new Certificate__c(
                    Enrollment__c = e.Id,
                    Issued_Date__c = Date.today()
                ));
            }
        }

        if (certsToInsert.isEmpty()) {
            return;
        }

        insert certsToInsert;

        // Generate PDF in background
        Set<Id> certIds = new Set<Id>();
        for (Certificate__c c : certsToInsert) {
            certIds.add(c.Id);
        }
        System.enqueueJob(new CertificatePDFGenerator(certIds));
    }
}
