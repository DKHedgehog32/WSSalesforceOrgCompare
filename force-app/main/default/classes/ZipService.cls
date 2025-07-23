/**
 * Created by harm on 11/03/2025.
 */

public with sharing class ZipService {
    public static void test() {
        ContentVersion versionRecord = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = '069Vc000006VEpeIAG'];

        Compression.ZipReader reader = new Compression.ZipReader(versionRecord.VersionData);
        Map<String, Compression.ZipEntry> zipMap = reader.getEntriesMap();
        for(String zipKey : zipMap.keySet()) {
            System.Debug('## zipKey '+zipKey);
            Compression.ZipEntry entry = zipMap.get(zipKey);
            System.Debug('## entry '+entry.getContent().toString());
        }


    }
}