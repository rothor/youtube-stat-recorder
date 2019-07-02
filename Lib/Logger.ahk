class Logger
{
	__New(filePath)
	{
		this.filePath := filePath
	}
	
	log(str)
	{
		FileAppend("`t===== " this.getTimestampStr() " =====`n" str "`n", this.filePath)
	}
	
	clear()
	{
		FileDelete(this.filePath)
		FileAppend("", this.filePath)
	}
	
	
		; - Private methods -
	
	getTimestampStr()
	{
		return FormatTime(, "MM/dd/yyyy HH:mm:ss")
	}
}