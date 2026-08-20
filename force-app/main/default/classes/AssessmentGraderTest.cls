@isTest
private class AssessmentGraderTest {

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
    static void testGradeSetsScore() {
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Enrollment__c enrollment = [SELECT Id FROM Enrollment__c LIMIT 1];

        Submission__c sub = new Submission__c(
            Assignment__c = assignment.Id,
            Enrollment__c = enrollment.Id,
            Feedback__c = 'A,B,C,D',
            Submitted_On__c = System.now()
        );
        insert sub;

        Test.startTest();
        AssessmentGrader.grade(new List<Submission__c>{ sub });
        Test.stopTest();

        Submission__c updated = [SELECT Score__c FROM Submission__c WHERE Id = :sub.Id];
        System.assertEquals(100, updated.Score__c, 'Score should be set to 100');
    }

    @isTest
    static void testGradeWithNullAndEmpty() {
        Test.startTest();
        AssessmentGrader.grade(null);
        AssessmentGrader.grade(new List<Submission__c>());
        Test.stopTest();
        System.assert(true, 'Handled null and empty list');
    }
}