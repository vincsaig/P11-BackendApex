public without sharing class OrderHelper {
    /*
    This method is used to check if an order has a product before setting it as 'Active'.
    If no order is found an error is added to the order
    */
    public static void checkOrderHasProduct(Map<Id,Order> newOrders, Map<Id,Order> oldOrders){
        List<Order> ordersToCheck = new List<Order>();
        Map<Id,List<OrderItem>> linkIdOrderProduct = new Map<Id,List<OrderItem>>();
        for(Order newOrder : newOrders.values()){
            Order oldOrder = oldOrders.get(newOrder.Id);
            if(newOrder.Status == 'Activated' && oldOrder.Status != 'Activated'){
                ordersToCheck.add(newOrder);
            }
        }

        for(OrderItem item : [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN :ordersToCheck]){
            if(linkIdOrderProduct.get(item.OrderId) != null){
                linkIdOrderProduct.get(item.OrderId).add(item);
            }
            else{
                linkIdOrderProduct.put(item.OrderId, new List<OrderItem>{item});
            }
        }

        for(Order order : ordersToCheck){
            if(!linkIdOrderProduct.containsKey(order.Id)){
                order.addError('You can\'t set an order to \'Active\' if there\'s no associated orderItem/product. Please link a product to this order and try again.');
            }
        }
    }

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
