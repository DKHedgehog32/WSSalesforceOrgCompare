/**
 * Address management / utility functions
 */
public with sharing class AddressService {
    public static void setPrimaryAddressInStandardFields(Account acc) {
        acc.BillingCity = acc.Full_Billing_City__c;
        acc.BillingCountryCode = acc.Full_Billing_Country__c;
        acc.BillingPostalCode = acc.Full_Billing_Postal_Code__c;
        acc.BillingStreet = acc.Full_Billing_Street__c;
        //acc.BillingState = acc.Full_Billing_Provence__c;
        acc.ShippingCity = acc.Full_Shipping_City__c;
        acc.ShippingCountryCode = acc.Full_Shipping_Country__c;
        acc.ShippingPostalCode = acc.Full_Shipping_Postal_Code__c;
        acc.ShippingStreet = acc.Full_Shipping_Street__c;
        //acc.ShippingState = acc.Full_Shipping_Provence__c;
    }
    //
    // Retrieves all Account addresses for a uuid and returns them as PersoonAddressModel entries
    public static List<PersoonAdresModel> getPersoonAddressen(String uuid) {
        List<PersoonAdresModel> output = new List<PersoonAdresModel>();
        List<Account_Address__c> accountAddressRecords = [SELECT
                Account__r.UUID__c, Account__r.Primary_Billing_Address__r.Unique_Key__c, Account__r.Primary_Shipping_Address__r.Unique_Key__c,
                Address__r.Province__c, Address__r.Unique_Key__c, Address__r.Name, Address__r.PO_Box_Number__c, Address__r.Postal_Code__c,
                Address__r.Freepost_number__c, Address__r.Street__c, Address__r.Country__c, Address__r.House_Letter__c, Address__r.Address_Line_2__c,
                Address__r.House_Number_Addition__c, Address__r.House_Number__c, Address__r.City__c, Address__r.Address_Line_1__c, Address__r.Denotation__c,
                Start_Date__c, End_Date__c, Is_Primary__c, Type__c, Deduplication_Key__c
                FROM Account_Address__c
                WHERE Account__r.UUID__c = :uuid.trim()
                ORDER BY Start_Date__c ASC];
        for(Account_Address__c acadd : accountAddressRecords) {
            output.add(DataMapper.mapAddressToPersoonAdresModel(acadd));
        }
        return output;
    }

    //
    // Strips spaces from postal code
    public static void normalizePostalCodesByReference(Address__c addressRecord) {
        if(String.isEmpty(addressRecord.Postal_Code__c)) {
            return;
        }
        addressRecord.Postal_Code__c = addressRecord.Postal_Code__c.replaceAll(' ','');
    }
    //
    // Strips spaces from postal code
    public static void normalizePostalCodesByReference(AdresModel addressRecord) {
        if(String.isEmpty(addressRecord.postcode)) {
            return;
        }
        addressRecord.postcode = addressRecord.postcode.replaceAll(' ','');
    }
    //
    // Constructs a unique key value for an address record
    public static String getAddressKey(Address__c addressRecord) {
        normalizePostalCodesByReference(addressRecord);
        String country = (addressRecord.Country__c <> null) ? addressRecord.Country__c : 'NL';

        if(country<>'NL') {
            //
            // Foreign addresses can be anything
            return addressRecord.Country__c+'-'+Datetime.now().getTime();
        }
        String postalCode = (addressRecord.Postal_Code__c <> null) ? addressRecord.Postal_Code__c.trim() : '';
        String housenumber = (addressRecord.House_Number__c <> null) ? addressRecord.House_Number__c.trim() : '';
        String housenumberAddition = (addressRecord.House_Number_Addition__c <> null) ? addressRecord.House_Number_Addition__c.trim() : '';
        String houseletter = (addressRecord.House_Letter__c <> null) ? addressRecord.House_Letter__c.trim() : '';
        String poBoxNr = (addressRecord.PO_Box_Number__c <> null) ? addressRecord.PO_Box_Number__c.trim(): '';
        String antwNr = (addressRecord.Freepost_number__c <> null) ? addressRecord.Freepost_number__c.trim(): '';

        return getUniqueAddressKey(postalCode, poBoxNr, antwNr, housenumber, houseletter, housenumberAddition);
    }
    public static String getAddressKey(AdresModel addressRecord) {
        normalizePostalCodesByReference(addressRecord);
        String country = (addressRecord.land?.code <> null) ? addressRecord.land.code : 'NL';

        if(country<>'NL') {
            //
            // We don't want to make foreign addresses unique
            return null;
        }
        String postalCode = (addressRecord.postcode <> null) ? addressRecord.postcode.trim() : '';
        String housenumber = (addressRecord.huisnummer <> null) ? addressRecord.huisnummer.trim() : '';
        String housenumberAddition = (addressRecord.huisnummerToevoeging <> null) ? addressRecord.huisnummerToevoeging.trim() : '';
        String houseletter = (addressRecord.huisletter <> null) ? addressRecord.huisletter.trim() : '';
        String poBoxNr = (addressRecord.postbusnummer <> null) ? addressRecord.postbusnummer.trim(): '';
        String antwNr = (addressRecord.antwoordnummer <> null) ? addressRecord.antwoordnummer.trim(): '';


        return getUniqueAddressKey(postalCode, poBoxNr, antwNr, housenumber, houseletter, housenumberAddition);
    }
    //
    // Applies https://www.postnl.nl/Images/Brochure-KIX-code-van-PostNL_tcm10-10210.pdf
    public static String getUniqueAddressKey(String postalCode, String poBoxNr, String antwNr, String housenumber, String houseletter, String housenumberAddition) {
        String keyValue;
        //
        // This mechanism may not be the most robust,
        // perhaps a checkbox to indicate pobox/freepost addresses will be better
        // For now catch illegal combinations on the front end
        if(!String.isEmpty(poBoxNr)) {
            keyValue = postalCode+poBoxNr;

        } else if(!String.isEmpty(antwNr)) {
            keyValue = postalCode+antwNr;
        } else {
            keyValue = postalCode+housenumber+'X'+houseletter+housenumberAddition;
        }

        return keyValue;
    }
    //
    // Constructs a readable name
    public static String getNameValue(Address__c addressRecord) {
        normalizePostalCodesByReference(addressRecord);
        String country = (addressRecord.Country__c <> null) ? addressRecord.Country__c : '';
        String city = (addressRecord.City__c <> null) ? addressRecord.City__c : '';
        String street = (addressRecord.Street__c <> null) ? addressRecord.Street__c : '';
        String postalCode = (addressRecord.Postal_Code__c <> null) ? addressRecord.Postal_Code__c : '';
        String housenumber = (addressRecord.House_Number__c <> null) ? addressRecord.House_Number__c : '';
        String housenumberAddition = (!String.isEmpty(addressRecord.House_Number_Addition__c)) ? ' '+addressRecord.House_Number_Addition__c : '';
        String houseletter = (!String.isEmpty(addressRecord.House_Letter__c)) ? ' '+addressRecord.House_Letter__c : '';
        String addressLine1 = (addressRecord.Address_Line_1__c <> null) ? addressRecord.Address_Line_1__c : '';
        String addressLine2 = (addressRecord.Address_Line_2__c <> null) ? addressRecord.Address_Line_2__c : '';

        String nameValue ='';
        if(country=='NL') {
            if(!String.isBlank(addressRecord.Freepost_number__c)) {
                nameValue = 'Antwoordnummer '+addressRecord.Freepost_number__c+' '+city+', '+country;
            } else if(!String.isBlank(addressRecord.PO_Box_Number__c)) {
                nameValue = 'Postbus '+addressRecord.PO_Box_Number__c+' '+city+', '+country;

            } else {
                nameValue = street+' '+housenumber+''+houseletter+''+housenumberAddition+', '+city+', '+country;
            }
        } else {
            nameValue = addressLine1+' '+addressLine2+', '+city+', '+country;
        }
        return nameValue.abbreviate(80);
    }

    //
    // Bulk entry points
    public static List<String> getAddressKeys(List<Address__c> addresses) {
        List<String> output = new List<String>();
        for(Address__c add : addresses) {
            output.add(getAddressKey(add));
        }
        return output;
    }
    public static List<String> getNameValues(List<Address__c> addresses) {
        List<String> output = new List<String>();
        for(Address__c add : addresses) {
            output.add(getNameValue(add));
        }
        return output;
    }
    public static void normalizePostalCodesByReference(List<Address__c> addresses) {
        for(Address__c add : addresses) {
            normalizePostalCodesByReference(add);
        }
    }
    public static void normalizePostalCodesByReference(List<AdresModel> addresses) {
        for(AdresModel add : addresses) {
            normalizePostalCodesByReference(add);
        }
    }
    //
    // Handles upsert of the address records and creation of the junction records
    public static List<Account_Address__c> convertPersoonAddresses(PersoonModel persoon, String uuid) {
        //
        // Handle addresses
        // Put in map with unique index to avoid dupes in list
        Map<String, Address__c> addressesforUpsert = new Map<String, Address__c>();
        List<Address__c> addressesforInsert = new List<Address__c>();
        Address__c addShipping;
        Address__c addBilling;
        //
        // Add the address records and link them appropriately to the account
        if(persoon.woonadres<>null) {
            addShipping = DataMapper.mapPersoonAdresToAddress(persoon.woonadres);
            if(addShipping.Unique_Key__c<> null) {
                addressesforUpsert.put(addShipping.Unique_Key__c.toLowerCase(), addShipping);

            } else {
                addressesforInsert.add(addShipping);
            }

        }
        if(persoon.postadres<>null) {
            addBilling = DataMapper.mapPersoonAdresToAddress(persoon.postadres);
            if(addBilling.Unique_Key__c<> null) {
                addressesforUpsert.put(addBilling.Unique_Key__c.toLowerCase(), addBilling);

            } else {
                addressesforInsert.add(addBilling);
            }
        }
        //
        // Store the address record(s)
        if(addressesforUpsert.size() > 0) {
            System.debug('#### Upserting addresses: '+JSON.serializePretty(addressesforUpsert.values()));
            upsert addressesforUpsert.values() Address__c.Unique_Key__c;
        }
        if(addressesforInsert.size() > 0) {
            System.debug('#### Inserting addresses: '+JSON.serializePretty(addressesforInsert));
            insert addressesforInsert;
        }
        //
        // Construct the Account Address junction(s)
        Map<String, Account_Address__c> dedupeMap = new Map<String, Account_Address__c>();
        if(addShipping <> null) {
            //
            // Only a shipping
            Address__c add1 = addressesforUpsert.get(addShipping.Unique_Key__c.toLowerCase());
            Account_Address__c shippAccAddress = AddressService.getAccountAddressForUpsert(uuid, add1);
            shippAccAddress.Type__c = 'WOO';
            if(persoon.woonadres.begindatum <> null) {
                shippAccAddress.Start_Date__c = persoon.woonadres.begindatum;

            }
            if(persoon.woonadres.einddatum <> null) {
                shippAccAddress.End_Date__c = persoon.woonadres.einddatum;
            }
            //
            // Coming from persoon this is the primary
            shippAccAddress.Is_Primary__c = true;
            shippAccAddress.Deduplication_Key__c = createCompositeKey(shippAccAddress, uuid, addShipping.Unique_Key__c);

            dedupeMap.put(shippAccAddress.Deduplication_Key__c, shippAccAddress);
        }
        if(addBilling <> null) {
            //
            // Only a billing
            Address__c add2 = addressesforUpsert.get(addBilling.Unique_Key__c.toLowerCase());
            Account_Address__c billAccAddress = AddressService.getAccountAddressForUpsert(uuid, add2);
            billAccAddress.Type__c = 'POS';
            if(persoon.postadres.begindatum <> null) {
                billAccAddress.Start_Date__c = persoon.postadres.begindatum;
            }
            if(persoon.postadres.einddatum <> null) {
                billAccAddress.End_Date__c = persoon.postadres.einddatum;
            }

            //
            // Coming from persoon this is the primary
            billAccAddress.Is_Primary__c = true;
            billAccAddress.Deduplication_Key__c = createCompositeKey(billAccAddress, uuid, addBilling.Unique_Key__c);
            dedupeMap.put(billAccAddress.Deduplication_Key__c, billAccAddress);
        }
        return dedupeMap.values();
    }
    public static Account_Address__c convertPersoonAddress(PersoonAdresModel addressModel, String uuid) {

        //
        // Handle addresses
        // Put in map with unique index to avoid dupes in list
        Map<String, Address__c> addressesforUpsert = new Map<String, Address__c>();
        Address__c theAddress = DataMapper.mapPersoonAdresToAddress(addressModel);
        addressesforUpsert.put(theAddress.Unique_Key__c, theAddress);

        //
        // Store the address record(s)
        if(addressesforUpsert.size() > 0) {
            upsert addressesforUpsert.values() Address__c.Unique_Key__c;
        }
        //
        // Construct the junction
        Account_Address__c accAddress = AddressService.getAccountAddressForUpsert(uuid, theAddress);
        accAddress.Start_Date__c = addressModel.begindatum;
        accAddress.End_Date__c = addressModel.einddatum;
        accAddress.Type__c = addressModel.soort.code;
        accAddress.Deduplication_Key__c = createCompositeKey(accAddress, uuid, theAddress.Unique_Key__c);
        return accAddress;
    }
    @TestVisible
    private static Account_Address__c getAccountAddressForUpsert(String accountUuid, Address__c addressRecord) {
        System.assertNotEquals(null, addressRecord?.Id, 'Address needs an id');
        System.assertNotEquals(null, accountUuid, 'UUID mandatory');
        Account_Address__c accAd = new Account_Address__c();
        accAd.Address__c = addressRecord.Id;
        accAd.Account__r = new Account(UUID__c=accountUuid);
        accAd.Is_Primary__c = true;
        return accAd;
    }
    private static String createCompositeKey(Account_Address__c input, String personUuid, String addressId) {
        String output = personUuid+'-'+addressId+'-'+IdentifierService.getDateStamp(input.Start_Date__c)+'-'+input.Type__c;
        return output;
    }
    //
    // For bulk/trigger use. Fills by reference
    public static void fillCompositeKeys(List<Account_Address__c> adds) {
        Set<ID> accIds = new Set<ID>();
        for(Account_Address__c aa : adds) {
            accIds.add(aa.Account__c);
        }
        Set<ID> addressIds = new Set<ID>();
        for(Account_Address__c aa : adds) {
            addressIds.add(aa.Address__c);
        }
        Map<ID, Account> accMap = new Map<ID, Account>([SELECT Id, UUID__c FROM Account WHERE Id IN :accIds]);
        Map<ID, Address__c> addrMap = new Map<ID, Address__c>([SELECT Id, Unique_Key__c FROM Address__c WHERE Id IN :addressIds]);
        for(Account_Address__c aa : adds) {
            if(String.isEmpty(aa.Deduplication_Key__c)) {
                String uuid = accMap.get(aa.Account__c)?.UUID__c;
                String addId = addrMap.get(aa.Address__c)?.Unique_Key__c;
                aa.Deduplication_Key__c = createCompositeKey(aa, uuid, addId);
            }
        }
    }
}