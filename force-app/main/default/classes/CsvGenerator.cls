/**
 * Created by harm on 04/04/2025.
 * AccountContactRelations
 * Primary_Account_In_Relationships__r
 * Subsidiary_Account_In_Relationships__r
 * Account_Addresses__r
 */

public with sharing class CsvGenerator {
    public static void generateCsv(List<Id> contractLineIds) {
        String accountFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Account');
        String contractLineFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Contract_Line__c');
        String bankAccountFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Bank_Account__c');
        String realEstateContractFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Real_Estate_Contract__c');
        String addressFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Address__r');
        String accountAddressFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Account_Address__c');
        String contractUnitFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Contract_Unit__c');
        String clusterFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Cluster__c');
        String clusterUnitFieldClause = SchemaUtil.allWriteableFieldsCommaSeparated('Cluster_Unit__c');

        //
        // Contract Lines
        Map<String, Object> contractLineBinds = new Map<String, Object>{'recIds' => contractLineIds};
        List<Contract_Line__c> contractLines = (List<Contract_Line__c>) Database.queryWithBinds('SELECT '+contractLineFieldClause+' FROM Contract_Line__c WHERE Id IN :recIds',
                                                    contractLineBinds,
                                                    AccessLevel.SYSTEM_MODE);
        //
        // Collect
        // - Account Ids
        // - Real Estate Contract Ids
        // - Bank account ids
        // - Contract Unit Ids
        Set<Id> accIds = new Set<Id>();
        Set<Id> recIds = new Set<Id>();
        Set<Id> bacIds = new Set<Id>();
        Set<Id> cutIds = new Set<Id>();

        for(Contract_Line__c line : contractLines) {
            accIds.add(line.Account__c);
            recIds.add(line.Real_Estate_Contract__c);
            cutIds.add(line.Contract_Unit__c);
        }
        String contractLineCsv = convertToCsv('Contract_Line__c',contractLines);
        insert getContentVersion('Contract_Line__c.csv', Blob.valueOf(contractLineCsv), 'Contract_Line__c.csv');

        //
        // Real Estate Contracts
        Map<String, Object> recBinds = new Map<String, Object>{'recIds' => recIds};
        List<Real_Estate_Contract__c> recs = (List<Real_Estate_Contract__c>) Database.queryWithBinds('SELECT '+realEstateContractFieldClause+' FROM Real_Estate_Contract__c WHERE Id IN :recIds',
                recBinds,
                AccessLevel.SYSTEM_MODE);
        //
        // Enrich accIds with Contract_Party__c
        for(Real_Estate_Contract__c aRec : recs) {
            accIds.add(aRec.Contract_Party__c);
            bacIds.add(aRec.Bank_Account__c);
        }
        String recsCsv = convertToCsv('Real_Estate_Contract__c',recs);
        insert getContentVersion('Real_Estate_Contract__c.csv', Blob.valueOf(recsCsv), 'Real_Estate_Contract__c.csv');

        //
        // Accounts
        Map<String, Object> accountBinds = new Map<String, Object>{'recIds' => accIds};
        List<Account> accounts = (List<Account>) Database.queryWithBinds('SELECT '+accountFieldClause+' FROM Account WHERE Id IN :recIds',
                accountBinds,
                AccessLevel.SYSTEM_MODE);
        String accountCsv = convertToCsv('Account',accounts);
        insert getContentVersion('Account.csv', Blob.valueOf(accountCsv), 'Account.csv');

        //
        // Bank Accounts
        Map<String, Object> bankAccountBinds = new Map<String, Object>{'recIds' => bacIds};
        List<Bank_Account__c> bAccounts = (List<Bank_Account__c>) Database.queryWithBinds('SELECT '+bankAccountFieldClause+' FROM Bank_Account__c WHERE Id IN :recIds',
                bankAccountBinds,
                AccessLevel.SYSTEM_MODE);
        String bacCsv = convertToCsv('Bank_Account__c',bAccounts);
        insert getContentVersion('Bank_Account__c.csv', Blob.valueOf(bacCsv), 'Bank_Account__c.csv');


        //
        // Contract Units
        Map<String, Object> contractUnitBinds = new Map<String, Object>{'recIds' => bacIds};
        List<Contract_Unit__c> contractUnits = (List<Contract_Unit__c>) Database.queryWithBinds('SELECT '+contractUnitFieldClause+' FROM Contract_Unit__c WHERE Id IN :recIds',
                contractUnitBinds,
                AccessLevel.SYSTEM_MODE);
        String cutCsv = convertToCsv('Contract_Unit__c',contractUnits);
        insert getContentVersion('Contract_Unit__c.csv', Blob.valueOf(cutCsv), 'Contract_Unit__c.csv');

    }
    public static String convertToCsv(String sobjectName, List<SObject> records) {
        String csvDataRows = '';
        String headerRow = '';
        for(String fieldName : SchemaUtil.getWritableFieldList(sobjectName)) {
            headerRow += '"'+fieldName+'",';
        }
        headerRow = headerRow.substring(0, headerRow.length()-1)+'\n';

        for(SObject oneRow : records) {
            for(String fieldName : SchemaUtil.getWritableFieldList(sobjectName)) {
                if(oneRow.get(fieldName) == null) {
                    csvDataRows += '"",';
                } else {
                    csvDataRows += '"'+oneRow.get(fieldName)+'",';

                }
            }
            csvDataRows = csvDataRows.substring(0, csvDataRows.length()-1)+'\n';
        }
        String csvData = headerRow+csvDataRows+'\n';
        return csvData;
    }
    private static ContentVersion getContentVersion(String fileName, Blob contentData, String pathName) {
        ContentVersion versionRecord = new ContentVersion();
        versionRecord.VersionData = contentData;
        versionRecord.Title = fileName;
        versionRecord.PathOnClient = pathName;
        return versionRecord;
    }
}