@isTest
public class MockResponse implements HttpCalloutMock {

	private final List<HttpResponse> responses = new List<HttpResponse>();
	private Integer respondIndex = 0;

	public MockResponse(Object o) {
		add(o);
	}

	public MockResponse add(Object o) {
		responses.add(createMockResponse(o));
		return this;
	}

	public HttpResponse respond(HttpRequest request) {
		return responses[respondIndex++];
	}

	private static HttpResponse createMockResponse(Object o) {
		if (o instanceof HttpResponse) {
			return (HttpResponse)o;
		}

		HttpResponse res = new HttpResponse();

		if (o instanceof ApiException) {
			ApiException e = (ApiException)o;
			res.setStatusCode(e.code);
			res.setStatus(e.status);
			Map<String, String> headers = e.headers;
			for (String key : headers.keySet()) {
				res.setHeader(key, headers.get(key));
			}
			res.setBody(e.body);
			return res;
		}

		res.setStatusCode(200);
		res.setStatus('OK');
		if (o instanceof Blob) {
			res.setHeader('Content-Type', 'application/pdf');
			res.setBodyAsBlob((Blob)o);
		} else {
			res.setHeader('Content-Type', 'application/json');
			res.setBody(JSON.serialize(o));
		}
		return res;
	}
}