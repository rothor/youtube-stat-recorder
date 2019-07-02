class HttpRequester
{
	send(p_params)
	{
		request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		request.Open(p_params.method, p_params.url, true)
		for _, header in p_params.headerManager.headers {
			request.SetRequestHeader(header.name, header.value)
		}
		request.Send(p_params.body)
		request.WaitForResponse()
		
		headerManager := new HttpRequester.HeaderManager()
		headerManager.str := request.GetAllResponseHeaders()
		headerArr := StrSplit(request.GetAllResponseHeaders(), "`n")
		for _, headerStr in headerArr {
			if (headerStr == "")
				continue
			parts := StrSplit(headerStr, ": ",, 2)
			headerManager.add(parts[1], parts[2])
		}
		
		return new HttpRequester.Response(request.ResponseText
			, headerManager
			, request.Status
			, request.StatusText)
	}
	
	class Header
	{
		name := ""
		value := ""
		
		__New(name, value)
		{
			this.name := name
			this.value := value
		}
	}
	
	class Cookie
	{
		name := ""
		value := ""
		domain := ""
		path := ""
		
		__New(name := "", value := "", domain := "", path := "")
		{
			this.name := name
			this.value := value
			this.domain := domain
			this.path := path
		}
	}
	
	class HeaderManager
	{
		headers := []
		str := ""
		
		__New()
		{
			
		}
		
		add(name, value)
		{
			this.headers.Push(new HttpRequester.Header(name, value))
		}
		
		get(name)
		{
			valueArr := []
			for _, header in this.headers {
				if (header.name == name)
					valueArr.Push(header.value)
			}
			return valueArr
		}
		
		getCookies()
		{
			cookieArr := []
			setCookieStrs := this.get("Set-Cookie")
			for _, setCookieStr in setCookieStrs {
				cookieFields := StrSplit(setCookieStr, "; ")
				cookieFieldParts := StrSplit(cookieFields[1], "=",, 2)
				newCookie := new HttpRequester.Cookie(cookieFieldParts[1], cookieFieldParts[2])
				
				for k, cookieField in cookieFields {
					if (k == 1)
						continue
					cookieFieldParts := StrSplit(cookieField, "=",, 2)
					if (cookieFieldParts[1] == "domain")
						newCookie.domain := cookieFieldParts[2]
					else if (cookieFieldParts[1] == "path")
						newCookie.path := cookieFieldParts[2]
				}
				cookieArr.Push(newCookie)
			}
			return cookieArr
		}
		
		setCookies(cookieArr)
		{
			cookieStr := ""
			i := true
			for _, cookie in cookieArr {
				if (i)
					i := false
				else
					cookieStr .= "; "
				cookieStr .= cookie.name "=" cookie.value
			}
			this.add("Cookie", cookieStr)
		}
		
		getStr()
		{
			return this.str
		}
	}
	
	class Params
	{
		url := ""
		body := ""
		headerManager := new HttpRequester.HeaderManager()
		method := "GET"
		
		__New(url := ""
			, body := ""
			, headerManager := ""
			, method := "GET")
		{
			this.url := url
			this.body := body
			this.headerManager := headerManager is HttpRequester.HeaderManager ? headerManager : new HttpRequester.HeaderManager()
			this.method := method
		}
	}
	
	class Response
	{
		body := ""
		headerManager := new HttpRequester.HeaderManager()
		statusCode := 0
		statusText := ""
		
		__New(body
			, headerManager
			, statusCode
			, statusText)
		{
			this.body := body
			this.headerManager := headerManager is HttpRequester.HeaderManager ? headerManager : new HttpRequester.HeaderManager()
			this.statusCode := statusCode
			this.statusText := statusText
		}
	}
}
