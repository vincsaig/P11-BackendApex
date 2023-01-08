@isTest
private class Order_Test {
    @TestSetup
    static void createData(){
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        Contract contract = new Contract(
                                            AccountId = acc1.Id,
                                            Status = 'Draft',
                                            StartDate = Date.today(),
                                            ContractTerm = 1
                                        );
        insert contract;

        contract.Status = 'Activated';

        update contract;

        List<Order> ordersList = new List<Order>();
        for(Integer i = 0; i < 200; i++){
            Order order = new Order(AccountId = acc1.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), ContractId = contract.Id);
            ordersList.add(order);
        }
        insert ordersList;

        List<OrderItem> ois = new List<OrderItem>();
        for(Order order : ordersList){
            OrderItem oi1 = new OrderItem (OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
            OrderItem oi2 = new OrderItem (OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
            ois.add(oi1);
            ois.add(oi2);
        }

        insert ois;
    }

    @isTest
    static void testCheckOrderHasProduct(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Order order = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), ContractId = contract.Id, ShippingCity = 'test1');

        insert order;

        Boolean exceptionThrown = false;
        test.startTest();
        try{
            order.Status = 'Activated';
            update order;
        } 
        catch(DmlException e){
            exceptionThrown = true;
        }
        test.stopTest();
        System.assertEquals(true,exceptionThrown,'An exception should have been thrown');

        order = [SELECT Id,Status FROM Order WHERE ShippingCity = 'test1'];

        System.assertEquals('Draft', order.Status, 'The order\'s status should still be Draft');
    }

    @isTest
    static void testAccountHasOrder(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id, Active__c FROM Account LIMIT 1];

        System.assertEquals(true,acc.Active__c,'Account should be active before deleting order');
        test.startTest();
        delete order;
        test.stopTest();

        acc = [SELECT Id, Active__c FROM Account LIMIT 1];
        System.assertEquals(true, acc.Active__c, 'Account should be active as 1 out of 200 orders has been deleted');
    }

    @isTest
    static void testAccountDeleteAllOrders(){
        List<Order> orders = [SELECT Id FROM Order];
        Account acc = [SELECT Id, Active__c FROM Account LIMIT 1];

        System.assertEquals(true, acc.Active__c, 'Account should be active before deleting all its orders');

        test.startTest();
        delete orders;
        test.stopTest();

        acc = [SELECT Id, Active__c FROM Account LIMIT 1];
        System.assertEquals(false, acc.Active__c, 'Account should not be active as all its orders have been deleted');
    }

    @isTest
    static void testBatch02AccountWithoutOrder(){
        Account acc = new Account(Name = 'Batch02AccountWithoutOrder');
        insert acc;
        test.startTest();
        Database.executeBatch(new Batch02AccountWithoutOrderOrTask());
        test.stopTest();

        Task task = [SELECT Id,ReminderDateTime FROM Task WHERE WhatId = :acc.Id];
        System.assertNotEquals(null, task, 'A task should have been created');
        System.assertEquals(Date.today().addDays(5), task.ReminderDateTime, 'The reminder should be 5 days from now');
    }

    @isTest
    static void testAccountSetToActiveOnOrderAdd(){
        Account acc = new Account(Name = 'testAccountSetToActiveOnOrderAdd');

        insert acc;
        Contract contract = new Contract(
            AccountId = acc.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 1
        );
        insert contract;
        contract.Status = 'Activated';
        update contract;

        Order order = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), ContractId = contract.Id);

        test.startTest();
        insert order;
        test.stopTest();

        acc = [SELECT Id, Active__c FROM Account WHERE Name = 'testAccountSetToActiveOnOrderAdd'];
        System.assertEquals(true, acc.Active__c,'Account should be active');
    }
}
