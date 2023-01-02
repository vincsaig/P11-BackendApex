global class Batch01AccountChiffreAffaire implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
        //Query all orders that are 'Ordered'
        return Database.getQueryLocator('SELECT Id, TotalAmount, AccountId FROM Order WHERE Status = \'Ordered\'');
    }
    
    global void execute(Database.BatchableContext info, List<Order> scope){
        //We store the orders based on their account Id which is found on the order
        Map<Id,List<Order>> mapAccountIdListOfOrder = new Map<Id, List<Order>>();
        List<Account> accountsList = new List<Account>();
        for(Order order : scope){
            if(mapAccountIdListOfOrder.get(order.AccountId) != null){
                mapAccountIdListOfOrder.get(order.AccountId).add(order);
            } 
            else{
                mapAccountIdListOfOrder.put(order.AccountId,new List<Order>{order});
            }
        }

        if(mapAccountIdListOfOrder.size() > 0){
            accountsList = OrderHelper.getAccountAndSetRevenue(mapAccountIdListOfOrder);
        }
        if(accountsList.size() > 0){
            update accountsList;
        }
    }
    
    global void finish(Database.BatchableContext info){
    }
}