public with sharing class CertificatePDFGenerator implements Queueable {

    private List<Id> certificateIds;

    public CertificatePDFGenerator(List<Id> certificateIds) {
        this.certificateIds = certificateIds == null ? new List<Id>() : certificateIds;
    }

    public void execute(QueueableContext context) {
        if (certificateIds.isEmpty()) {
            return;
        }

        List<Certificate__c> certs = [
            SELECT Id, Enrollment__c, Enrollment__r.Student__r.Email,
                   Enrollment__r.Student__r.Name, Enrollment__r.Course__r.Name,
                   Issued_Date__c
            FROM Certificate__c
            WHERE Id IN :certificateIds
        ];

        List<ContentVersion> versionsToInsert = new List<ContentVersion>();

        for (Certificate__c cert : certs) {
            Blob pdfBlob = generatePdfBlob(cert);

            ContentVersion cv = new ContentVersion();
            cv.Title = 'Certificate_' + cert.Id;
            cv.PathOnClient = 'Certificate_' + cert.Id + '.pdf';
            cv.VersionData = pdfBlob;
            cv.FirstPublishLocationId = cert.Id;
            versionsToInsert.add(cv);
        }

        if (!versionsToInsert.isEmpty()) {
            insert versionsToInsert;
        }

        for (Certificate__c cert : certs) {
            sendCertificateEmail(cert);
            if (cert.Enrollment__c != null) {
                TwilioSMSCallout.sendSMSAsync(cert.Enrollment__c, 'Certificate');
            }
        }
    }

    private Blob generatePdfBlob(Certificate__c cert) {
        if (Test.isRunningTest()) {
            return Blob.valueOf('Test PDF content for ' + cert.Id);
        }
        PageReference pdfPage = Page.CertificatePDF;
        pdfPage.getParameters().put('certId', cert.Id);
        return pdfPage.getContentAsPDF();
    }

    private void sendCertificateEmail(Certificate__c cert) {
        if (cert.Enrollment__r == null
            || cert.Enrollment__r.Student__r == null
            || String.isBlank(cert.Enrollment__r.Student__r.Email)) {
            return;
        }

        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{ cert.Enrollment__r.Student__r.Email });
            email.setSubject('Your Certificate - ' + cert.Enrollment__r.Course__r.Name);
            email.setPlainTextBody(
                'Congratulations ' + cert.Enrollment__r.Student__r.Name +
                '! You have successfully completed ' + cert.Enrollment__r.Course__r.Name +
                '. Your certificate is attached.'
            );

            List<ContentVersion> cv = [
                SELECT VersionData, Title
                FROM ContentVersion
                WHERE FirstPublishLocationId = :cert.Id
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (!cv.isEmpty()) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv[0].Title + '.pdf');
                attachment.setBody(cv[0].VersionData);
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
            }

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email }, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Certificate email failed: ' + e.getMessage());
        }
    }
}
