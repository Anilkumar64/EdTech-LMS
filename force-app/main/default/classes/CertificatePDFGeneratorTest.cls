@isTest
private class CertificatePDFGeneratorTest {

    @TestSetup
    static void setup() {
        Instructor__c inst = TestDataFactory.createInstructor();
        Course__c course = TestDataFactory.createCourse(inst.Id);
        Module__c mod = TestDataFactory.createModule(course.Id);
        TestDataFactory.createAssignment(mod.Id);
        Contact student = TestDataFactory.createStudent();
        Enrollment__c enrollment = TestDataFactory.createEnrollment(student.Id, course.Id);

        insert new Certificate__c(
            Enrollment__c = enrollment.Id,
            Issued_Date__c = Date.today()
        );
    }

    @isTest
    static void testPDFGeneration() {
        Certificate__c cert = [SELECT Id FROM Certificate__c LIMIT 1];

        Test.startTest();
        System.enqueueJob(new CertificatePDFGenerator(new Set<Id>{ cert.Id }));
        Test.stopTest();

        List<Attachment> atts = [SELECT Id, Name, ContentType FROM Attachment WHERE ParentId = :cert.Id];
        System.assertEquals(1, atts.size(), 'PDF attachment should be created');
        System.assertEquals('application/pdf', atts[0].ContentType);
    }

    @isTest
    static void testEmptyIds() {
        Test.startTest();
        System.enqueueJob(new CertificatePDFGenerator(null));
        System.enqueueJob(new CertificatePDFGenerator(new Set<Id>()));
        Test.stopTest();
        System.assert(true, 'Handled null and empty set');
    }
}