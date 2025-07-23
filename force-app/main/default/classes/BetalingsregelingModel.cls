/**
 * Created by harm on 10/02/2025.
 */

global class BetalingsregelingModel {
    @AuraEnabled @InvocableVariable
    global Integer termijnenAantal; // Integer?

    public static BetalingsregelingModel getMock() {
        BetalingsregelingModel model = new BetalingsregelingModel();
        return model;
    }
}