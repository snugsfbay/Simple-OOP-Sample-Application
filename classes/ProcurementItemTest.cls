@isTest
public class ProcurementItemTest{

    @isTest
    static void createGoodItem(){
        ProcurementItem.CreateItemResult itemInfo = insertGoodItem();
        System.assert([SELECT Count() FROM Stock_Item__c] == 1, 'Not created');
        System.assert([SELECT id FROM Stock_Item__c Limit 1].id == itemInfo.referenceID, 'Item id does not match reference id.');
    }

    @isTest
    static void validateFields(){
        GoodItem item = new GoodItem();
        ProcurementItem.CreateItemResult itemInfo = insertGoodItem();
        Stock_Item__c si = [SELECT list_price__c, item_name__c, description__c, minimum_stock_level__c FROM Stock_Item__c Limit 1];
        System.assert(si.item_name__c == item.name, 'Not created with good name');            
    }

    @isTest
    static void validateNoDescription(){
        GoodItem item = new GoodItem();
        String description;
        ProcurementItem poi = new ProcurementItem(item.listPrice, item.name, description, item.minimumStock);
        Stock_Item__c si = [SELECT list_price__c, item_name__c, description__c, minimum_stock_level__c FROM Stock_Item__c Limit 1];
        System.assert(si.description__c == null, 'Optional description field should be null');            
    }
    
    @isTest
    static void validateNoName(){
        GoodItem item = new GoodItem();
        String name;
        ProcurementItem poi = new ProcurementItem(item.listPrice, name, item.description, item.minimumStock);
        System.assert(poi.createResult.message.contains(ProcurementItem.MISSINGDATA));
        System.assert([SELECT Count() FROM Stock_Item__c] == 0, 'Should not be created without valid price');
    }

    @isTest
    static void validateNoPrice(){
        GoodItem item = new GoodItem();
        Decimal price;
        ProcurementItem poi = new ProcurementItem(price, item.name, item.description, item.minimumStock);
        System.assert(poi.createResult.message.contains(ProcurementItem.MISSINGPRICE));
        System.assert([SELECT Count() FROM Stock_Item__c] == 0, 'Should not be created without valid name');
    }

    @isTest
    static void validateNoMinimum(){
        GoodItem item = new GoodItem();
        Integer min;
        ProcurementItem poi = new ProcurementItem(item.listPrice, item.name, item.description, min);
        System.assert(poi.createResult.message.contains(ProcurementItem.MISSINGMINQUANT));
        System.assert([SELECT Count() FROM Stock_Item__c] == 0, 'Should not be created without valid minimum quantity');
    }

    @isTest
    static void validateInvalidMinimum(){
        GoodItem item = new GoodItem();
        Integer min = 0;
        ProcurementItem poi = new ProcurementItem(item.listPrice, item.name, item.description, min);
        System.assert(poi.createResult.message.contains(ProcurementItem.MISSINGMINQUANT));
        System.assert([SELECT Count() FROM Stock_Item__c] == 0, 'Should not be created with invalid minimum quantity');
    }

    @isTest
    static void aSetProcurmentItem(){
        GoodItem item = new GoodItem();
        ProcurementItem.CreateItemResult results = ProcurementItem.aSetProcurementItem(item.listPrice, item.name, item.description, item.minimumStock);
        System.assert(results.message.contains(ProcurementItem.INSERTEDITEM));
    }

    @isTest
    static void iSetProcurmentItem(){
        List<ProcurementItem.CreateItemRequest> itemList = new List<ProcurementItem.CreateItemRequest>{goodRequest()};
        List<ProcurementItem.CreateItemResult> resultsList = ProcurementItem.iSetProcurementItem(itemList);
        System.assert(resultsList[0].message.contains(ProcurementItem.INSERTEDITEM));
    }    
    
    static ProcurementItem.CreateItemResult insertGoodItem(){
        GoodItem item = new GoodItem();
        ProcurementItem itemResult = new ProcurementItem(item.listPrice, item.name, item.description, item.minimumStock);
        ProcurementItem.CreateItemResult results = itemResult.createResult;
        System.assert(results.message.contains(ProcurementItem.INSERTEDITEM));
        return results;    
    } 
    
 

    static ProcurementItem.CreateItemRequest goodRequest(){
        GoodItem testData = new GoodItem();
        ProcurementItem.CreateItemRequest item = new ProcurementItem.CreateItemRequest();
        item.price = testData.listPrice;
        item.itemName = testData.name;
        item.itemDescription = testData.description;
        item.minStock = testData.minimumStock;
        system.debug(item);
        return item;
    }  
    
    private class GoodItem{
        String name = 'good item name';
        String description = 'this is a really good item description';
        Decimal listPrice = 47.55;
        Integer minimumStock = 5;
    }
    


}