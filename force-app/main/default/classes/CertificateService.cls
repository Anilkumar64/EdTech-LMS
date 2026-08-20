public with sharing class CertificateService {

    /**
     * Called when Progress reaches 100%.
     * Creates a Certificate__c record if one does not already exist.
     *
     * NOTE: Full "all assessments passed" check requires a student-level
     * assessment result object (not present in the current data model).
     * Currently we issue the certificate when Progress = 100%.
     */
    public static void checkEligibility(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) {
            return;
        }

        // Only consider enrollments that are truly at 100%
        List<Enrollment__c> eligibleEnrollments = [
            SELECT Id
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
              AND Progress__c = 100
        ];

        if (eligibleEnrollments.isEmpty()) {
            return;
        }

        // Prevent duplicate certificates
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

        if (!certsToInsert.isEmpty()) {
            insert certsToInsert;
        }
    }
}