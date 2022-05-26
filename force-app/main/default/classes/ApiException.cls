public class ApiException extends Exception {

	public final Integer code { get; private set;}
	public final String status { get; private set;}
	public final Map<String, String> headers { get; private set;}
	public final String body { get; private set;}

	@SuppressWarnings('PMD.ExcessiveParameterList')
	public ApiException(Integer code, String status, Map<String, String> headers, String body) {
		this(String.format('Label.MsgApiResponseError', new Object[]{code, status, body}));
		this.code = code;
		this.status = status;
		this.headers = headers;
		this.body = body;
	}
}