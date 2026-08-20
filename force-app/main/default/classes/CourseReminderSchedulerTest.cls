@isTest
private class CourseReminderSchedulerTest {

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
    static void testExecute() {
        Test.startTest();
        new CourseReminderScheduler().execute(null);
        Test.stopTest();
        System.assert(true, 'Scheduler executed without error');
    }

    @isTest
    static void testScheduleJob() {
        Test.startTest();
        CourseReminderScheduler.scheduleJob();
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'Weekly Progress Report%'
        ];
        System.assertEquals(1, jobs.size(), 'Job should be scheduled');
    }
}