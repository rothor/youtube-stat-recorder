class DllCallWrapper
{
	__New(dllPath, doLoadLibrary := false)
	{
		this.dllPath := dllPath
		this.hModule := 0
		if (doLoadLibrary)
			this.loadLibrary()
	}
	
	loadLibrary()
	{
		if (!this.hModule)
			this.hModule := DllCall("LoadLibrary", "Str", this.dllPath, "Ptr")
	}
	
	freeLibrary()
	{
		if (this.hModule)
			DllCall("FreeLibrary", "Ptr", this.hModule)
		this.hModule := 0
	}
	
	func(name)
	{
		return this.dllPath "\" name
	}
}