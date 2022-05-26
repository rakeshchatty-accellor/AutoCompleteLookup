public abstract class Rest {

	private static final String HEADER_CONTENT_TYPE = 'Content-Type';
	private static final String HEADER_ACCEPT = 'Accept';
	private static final String HEADER_ACCEPT_DELIMITER = ',';

	protected String preferredContentType = 'application/json';
	protected String preferredAccept = 'application/json';
	protected final String calloutName;

	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected Object invoke(String method, String path, Object body, Type returnType) {
		return invoke(method, path, body,
			new Map<String, Object>(),				// pathParams
			new Map<String, Object>(),				// headers
			new List<String>{ 'application/json' },	// accepts
			new List<String>{ 'application/json' },	// contentTypes
			returnType);
	}

	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected virtual Object invoke(String method, String path, Object body, Map<String, Object> pathParams, Map<String, Object> headers,
			List<String> accepts, List<String> contentTypes, Type returnType) {

		HttpResponse res = getResponse(method, path, body, pathParams, headers, accepts, contentTypes);

		Integer code = res.getStatusCode();
		Boolean isFailure = code / 100 != 2;
		if (isFailure) {
			throw new ApiException(code, res.getStatus(), getHeaders(res), res.getBody());
		} else if (returnType != null) {
			return toReturnValue(res, returnType);
		}
		return null;
	}

	@TestVisible
	protected virtual Map<String, String> getHeaders(HttpResponse res) {
		Map<String, String> headers = new Map<String, String>();
		List<String> headerKeys = res.getHeaderKeys();
		for (String headerKey : headerKeys) {
			headers.put(headerKey, res.getHeader(headerKey));
		}
		return headers;
	}

	@TestVisible
	protected virtual Object toReturnValue(HttpResponse res, Type returnType) {
		if (returnType == Blob.class) {
			return res.getBodyAsBlob();
		}

		String body = res.getBody();
		String contentType = res.getHeader(HEADER_CONTENT_TYPE);
		if (contentType.contains('application/json')) {
			JsonParser parser = Json.createParser(body);
			parser.nextToken();
			return parser.readValueAs(returnType);
		}
		return body;
	}

	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected virtual HttpResponse getResponse(String method, String path, Object body, Map<String, Object> pathParams, Map<String, Object> headers,
			List<String> accepts, List<String> contentTypes) {

		HttpRequest req = new HttpRequest();
		req.setMethod(method);
		req.setEndpoint(toEndpoint(path, pathParams));
		String contentType = setContentTypeHeader(contentTypes, headers);
		setAcceptHeader(accepts, headers);
		setHeaders(req, headers);

		if (method != 'GET') {
			req.setBody(toBody(contentType, body));
		}

		return new Http().send(req);
	}

	@TestVisible
	protected virtual void setHeaders(HttpRequest req, Map<String, Object> headers) {
		for (String headerName : headers.keySet()) {
			req.setHeader(headerName, String.valueOf(headers.get(headerName)));
		}
	}

	@TestVisible
	protected virtual String toBody(String contentType, Object body) {
		if (contentType.contains('application/json')) {
			return Json.serialize(body, true);
		}
		return String.valueOf(body);
	}

	@TestVisible
	protected virtual String setContentTypeHeader(List<String> contentTypes, Map<String, Object> headers) {
		if (contentTypes.isEmpty()) {
			headers.put(HEADER_CONTENT_TYPE, preferredContentType);
			return preferredContentType;
		}
		for (String contentType : contentTypes) {
			if (preferredContentType == contentType) {
				headers.put(HEADER_CONTENT_TYPE, preferredContentType);
				return preferredContentType;
			}
		}
		String contentType = contentTypes.get(0);
		headers.put(HEADER_CONTENT_TYPE, contentType);
		return contentType;
	}

	@TestVisible
	protected virtual void setAcceptHeader(List<String> accepts, Map<String, Object> headers) {
		for (String accept : accepts) {
			if (preferredAccept == accept) {
				headers.put(HEADER_ACCEPT, preferredAccept);
				return;
			}
		}
		if (!accepts.isEmpty()) {
			headers.put(HEADER_ACCEPT, String.join(accepts, HEADER_ACCEPT_DELIMITER));
		}
	}

	@TestVisible
	protected virtual String toPath(String path, Map<String, Object> params) {
		String formatted = path;
		for (String key : params.keySet()) {
			formatted = formatted.replace('{' + key + '}', String.valueOf(params.get(key)));
		}
		return formatted;
	}

	@TestVisible
	protected virtual String toEndpoint(String path, Map<String, Object> params) {
		return 'callout:' + calloutName + toPath(path, params);
	}
}