class ErrorResponse
{
	__New(success, errorCode := 0, errorMsg := "")
	{
		this.success := success
		this.code := errorCode
		this.msg := errorMsg
	}
}