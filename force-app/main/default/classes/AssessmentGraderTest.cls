@isTest
private class AssessmentGraderTest {

    private class TwilioMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"sid":"SM_test","status":"queued"}');
            return res;
        }
    }

    @isTest
    static void testGradingRunsWithoutError() {
        Test.setMock(HttpCalloutMock.class, new TwilioMock());
        Course__c course = TestDataFactory.createCourse('Beginner');
        Module__c module1 = TestDataFactory.createModule(course.Id, 1);
        Assignment__c assign = TestDataFactory.createAssignment(module1.Id);
        Contact student = TestDataFactory.createStudent();
        Enrollment__c enr = TestDataFactory.createEnrollment(student.Id, course.Id);
        Submission__c sub = new Submission__c(
            Assignment__c = assign.Id,
            Enrollment__c = enr.Id,
            Student_Answers__c = '{"Q1":"A","Q2":"B"}',
            Submitted_On__c = System.now()
        );
        insert sub;

        Test.startTest();
        AssessmentGrader.gradeSubmission(sub.Id);
        Test.stopTest();

        Submission__c result = [SELECT Score__c, Assessment_Passed__c FROM Submission__c WHERE Id = :sub.Id];
        // No CMDT answer keys deployed → 0 questions → score 0
        System.assertNotEquals(null, result.Score__c, 'Score should be set after grading');
        System.assertEquals(0, result.Score__c, 'With no answer keys, score should be 0');
    }
}
