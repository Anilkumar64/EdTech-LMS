@isTest
private class ProgressCalculatorTest {

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
    static void testRecalculateSetsProgressTo100() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];

        Test.startTest();
        TestDataFactory.createSubmission(assignment.Id, enrollment.Id, 95);
        Test.stopTest();

        Enrollment__c updated = [SELECT Progress__c FROM Enrollment__c WHERE Id = :enrollment.Id];
        System.assertEquals(100, updated.Progress__c);
    }

    @isTest
    static void testRecalculateWithEmptySet() {
        Test.startTest();
        ProgressCalculator.recalculate(new Set<Id>());
        ProgressCalculator.recalculate(null);
        Test.stopTest();
        System.assert(true, 'Handled empty/null set safely');
    }
}