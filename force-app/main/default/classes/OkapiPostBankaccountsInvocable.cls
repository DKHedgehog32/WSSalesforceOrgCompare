/**
 * Invocable for the POST Bankgegevens
 */

public with sharing class OkapiPostBankaccountsInvocable {
    @InvocableMethod(Description='Create bank accounts on the Okapi service' Label='Post Bank Accounts')
    public static void postBankAccounts(List<BetaalgegevenModel> bankAccounts) {
        OkapiClient.upsertBankGegevens(bankAccounts, 'POST');
    }
}