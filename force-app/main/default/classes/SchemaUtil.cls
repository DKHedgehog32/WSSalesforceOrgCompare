global class SchemaUtil {
    global static String allWriteableFieldsCommaSeparated(String sobjectName) {
        String output = '';
        Set<String> allFields = getWritableFieldList(sobjectName);
        for(String fieldName : allFields) {
            if(fieldName.toLowerCase()=='id') {
                continue; // Adding Id at the end; saves the comma hassle
            }
            output += fieldName+', ';
        }
        output += 'Id';
        return output;
    }

    global static String allFieldsCommaSeparated(String sobjectName) {
        String output = '';
        Set<String> allFields = getFieldList(sobjectName);
        for(String fieldName : allFields) {
            if(fieldName.toLowerCase()=='id') {
                continue; // Adding Id at the end; saves the comma hassle
            }
            output += fieldName+', ';
        }
        output += 'Id';
        return output;
    }

    global static String allFieldsCommaSeparated(String sobjectName, Set<String> onlyIn) {
        String output = '';
        //Set<String> allFields = getFieldList(sobjectName);
        for(String fieldName : onlyIn) {
            if(!fieldExists(sobjectName, fieldName.toLowerCase())) {
                continue;
            }
            if(fieldName.toLowerCase()=='id') {
                continue; // Adding Id at the end; saves the comma hassle
            }
            output += fieldName+', ';
        }
        output += 'Id';
        return output;
    }

    //
    // Returns the name of the SObject based on provided Id
    global static String getSobjectName(ID recordId) {
        if(recordId == null) {
            throw new SchemaUtilException('Need id '+recordId);
        }
        return recordId.getSobjectType().getDescribe().getLocalName();
    }
    //
    // Checks if a field exists on an sobject
    global static Boolean fieldExists(String objectName, String fieldName) {
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sot =  allObj.get(objectName);
            Map<String,Schema.SObjectField> fieldMap = sot.getDescribe().fields.getMap();
            return fieldMap.containsKey(fieldName);
        } else {
            return false;
        }
    }
    global static Map<String,Schema.SObjectField> getFieldMap(String objectName) {
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sot =  allObj.get(objectName);
            Map<String,Schema.SObjectField> fieldMap = sot.getDescribe().fields.getMap();
            return fieldMap;
        } else {
            return null;
        }
    }
    global static Schema.SObjectField getFieldToken(String objectName, String fieldName) {
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sot =  allObj.get(objectName);
            Map<String,Schema.SObjectField> fieldMap = sot.getDescribe().fields.getMap();
            if(fieldMap.containsKey(fieldName)) {
                return fieldMap.get(fieldName);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
    global static Set<String> getFieldList(String objectName) {
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sot =  allObj.get(objectName);
            return sot.getDescribe().fields.getMap().keySet();
        } else {
            return new Set<String>();
        }
    }
    global static Set<String> getWritableFieldList(String objectName) {
        Set<String> output = new Set<String>();
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sot =  allObj.get(objectName);
            for(Schema.SObjectField field : sot.getDescribe().fields.getMap().values()) {
                if(!field.getDescribe().isCreateable()) {
                    continue;
                }
                output.add(field.getDescribe().name);
            }

        } else {
            return new Set<String>();
        }
        return output;
    }
    global static Boolean objectExists(String objectName) {
        return getAllObjects().containsKey(objectName);
    }
    //
    // Map child relation to SObject names
    global static Map<String, String> relationToSobject(String objectName) {
        Map<String, String> relToSobjectMap = new Map<String, String>();
        if(getAllObjects().containsKey(objectName)) {
            Schema.DescribeSObjectResult sor = getAllObjects().get(objectName).getDescribe();
            List<Schema.ChildRelationship> relations = sor.getChildRelationships();
            for(Schema.ChildRelationship rel : relations) {
                if(rel.getRelationshipName() == null) {
                    continue;
                }
                relToSobjectMap.put(rel.getRelationshipName().toLowerCase(), rel.getChildSObject().getDescribe().getName().toLowerCase());
            }
        }
        return relToSobjectMap;
    }
    global static String getRelatedFieldName(String objectName, String relationName) {
        Map<String, String> relToSobjectMap = relationToSobject(objectName);
        Schema.DescribeSObjectResult sor = getAllObjects().get(objectName).getDescribe();
        List<Schema.ChildRelationship> relations = sor.getChildRelationships();
        for(Schema.ChildRelationship rel : relations) {
            if(rel.getRelationshipName() == null) {
                continue;
            }
            if(rel.getRelationshipName().toLowerCase() == relationName.toLowerCase()) {
                System.debug('### CHILD REL '+rel.getField().getDescribe()); //getRelationshipName()
                return rel.getField().getDescribe().getName();
            }
        }
        return null;
    }
    global static Schema.DescribeFieldResult getRelatedFieldToken(String objectName, String relationName) {
        Map<String, String> relToSobjectMap = relationToSobject(objectName);
        Schema.DescribeSObjectResult sor = getAllObjects().get(objectName).getDescribe();
        List<Schema.ChildRelationship> relations = sor.getChildRelationships();
        for(Schema.ChildRelationship rel : relations) {
            if(rel.getRelationshipName() == null) {
                continue;
            }
            if(rel.getRelationshipName().toLowerCase() == relationName.toLowerCase()) {
                //System.debug('### CHILD REL '+rel.getField().getDescribe()); //getRelationshipName()
                return rel.getField().getDescribe();//.getName();
            }
        }
        return null;
    }
    global static Map<String, String> relationToSobject(String objectName, Set<String> onlyIn) {
        Map<String, String> relToSobjectMap = new Map<String, String>();
        if(getAllObjects().containsKey(objectName)) {
            Schema.DescribeSObjectResult sor = getAllObjects().get(objectName).getDescribe();
            List<Schema.ChildRelationship> relations = sor.getChildRelationships();
            for(Schema.ChildRelationship rel : relations) {
                if(rel.getRelationshipName() == null) {
                    continue;
                }
                if(onlyIn.contains(rel.getRelationshipName())) {
                    relToSobjectMap.put(rel.getRelationshipName(), rel.getChildSObject().getDescribe().getName());
                }
            }
        }
        return relToSobjectMap;
    }

    global static Map<String, Schema.SObjectType> getAllObjects() {
        return Schema.getGlobalDescribe();
    }
    global static Map<String, Schema.SObjectType> getAllCreatableObjects() {

        Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
        List<String> typeNames = New List<String>();
        //
        // Filter out knowledge article types
        // They kill the describe call
        for(String objName : allObjects.keySet()) {
            if(!objName.endsWith('__kav')) {
                typeNames.add(objName);
            }
        }
        Schema.DescribeSObjectResult[] descRes = Schema.describeSObjects(typeNames);

        Map<String, Schema.SObjectType> output = new Map<String, Schema.SObjectType>();
        for(Schema.DescribeSObjectResult objDesc : descRes) {
            if(objDesc.isCreateable() && objDesc.isAccessible()) {
                output.put(objDesc.getName(), objDesc.getSobjectType());
            }
        }
        return output;
    }
    global static SObject getSobInstance(String objectName) {
        //System.Debug('#### Instantiating '+objectName);
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sobType = allObj.get(objectName);
            return sobType.newSObject();
        } else {
            return null;
        }
    }

    public static SObject getSobInstance(String objectName, ID theId) {
        //System.Debug('#### Instantiating '+objectName+', with Id '+theId);
        Map<String, Schema.SObjectType> allObj = getAllObjects();
        if(allObj.containsKey(objectName)) {
            Schema.SObjectType sobType = allObj.get(objectName);
            return sobType.newSObject(theId);
        } else {
            return null;
        }
    }
    //
    // Maps Sobjects to keyprefixes
    global static Map<String, String> sobjectKeyPrefixMap {
        get {
            if(sobjectKeyPrefixMap == null) {
                sobjectKeyPrefixMap = new Map<String, String>();
                Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
                List<String> typeNames = New List<String>();
                //
                // Filter out knowledge article types
                // They kill the describe call
                for(String objName : allObjects.keySet()) {
                    if(!objName.endsWith('__kav')) {
                        typeNames.add(objName);
                    }
                }
                List<Schema.DescribeSObjectResult> typeList = Schema.describeSObjects(typeNames);
                for(Schema.DescribeSObjectResult res : typeList) {
                    sobjectKeyPrefixMap.put(res.getKeyPrefix(),res.getName());
                }
            }
            return sobjectKeyPrefixMap;
        }
        set;
    }
    global static void setFieldValue(SObject s, String fieldName, Object fieldValueIn, Map<String, Schema.SObjectField> sofMap) {
        String fieldValue = String.valueOf(fieldValueIn);
        if(String.isEmpty(fieldName) || s == null || sofMap == null) {
            throw new SchemaUtilException('Missing required arguments for setting Sobject value');
        }
        if(sofMap.containsKey(fieldName) && !String.isEmpty(fieldValue)) {
            Schema.DescribeFieldResult fieldDesc = sofMap.get(fieldName).getDescribe();
            if(fieldName.toLowerCase() <> 'id' && !fieldDesc.isCreateable()) {
                return;
            }
            Schema.DisplayType fieldType = fieldDesc.getType();
            //System.Debug('### FIELD TYPE '+fieldType);

            //
            // Set correct type
            if(fieldType == Schema.DisplayType.ADDRESS) {
                // Unsupported
            }
            if(fieldType == Schema.DisplayType.ANYTYPE) {
                //
                // Unsupported
                //s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.BASE64) {
                //
                // Don't think we will ever get blobs.
                //s.put(fieldName, Blob.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.BOOLEAN) {
                s.put(fieldName, Boolean.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.COMBOBOX) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.COMPLEXVALUE) {
                // Formula  ? ... Readonly
            }
            if(fieldType == Schema.DisplayType.CURRENCY) {
                //s.put(fieldName, Decimal.valueOf(fieldValue));
                s.put(fieldName, Decimal.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.DATACATEGORYGROUPREFERENCE) {
                // Unsupported
            }
            if(fieldType == Schema.DisplayType.DATE) {
                s.put(fieldName, Date.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.DATETIME) {
                try {
                    s.put(fieldName, DateTime.valueOf(fieldValue));
                }
                catch(Exception e) {
                    System.Debug('#### Exception '+e.getMessage()+', retrying as string');

                    try {
                        s.put(fieldName, String.valueOf(fieldValue));
                    }
                    catch(Exception ex) {
                        System.Debug('#### CRASH '+fieldValue);
                    }
                }
            }
            if(fieldType == Schema.DisplayType.DOUBLE) {
                try {
                    s.put(fieldName, Double.valueOf(fieldValue));
                }
                catch(Exception e) {
                    System.Debug('#### CRASH '+fieldValue);
                }
                //s.put(fieldName, fieldValue);
                //
            }
            if(fieldType == Schema.DisplayType.EMAIL) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.ENCRYPTEDSTRING) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.ID && fieldName.toLowerCase()=='id') {
                try {
                    s.put(fieldName, String.valueOf(fieldValue));
                }
                catch(Exception e) {
                    System.Debug('#### ID FAILURE '+fieldName+':'+e.getMessage());
                }
            }
            if(fieldType == Schema.DisplayType.INTEGER) {
                s.put(fieldName, Integer.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.LOCATION) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.MULTIPICKLIST) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.PERCENT) {
                s.put(fieldName, Double.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.PHONE) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.PICKLIST) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.REFERENCE) {
                s.put(fieldName, String.valueOf(fieldValue));

            }
            if(fieldType == Schema.DisplayType.SOBJECT) {
                //s.put(fieldName, String.valueOf(fieldValue));
            }
            if(fieldType == Schema.DisplayType.STRING) {
                s.put(fieldName, String.valueOf(fieldValue));

            }
            if(fieldType == Schema.DisplayType.TEXTAREA) {
                s.put(fieldName, String.valueOf(fieldValue));

            }
            if(fieldType == Schema.DisplayType.TIME) {
                // unsupported

            }
            if(fieldType == Schema.DisplayType.URL) {
                s.put(fieldName, String.valueOf(fieldValue));
            }
        } else {
            //
            // else, unknown field
            // System.Debug('##### IGNORED '+fieldName);
        }
    }
    public static Boolean checkFieldAccess(Schema.DescribeFieldResult fieldDesc, Boolean updateMode) {
        //
        // Id's must be set for updates
        Boolean result = false;
        if(updateMode) {
            result = fieldDesc.isAccessible();
        } else {
            result = fieldDesc.isAccessible() && fieldDesc.isCreateable();
        }
        //System.Debug('## FLS CHECK '+fieldDesc.name+': '+result);
        //System.Debug('## FLS CPU TIME '+Limits.getCpuTime());
        return result;
    }
    //
    // Cached FLS check results
    // Index: Object.Field.UpdateMode
    public static Map<String, Boolean> flsMap {
        get {
            if(flsMap==null) {
                flsMap = new Map<String, Boolean>();
            }
            return flsMap;
        }
        set;
    }
    public static Boolean checkObjectAccess(Schema.DescribeSObjectResult objDesc, Boolean updateMode) {
        Boolean result = false;
        if(updateMode) {
            result = objDesc.isUpdateable() && objDesc.isAccessible();
        } else {
            result = objDesc.isCreateable() && objDesc.isAccessible();
        }
        //System.Debug('## CRUD CHECK '+objDesc.name+': '+result);
        return result;
    }
    public static Boolean checkObjectAccessV2(Schema.DescribeSObjectResult objDesc, String accessLevel) {
        Boolean result = false;
        switch on accessLevel {
            when 'update' {
                result =  objDesc.isAccessible() && objDesc.isUpdateable();
            }
            when 'delete' {
                result = objDesc.isAccessible() && objDesc.isDeletable();
            }
            when 'read' {
                result = objDesc.isAccessible();
            }
            when 'create' {
                result =  objDesc.isAccessible() && objDesc.isCreateable();
            }
            when else {
                result = false; // Default!
            }
        }
        System.Debug('## CRUD CHECK V2 '+objDesc.name+': '+result);
        return result;
    }
    public static Boolean checkObjectDeletable(Schema.DescribeSObjectResult objDesc) {
        Boolean result = objDesc.isDeletable();
        //System.Debug('## CRUD CHECK DELETE '+objDesc.name+': '+result);
        return result;
    }
    public class SchemaUtilException extends Exception {

    }

}