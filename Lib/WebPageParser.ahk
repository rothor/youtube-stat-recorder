class WebPageParser
{
	__New(page, maxSearchStrSize := 999999999)
	{
		this.page := page
		this.pos := 1
		this.maxSearchStrSize := maxSearchStrSize
		this.errorStr := ""
	}
	
	gotoPrev(str)
	{
		pos := InStr(this.page, str)
		prevPos := pos
		occurrence := 0
		while (pos and pos < this.pos) {
			occurrence++
			prevPos := pos
			pos := InStr(this.page, str,, pos + 1)
		}
		
		if (occurrence > 0) {
			this.pos := prevPos
			return 1
		}
		else {
			return 0
		}
	}
	
	gotoNext(str, occurrence := 1)
	{
		newPos := InStr(this.page, str,, this.pos, occurrence)
		if (newPos == 0) {
			return 0
		}
		else {
			this.pos := newPos + StrLen(str)
			return 1
		}
	}
	
	getNextBetween(str1, str2, ByRef result)
	{
		posBegin := InStr(this.page, str1,, this.pos)
		if (!posBegin) {
			this.errorStr := "Did not find first search string."
			return 0
		}
		posBegin += StrLen(str1)
		
		posEnd := InStr(this.page, str2,, posBegin)
		if (!posEnd) {
			this.errorStr := "Did not find second search string."
			return 0
		}
		
		if (posEnd - posBegin > this.maxSearchStrSize) {
			this.errorStr := "Max string size exceeded."
			return 0
		}
		
		result := SubStr(this.page, posBegin, posEnd - posBegin)
		this.pos := posEnd + StrLen(str2)
		return 1
	}
	
	getBetweenClosing(ByRef result)
	{
		open := "{"
		close := "}"
		if (this.getChar(this.pos) == "{") {
			open := "{"
			close := "}"
		}
		else if (this.getChar(this.pos) == "[") {
			open := "["
			close := "]"
		}
		else {
			return 0
		}
		
		openCount := 1
		closeCount := 0
		pos := this.pos + 1
		withinStr := false
		prevChar := open
		while (openCount != closeCount and pos <= StrLen(this.page)) {
			char := this.getChar(pos)
			if (withinStr) {
				if (char == "`"" and prevChar != "\")
					withinStr := false
			}
			else {
				if (char == "`"")
					withinStr := true
				else if (char == open)
					openCount++
				else if (char == close)
					closeCount++
			}
			prevChar := char
			pos++
		}
		
		if (openCount == closeCount) {
			result := SubStr(this.page, this.pos, pos - this.pos)
			this.pos := pos
			return 1
		}
		else
			return 0
	}
	
	offset(amount)
	{
		this.pos += amount
	}
	
	getChar(pos)
	{
		return SubStr(this.page, pos, 1)
	}
	
	setMaxSearchStrSize(newSize)
	{
		this.maxSearchStrSize := newSize
	}
	
	getErrorStr()
	{
		return this.errorStr
	}
	
	resetPos()
	{
		this.pos := 0
	}
	
	outputPage()
	{
		FileAppend(this.page, "logs/page output.txt")
	}
}