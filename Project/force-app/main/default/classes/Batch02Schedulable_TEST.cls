@isTest
public with sharing class Batch02Schedulable_TEST {
    @isTest
    static void testSchedulableClass(){
        Batch02Schedulable testobj = new Batch02Schedulable();
        String cronexpression = '0 0 0 ? * 2#1 *';
        test.startTest();
        Id jobId = System.schedule('Test1', cronexpression, testobj);
        CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals(cronexpression, cronTrigger1.CronExpression);
        System.assertEquals(0, cronTrigger1.TimesTriggered);
        test.stopTest();
    }
}
