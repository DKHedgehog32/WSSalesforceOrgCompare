public class TestEvent implements Database.Batchable<sObject> ,   Database.AllowsCallouts {
	public String query = 'SELECT Id, External_Id__c FROM Account WHERE IsPersonAccount=true AND FirstName=\'\' ORDER BY External_Id__c ASC LIMIT 100';
   	public Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator(query);
   	}

   	public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<PersoonModel> personenToRequest = new List<PersoonModel>();
        for(SObject s : scope) {
            Account acc = (Account) s;
            PersoonModel pm = new PersoonModel();
            pm.id = acc.External_Id__c;
            pm.idAdministratie = 'WOCAS';
            personenToRequest.add(pm);
        }
        System.Debug('## request '+JSON.serializePretty(personenToRequest));
        DateTime endValue = System.now().addSeconds(1);
        while(System.now()<endValue) {
            
        }
        List<OkapiResponseModel> responses = OkapiClient.requestPersonsPush(personenToRequest);
        System.Debug('## response '+JSON.serializePretty(responses));
    }

   	public void finish(Database.BatchableContext bc){
   	}
}