global class Batch02AccountWithoutOrderOrTask implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext info){ 
        return Database.getQueryLocator([SELECT Id,OwnerId,(SELECT Id,WhatId FROM Tasks WHERE IsReminderSet = true AND Subject = 'Call') 
                                        FROM Account 
                                        WHERE Active__c = false]
                                        );
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope){
        System.debug(scope[0].Tasks.size());
        List<Task> tasksToInsert = new List<Task>();
        for(Account acc : scope){
            if(acc.Tasks.size() == 0){
                Task task = new Task(
                    Subject = 'Call',
                    Status = 'Nouvelle',
                    Priority = 'Normale',
                    WhatId = acc.Id,
                    ReminderDateTime = Date.today().addDays(5),
                    OwnerId = acc.OwnerId
                );
                tasksToInsert.add(task);
            }
        }
        insert tasksToInsert;
    }
    
    global void finish(Database.BatchableContext info){
    }
}
