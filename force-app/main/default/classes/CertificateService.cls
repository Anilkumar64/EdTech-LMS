public with sharing class CertificateService {

    /**
     * Issues a Certificate__c for enrollments that are at 100% progress and do not already have one.
     * Enqueues PDF generation + email/SMS asynchronously.
     */
    public static void evaluateAndIssue(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        List<Enrollment__c> enrollments = [
            SELECT Id, Progress__c, Status__c,
                   (SELECT Id FROM Certificates__r LIMIT 1)
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
            AND Progress__c >= 100
        ];

        List<Certificate__c> toInsert = new List<Certificate__c>();

        for (Enrollment__c enr : enrollments) {
            if (enr.Certificates__r == null || enr.Certificates__r.isEmpty()) {
                toInsert.add(new Certificate__c(
                    Enrollment__c = enr.Id,
                    Issued_Date__c = System.today()
                ));
            }
        }

        if (toInsert.isEmpty()) {
            return;
        }

        insert toInsert;

        List<Id> certIds = new List<Id>();
        for (Certificate__c c : toInsert) {
            certIds.add(c.Id);
        }
        System.enqueueJob(new CertificatePDFGenerator(certIds));
    }
}
