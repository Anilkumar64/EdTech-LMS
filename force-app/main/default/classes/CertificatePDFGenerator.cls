public with sharing class CertificatePDFGenerator implements Queueable {

    private Set<Id> certificateIds;

    public CertificatePDFGenerator(Set<Id> certificateIds) {
        this.certificateIds = certificateIds;
    }

    public void execute(QueueableContext context) {
        if (certificateIds == null || certificateIds.isEmpty()) {
            return;
        }

        List<Certificate__c> certificates = [
            SELECT Id, 
                   Enrollment__r.Student__r.Name, 
                   Enrollment__r.Course__r.Name, 
                   Issued_Date__c
            FROM Certificate__c
            WHERE Id IN :certificateIds
        ];

        List<Attachment> attachments = new List<Attachment>();

        for (Certificate__c cert : certificates) {
            String studentName = cert.Enrollment__r.Student__r.Name != null 
                ? cert.Enrollment__r.Student__r.Name : 'Student';
            String courseName  = cert.Enrollment__r.Course__r.Name != null 
                ? cert.Enrollment__r.Course__r.Name : 'Course';
            String issuedDate  = String.valueOf(cert.Issued_Date__c);

            String html = '<html><body style="font-family:Arial;text-align:center;padding:40px;">'
                        + '<h1>Certificate of Completion</h1>'
                        + '<p>This is to certify that</p>'
                        + '<h2>' + studentName + '</h2>'
                        + '<p>has successfully completed the course</p>'
                        + '<h3>' + courseName + '</h3>'
                        + '<p>Issued on: ' + issuedDate + '</p>'
                        + '</body></html>';

            Blob pdfBlob = Blob.toPDF(html);

            Attachment att = new Attachment();
            att.ParentId    = cert.Id;
            att.Name        = 'Certificate_' + studentName.replaceAll('[^a-zA-Z0-9]', '_') + '.pdf';
            att.Body        = pdfBlob;
            att.ContentType = 'application/pdf';
            attachments.add(att);
        }

        if (!attachments.isEmpty()) {
            insert attachments;
        }
    }
}