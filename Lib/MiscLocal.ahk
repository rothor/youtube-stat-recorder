class MiscLocal
{

isDigit(str)
{
	return str is "digit" and str != ""
}

getUtcDatetime()
{
	return FormatTime(A_NowUTC,"yyyy-MM-ddTHH:mm:ss." A_MSec)
}

}