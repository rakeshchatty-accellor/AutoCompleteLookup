@isTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class RestTest {
	@isTest
	private static void extractHeadersFromResponse() {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setHeader('Cache-Control', 'private, max-age=0');
		Map<String, String> headers = new MockApiClient().getHeaders(res);

		System.assertEquals(2, headers.size());
		System.assertEquals('application/json', headers.get('Content-Type'));
		System.assertEquals('private, max-age=0', headers.get('Cache-Control'));
	}

	@isTest
	private static void deserializeResponseBodyByContentType() {
		MockApiClient client = new MockApiClient();

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"red":"apple","yellow":"banana","orange":"orange"}');
		Map<String, String> result1 = (Map<String, String>) client.toReturnValue(res, Map<String, String>.class);
		System.assertEquals(3, result1.size());
		System.assertEquals('apple', result1.get('red'));
		System.assertEquals('banana', result1.get('yellow'));
		System.assertEquals('orange', result1.get('orange'));

		res.setHeader('Content-Type', 'text/plain');
		res.setBody('Hello, World!');
		String result2 = (String) client.toReturnValue(res, String.class);
		System.assertEquals('Hello, World!', result2);

		Blob fileContent = Blob.valueOf('Sample text file\nContents');
		res.setHeader('Content-Type', 'application/pdf');
		res.setBodyAsBlob(fileContent);
		Blob result3 = (Blob) client.toReturnValue(res, Blob.class);
		System.assertEquals(fileContent, result3);
	}

	@isTest
	private static void addStringifiedHeadersToRequest() {
		MockApiClient client = new MockApiClient();
		Map<String, Object> headers = new Map<String, Object>{
			'Content-Type' => 'application/json',
			'Max-Forwards' => 10
		};
		HttpRequest req = new HttpRequest();
		client.setHeaders(req, headers);

		System.assertEquals('application/json', req.getHeader('Content-Type'));
		System.assertEquals('10', req.getHeader('Max-Forwards'));
	}

	@isTest
	private static void serializeRequestBodyByContentType() {
		MockApiClient client = new MockApiClient();
		Map<String, Object> body1 = new Map<String, Object>{
			'hello' => 'world',
			'foo' => 15,
			'bar' => DateTime.newInstanceGmt(2000, 1, 23, 4, 56, 7),
			'bat' => false
		};
		Set<String> expected1 = new Set<String>{
			'"hello":"world"',
			'"foo":15',
			'"bar":"2000-01-23T04:56:07.000Z"',
			'"bat":false'
		};
		Set<String> actual1 = new Set<String>(client
			.toBody('application/json', body1)
			.removeStart('{')
			.removeEnd('}')
			.split(',')
		);
		System.assertEquals(expected1, actual1);

		String body2 = 'Hello, World!';
		String actual2 = client.toBody('text/plain', body2);
		System.assertEquals(body2, actual2);
	}

	@isTest
	private static void usePreferredContentTypeOrFirstInList() {
		MockApiClient client = new MockApiClient();

		Map<String, Object> headers1 = new Map<String, Object>();
		List<String> types1 = new List<String>{'application/xml', 'application/json', 'text/plain'};
		String result1 = client.setContentTypeHeader(types1, headers1);
		System.assertEquals(1, headers1.size());
		System.assertEquals('application/json', headers1.get('Content-Type'));
		System.assertEquals('application/json', result1);

		Map<String, Object> headers2 = new Map<String, Object>();
		List<String> types2 = new List<String>{'application/xml', 'text/plain'};
		String result2 = client.setContentTypeHeader(types2, headers2);
		System.assertEquals(1, headers2.size());
		System.assertEquals('application/xml', headers2.get('Content-Type'));
		System.assertEquals('application/xml', result2);

		Map<String, Object> headers3 = new Map<String, Object>();
		String result3 = client.setContentTypeHeader(new List<String>(), headers3);
		System.assertEquals(1, headers3.size());
		System.assertEquals('application/json', headers3.get('Content-Type'));
		System.assertEquals('application/json', result3);
	}

	@isTest
	private static void usePreferredAcceptOrAllInListNoDefault() {
		MockApiClient client = new MockApiClient();

		Map<String, Object> headers1 = new Map<String, Object>();
		List<String> types1 = new List<String>{'application/xml', 'application/json', 'text/plain'};
		client.setAcceptHeader(types1, headers1);
		System.assertEquals(1, headers1.size());
		System.assertEquals('application/json', headers1.get('Accept'));

		Map<String, Object> headers2 = new Map<String, Object>();
		List<String> types2 = new List<String>{'application/xml', 'text/plain'};
		client.setAcceptHeader(types2, headers2);
		System.assertEquals(1, headers2.size());
		System.assertEquals('application/xml,text/plain', headers2.get('Accept'));

		Map<String, Object> headers3 = new Map<String, Object>();
		client.setAcceptHeader(new List<String>(), headers3);
		System.assert(headers3.isEmpty());
	}

	@isTest
	private static void formUrlWithPathParams() {
		MockApiClient client = new MockApiClient();
		String path = '/departments/{department}';
		Map<String, Object> params = new Map<String, Object>{'department' => 'finance'};
		String expected = 'callout:SomeNamedCredentials/departments/finance';
		String actual = client.toEndpoint(path, params);
		System.assertEquals(expected, actual);
	}

	@isTest
	private static void returnParsedBody() {
		MockApiClient client = new MockApiClient();
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{'
			+ '"city":"Austin","country":"United States","latitude":30.28403639999999,'
			+ '"longitude":-97.73789449999998,"postalCode":"78705","state":"Texas",'
			+ '"street":"2110 Speedway"}');

		Test.setMock(HttpCalloutMock.class, new MockResponse(res));
		Address a = (Address) client.invoke('GET', '/address', '', Address.class);

		System.assertEquals('Austin', a.getCity());
		System.assertEquals('United States', a.getCountry());
		System.assertEquals(30.28403639999999, a.getLatitude());
		System.assertEquals(-97.73789449999998, a.getLongitude());
		System.assertEquals('78705', a.getPostalCode());
		System.assertEquals('Texas', a.getState());
		System.assertEquals('2110 Speedway', a.getStreet());
	}

	@isTest
	private static void noReturnTypeReturnsNull() {
		MockApiClient client = new MockApiClient();
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		
		Test.setMock(HttpCalloutMock.class, new MockResponse(res));
		Object o = client.invoke('POST', '/address', '', null);

		System.assertEquals(null, o);
	}

	@isTest
	private static void errorThrowsException() {
		MockApiClient client = new MockApiClient();
		HttpResponse res = new HttpResponse();
		res.setStatus('ERROR');
		res.setStatusCode(404);
		res.setBody('Response Body');
		res.setHeader('Header Key', 'Header Value');
		
		Test.setMock(HttpCalloutMock.class, new MockResponse(res));
		try {
			client.invoke('POST', '/address', '', null);
		} catch (ApiException e) {
			System.assertEquals('ERROR', e.status);
			System.assertEquals(404, e.code);
			System.assertEquals('Response Body', e.body);
			System.assertEquals('Header Value', e.headers.get('Header Key'));
			return;
		}
		System.assert(false);
	}

	private class MockApiClient extends Rest {
		public MockApiClient() {
			calloutName = 'SomeNamedCredentials';
		}
	}
}