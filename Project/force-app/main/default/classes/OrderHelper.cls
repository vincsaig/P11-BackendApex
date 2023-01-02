public without sharing class OrderHelper {
    //Sets the net amount for the order based on TotalAmount - ShipmentCost
    public static void setNetAmount(Map<Id,Order> newOrdersMap, Map<Id,Order> oldOrdersMap){
        for(Order newOrder : newOrdersMap.values()){
            Order oldOrder = oldOrdersMap.get(newOrder.Id);
            if(newOrder.ShipmentCost__c != oldOrder.ShipmentCost__c){
                newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
            }
        }
    }

    //We store the orders based on their Account Id which is found on the order
    public static void setAccountRevenue(Map<Id,Order> newOrdersMap, Map<Id,Order> oldOrdersMap){
        Map<Id, List<Order>> mapAccountIdListOfOrder = new Map<Id, List<Order>>();
        for(Order newOrder : newOrdersMap.values()){
            Order oldOrder = oldOrdersMap.get(newOrder.Id);
            if(newOrder.Status == 'Ordered' && oldOrder.Status != 'Ordered'){
                if(mapAccountIdListOfOrder.get(newOrder.AccountId) != null){
                    mapAccountIdListOfOrder.get(newOrder.AccountId).add(newOrder);
                }
                else{
                    mapAccountIdListOfOrder.put(newOrder.AccountId,new List<Order>{newOrder});
                }
            }
        }
        
        if(mapAccountIdListOfOrder.size() > 0){
            List<Account> accountsLIst = getAccountAndSetRevenue(mapAccountIdListOfOrder);
            if(accountsList.size() > 0){
                update accountsList;
            }
        }
    }

    //Query all accounts based on the map keys, then sets their revenue based on all the linked orders that are 'Ordered'
    public static List<Account> getAccountAndSetRevenue(Map<Id, List<Order>> mapAccountIdListOfOrder){
        List<Account> accountsList = new List<Account>();
        if(mapAccountIdListOfOrder.size() > 0){
            accountsList = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :mapAccountIdListOfOrder.keySet()];
            for(Account account : accountsList){
                for(Order accountOrder : mapAccountIdListOfOrder.get(account.Id)){
                    if(account.Chiffre_d_affaire__c == null){
                        account.Chiffre_d_affaire__c = 0;
                    }
                    account.Chiffre_d_affaire__c += accountOrder.TotalAmount;
                }
            }
        }
        if(accountsList.size() == 0){
            return null;
        }
        return accountsList;
    }

    /*
    This method is used to check if an order has a product before setting it as 'Active'.
    If no order is found an error is added to the order
    */
    // public static void checkOrderHasProduct(Map<Id,Order> newOrders, Map<Id,Order> oldOrders){
    //     List<Order> ordersToCheck = new List<Order>();
    //     Map<Id,List<OrderItem>> linkIdOrderProduct = new Map<Id,List<OrderItem>>();
    //     for(Order newOrder : newOrders.values()){
    //         Order oldOrder = newOrders.get(newOrder.Id);
    //         if(newOrder.Status == 'Active' && oldOrder.Status != 'Active'){
    //             ordersToCheck.add(newOrder);
    //         }
    //     }

    //     for(OrderItem item : [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN :ordersToCheck]){
    //         if(linkIdOrderProduct.get(item.OrderId) != null){
    //             linkIdOrderProduct.get(item.OrderId).add(item);
    //         }
    //         else{
    //             linkIdOrderProduct.put(item.OrderId, new List<OrderItem>{item});
    //         }
    //     }

    //     for(Order order : ordersToCheck){
    //         if(!linkIdOrderProduct.containsKey(order.Id)){
    //             order.addError('You can\'t set an order to \'Active\' if there\'s no associated orderItem/product. Please link a product to this order and try again.');
    //         }
    //     }
    // }

    /*
    * On order delete, checks if the associated account still has orders linked to it
    * if not, set Active__c to false
    */
    public static void checkAccountHasOrder(Map<Id,Order> oldOrders){
        Set<Id> accountIds = new Set<Id>();
        for(Order order : oldOrders.values()){
            accountIds.add(order.AccountId);
        }

        List<Order> orders = [SELECT Id, AccountId FROM Order WHERE AccountId IN :accountIds];
        Map<Id,List<Order>> mapAccountIdsOrder = new Map<Id,List<Order>>();
        for(Order order : orders){
            if(mapAccountIdsOrder.get(order.AccountId) != null){
                mapAccountIdsOrder.get(order.AccountId).add(order);
            } else {
                mapAccountIdsOrder.put(order.AccountId, new List<Order>{order});
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for(Id accountId : accountIds){
            if(!mapAccountIdsOrder.containsKey(accountId)){
                accountsToUpdate.add(
                    new Account(
                        Id = accountId,
                        Active__c = false
                    )
                );
            }
        }
        if(accountsToUpdate.size() > 0){
            update accountsToUpdate;
        }
    }
    /* 
    * On order insert, get order Accounts where Active__c is false
    * and set it to true
    */ 
    public static void setAccountToActive(List<Order> newOrders){
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        for(Order order : newOrders){
            AccountIds.add(order.AccountId);
        }

        for(Account acc : [SELECT Id, Active__c FROM Account WHERE Active__c = false AND Id IN :accountIds]){
            acc.Active__c = true;
            accountsToUpdate.add(acc);
        }

        if(accountsToUpdate.size() > 0){
            update accountsToUpdate;
        }
    }
}
