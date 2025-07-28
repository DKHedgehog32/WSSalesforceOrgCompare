@isTest
private class KadasterAddressLookupControllerTest {

    private class MockKadasterResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String mockJson = '{' +
                '  "_embedded": {' +
                '    "adressen": [' +
                '      {' +
                '        "openbareRuimteNaam": "Bezuidenhoutseweg",' +
                '        "huisnummer": 265,' +
                '        "huisletter": "1",' +
                '        "huisnummertoevoeging": "A",' +
                '        "postcode": "2594AN",' +
                '        "woonplaatsNaam": "Den Haag",' +
                '        "adresseerbaarObjectIdentificatie": "0344010000110584",' +
                '        "adresregel5": "Bezuidenhoutseweg 265 1 A"' +
                '      }' +
                '    ]' +
                '  }' +
                '}';

            res.setBody(mockJson);
            return res;
        }
    }

    @isTest
    static void testFetchAddresses_withResult() {
        Test.setMock(HttpCalloutMock.class, new MockKadasterResponse());

        Test.startTest();
        List<Map<String, Object>> results = KadasterAddressLookupController.fetchAddresses('1234AB', '3');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One address should be returned');
        Map<String, Object> address = results[0];

        System.assertEquals('Bezuidenhoutseweg', address.get('streetName'));
        System.assertEquals('265', address.get('houseNumber'));
        System.assertEquals('1', address.get('houseLetter'));
        System.assertEquals('A', address.get('houseNumberAddition'));
        System.assertEquals('2594AN', address.get('postalCode'));
        System.assertEquals('Den Haag', address.get('city'));
        System.assertEquals('0344010000110584', address.get('addressableObjectIdentification'));
        System.assertEquals('Bezuidenhoutseweg 265 1 A', address.get('addressLabel'));
    }

    private class MockEmptyResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"_links":{"self":{"href":"https://api.bag..."}}}');
            return res;
        }
    }

    @isTest
    static void testFetchAddresses_emptyResponse() {
        Test.setMock(HttpCalloutMock.class, new MockEmptyResponse());

        Test.startTest();
        List<Map<String, Object>> results = KadasterAddressLookupController.fetchAddresses('1234AB', '999');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'No addresses should be returned');
    }

    private class MockErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setBody('Not found');
            return res;
        }
    }
}