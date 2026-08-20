public with sharing class CourseReminderScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new WeeklyProgressReport(), 50);
    }

    /** Call this once to schedule the job every Monday at 8 AM */
    public static void scheduleJob() {
        String cron = '0 0 8 ? * MON';
        System.schedule('Weekly Progress Report - Monday 8AM', cron, new CourseReminderScheduler());
    }
}