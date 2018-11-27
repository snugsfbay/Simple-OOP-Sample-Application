({
	doCreate : function(component, event, helper) {
		var action = component.get("c.aSetProcurementItem");
        component.set("v.results", "TESTING");
        action.setParams({
            price : component.get("v.price"),
            itemName : component.get("v.name"),
            itemDescription : component.get("v.description"),
            minStock : component.get("v.minimumStock"),
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS"){
                component.set("v.results", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                component.set("v.resultMessage", a.getReturnValue());
                $A.log("Errors", a.getError());
            }
        });
        
        $A.enqueueAction(action);
	}
})