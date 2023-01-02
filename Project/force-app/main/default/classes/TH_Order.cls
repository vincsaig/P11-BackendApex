public without sharing class TH_Order extends TriggerHandler {
    List<Order> newList = (List<Order>)Trigger.new;
    List<Order> oldList = (List<Order>)Trigger.old;
    Map<Id,Order> newMap = (Map<Id,Order>)Trigger.newMap;
    Map<Id,Order> oldMap = (Map<Id,Order>)Trigger.oldMap;

    public override void beforeUpdate(){
        // OrderHelper.checkOrderHasProduct(newMap, oldMap);
        OrderHelper.setNetAmount(newMap, oldMap);
    }

    public override void afterUpdate(){
        OrderHelper.setAccountRevenue(newMap, oldMap);
        OrderHelper.setAccountToActiveOnUpdate(newList, oldMap);
    }

    public override void afterInsert(){
        OrderHelper.setAccountToActive(newList);
    }

    public override void afterDelete(){
        OrderHelper.checkAccountHasOrder(oldMap);
    }
}
