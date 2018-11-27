/* 

    Simple OOP Sample Application 
    by Bonny Hinners
    
    I refactored our sample Stock Item class to further demonstrate encapsulation.
    Consider which of the methods are instance methods and which are static, which code is kept private?
    
    The premise is that the procurement department will create items at the time they propose new
    stock for sale in our online pantry. They only need to insert a little data and don't need
    access to the entire Stock Item sObject or the warehouse application.    
    
    CreateItemResult is in charge of data output.  We've decided to limit that to a message and a record ID
        It also has properties that are available to our UI.
    The constructor takes a collection of data and orchestrates what happens to that data and creates the returned object
    StockRequiredFields validates required data was passed to the constructor.
    StockAllowedFields tacks on any additional fields that are not required but may have been added to the constructor parameters 
        It also inserts the data into our Stock_Item__c SObject
    CreateItemRequest is in charge of data input from Flow. 
        Lightning components are responsible for managing data input according to the parameters required for the method.
        So the Lightning component developer has to know more about our Apex code than our Flow developer.
    We have two methods just for interacting with UI.
    
    The related UI includes both a Flow and a Lightning Component, both on a Lightning Home page for demo.
    Virtually no styling was applied to the UI, keeping it as bare bones as possible so you can compare the level of effort for each.
    
    *Note that a VisualForce page could still use this code if a controller extension was added to connect the page to the code here.
    
*/

public with sharing class ProcurementItem{

    // class variables and constants, can you tell which is which?
    public static Final String MISSINGDATA = 'Data is required for this field: ';
    public static Final String MISSINGPRICE = 'Price can be $0 for free items, but some decimal value 0 or higher is required.';
    public static Final String MISSINGMINQUANT = 'Please include a minimum quantity on hand before reorders are required.';
    public static Final String INSERTEDITEM = 'Successfully created item: ';
    public CreateItemResult createResult;

    // constructor -- this is basically our mediator and determines how other methods are used and when
    public ProcurementItem(Decimal price, String itemName, String itemDescription, Integer minStock) {        
        StockRequiredFields reqFields;
        StockAllowedFields allFields; 
               
        try {
            reqFields = new StockRequiredFields (itemName, price, minStock); // check for required data
        } catch (FieldException e){
            createResult = new CreateItemResult(e.getMessage());
            return; // just pass the error to the UI and be finished
        }
        allFields = new StockAllowedFields(reqFields, itemDescription); // add allowed data and create item
        createResult = allFields.createItem();  // insert the stock item and get the results      
    }
    
    // method provides access to the class for our Lightning Component UI
    @AuraEnabled
    public static CreateItemResult aSetProcurementItem(Decimal price, String itemName, String itemDescription, Integer minStock){
        ProcurementItem pItem = new ProcurementItem(price, itemName, itemDescription, minStock);       
        return pItem.createResult;        
    } 
    
     // method provides access to the class for our Flow -- it requires Lists for parameters and return values -- can be list of 1
    @InvocableMethod(label='Create Procurement Item' description='New stock items being procured')
    public static List<CreateItemResult> iSetProcurementItem(List<CreateItemRequest> itemList){
        List<CreateItemResult> resultList = new List<CreateItemResult>();
        for (CreateItemRequest item :itemList){
            ProcurementItem pItem = new ProcurementItem(item.price, item.itemName, item.itemDescription, item.minStock);
            resultList.add(pItem.createResult);
        }
        return resultList;        
    }    
    
    // inner class (custom object) for building the information we want to pass back to the UI or other calling class, like our test class
    public class CreateItemResult{
        @AuraEnabled
        @invocableVariable
        public string message;
        @AuraEnabled
        @invocableVariable
        public id referenceID;
        
        public createItemResult(Stock_Item__c si, String msg){
            message = msg;
            referenceID = si.ID;
        }
        
        public createItemResult(String msg){
            message = msg;            
        }
    }
    
    // inner class (custom object) to collect data from the Flow UI as input
    public class CreateItemRequest{
        @invocableVariable
        public Decimal price;
        @invocableVariable
        public String itemName;
        @invocableVariable
        public String itemDescription;
        @invocableVariable
        public Integer minStock;
        

    }
    
    // inner class builds comprises all the data and submits our new Stock Item 
    private class StockAllowedFields {
        public StockRequiredFields requiredFields;
        public String description;
        public StockAllowedFields(StockRequiredFields srf, String s){
            requiredFields = srf;
            description = s;
        }
        public CreateItemResult createItem(){
            Stock_Item__c si = new Stock_Item__c();
            String msg = INSERTEDITEM +' ';            
            si.item_name__c = requiredFields.itemName;
            si.list_price__c = requiredFields.listPrice;
            si.minimum_stock_level__c = requiredFields.minimumStockNeeded;
            si.description__c = description;

            try {
                insert si;
                msg += si;
            } catch (Exception e){
                msg = e.getMessage(); // this looks for DML errors, for example
            } 
            CreateItemResult itemResult = new CreateItemResult(si, msg);
            return itemResult; 
        }
    }    

    // inner class verifies that required fields are present or throws appropriate error message (constant)
    private class StockRequiredFields {
    
        public Decimal listPrice; 
        public String itemName;
        public Integer minimumStockNeeded;
        
        public StockRequiredFields(String name, Decimal lp, Integer min){
            if (String.isBlank(name)){ // blank name not allowed
                throw new FieldException (MISSINGDATA + 'Item Name');
            }
            if (lp == null || lp<0){ // price can be zero (or negative? or blank?) but not null
                throw new FieldException (MISSINGPRICE);            
            } 
            if (min == null || min<=0){ // reorder threshold must be 0 or greater
                throw new FieldException (MISSINGMINQUANT); 
            }
            // set the property values 
            listPrice = lp;
            itemName = name;
            minimumStockNeeded = min;
        }
    
    } 
    
    // inner class allows us to have a custom exception message with a specific type: field exception
    private class FieldException extends Exception {}


}