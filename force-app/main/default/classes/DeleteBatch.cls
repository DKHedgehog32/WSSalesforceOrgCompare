/**
 * Batch to delete a lot of data, based on SOQL query
 * Example: DeleteBatch.startBatch('SELECT Id FROM Account WHERE Name LIKE \'Test%\' LIMIT 200');
 */

public class DeleteBatch implements Database.Batchable<SObject> {
    public String query;
    public static void startBatch(String query) {
        if(String.isEmpty(query)) {
            throw new DeleteBatchException();
        }
        DeleteBatch db = new DeleteBatch();
        db.query = query;
        Database.executeBatch(db);
    }
    public Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope){

        delete scope;
    }

    public void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest() && Database.query(this.query)?.size() > 0) {
            startBatch(this.query);
        }
    }
    public class DeleteBatchException extends Exception {

    }
}