@isTest
private class WeeklyProgressReportTest {

    @TestSetup
    static void setup() {
        Instructor__c inst = TestDataFactory.createInstructor();
        Course__c course = TestDataFactory.createCourse(inst.Id);
        Module__c mod = TestDataFactory.createModule(course.Id);
        TestDataFactory.createAssignment(mod.Id);
        Contact student = TestDataFactory.createStudent();
        TestDataFactory.createEnrollment(student.Id, course.Id);
    }

    @isTest
    static void testBatchRunsSuccessfully() {
        Test.startTest();
        Id jobId = Database.executeBatch(new WeeklyProgressReport(), 50);
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Batch job should be queued');
    }
}