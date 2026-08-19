public with sharing class CourseReminderScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new WeeklyProgressReport(), 200);
    }

    // Call this once from Anonymous Apex / Dev Console to activate:
    // CourseReminderScheduler.scheduleWeekly();
    public static String scheduleWeekly() {
        String cronExp = '0 0 8 ? * MON *'; // every Monday 8:00 AM
        return System.schedule('Weekly Course Reminder', cronExp, new CourseReminderScheduler());
    }
}