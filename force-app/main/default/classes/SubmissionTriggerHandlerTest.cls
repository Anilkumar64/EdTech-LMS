@IsTest
private class SubmissionTriggerHandlerTest {
    @IsTest
    static void insertWithNullScoreDoesNotCompleteModule() {
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('ST1', 1, 1, false);

        Test.startTest();
        insert new Submission__c(Assignment__c = data.assignments[0].Id, Enrollment__c = data.enrollment.Id);
        Test.stopTest();

        Enrollment__c enrollment = [SELECT Progress__c FROM Enrollment__c WHERE Id = :data.enrollment.Id];
        System.assertEquals(0, enrollment.Progress__c);
    }

    @IsTest
    static void scoreAddedAndChangedRecalculatesProgress() {
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('ST2', 1, 1, false);
        Submission__c submission = new Submission__c(Assignment__c = data.assignments[0].Id, Enrollment__c = data.enrollment.Id);
        insert submission;

        Test.startTest();
        submission.Score__c = 80;
        update submission;
        submission.Score__c = 90;
        update submission;
        Test.stopTest();

        Enrollment__c enrollment = [SELECT Progress__c FROM Enrollment__c WHERE Id = :data.enrollment.Id];
        System.assertEquals(100, enrollment.Progress__c);
    }

    @IsTest
    static void enrollmentChangeRecalculatesBothEnrollments() {
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('ST3', 1, 1, false);
        Contact secondStudent = new Contact(LastName = 'Second Student', Email = 'second@example.com');
        insert secondStudent;
        Enrollment__c secondEnrollment = new Enrollment__c(
            Name = 'Second Enrollment',
            Student__c = secondStudent.Id,
            Course__c = data.course.Id,
            Enrollment_Date__c = Date.today(),
            Payment_Status__c = 'Paid',
            Status__c = 'Active'
        );
        insert secondEnrollment;
        Submission__c submission = new Submission__c(Assignment__c = data.assignments[0].Id, Enrollment__c = data.enrollment.Id, Score__c = 100);
        insert submission;

        Test.startTest();
        submission.Enrollment__c = secondEnrollment.Id;
        update submission;
        Test.stopTest();

        Set<Id> enrollmentIds = new Set<Id>{ data.enrollment.Id, secondEnrollment.Id };
        Map<Id, Enrollment__c> enrollments = new Map<Id, Enrollment__c>([
            SELECT Progress__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ]);
        System.assertEquals(0, enrollments.get(data.enrollment.Id).Progress__c);
        System.assertEquals(100, enrollments.get(secondEnrollment.Id).Progress__c);
    }

    @IsTest
    static void bulkInsertMultipleSubmissions() {
        LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('ST4', 1, 200, false);

        Test.startTest();
        insert LmsTestDataFactory.buildScoredSubmissions(data, 100);
        Test.stopTest();

        Enrollment__c enrollment = [SELECT Progress__c FROM Enrollment__c WHERE Id = :data.enrollment.Id];
        System.assertEquals(100, enrollment.Progress__c);
    }

    @IsTest
    static void bulkUpdateMultipleEnrollments() {
        List<Submission__c> submissions = new List<Submission__c>();
        Set<Id> enrollmentIds = new Set<Id>();
        for (Integer i = 0; i < 20; i++) {
            LmsTestDataFactory.Scenario data = LmsTestDataFactory.createScenario('STB' + i, 1, 1, false);
            enrollmentIds.add(data.enrollment.Id);
            submissions.add(new Submission__c(Assignment__c = data.assignments[0].Id, Enrollment__c = data.enrollment.Id));
        }
        insert submissions;
        for (Submission__c submission : submissions) {
            submission.Score__c = 100;
        }

        Test.startTest();
        update submissions;
        Test.stopTest();

        System.assertEquals(20, [SELECT COUNT() FROM Enrollment__c WHERE Id IN :enrollmentIds AND Progress__c = 100]);
    }
}