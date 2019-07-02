class Tooltip1
{

static maxIndex := 10
static available := []
static staticIndex := 0
static staticTimedIndex := 0
static toSkip := 0
static z := Tooltip1.init()
static timerClear := Tooltip1.clear
static timerClearStaticTimed := Tooltip1.clearStaticTimed.Bind(Tooltip1)

init()
{
	i := 1
	while(i <= 20) {
		Tooltip1.available.push(true)
		i++
	}
}

/* Tooltips with indexes greater than Tooltip1.maxIndex are safe
 * from being automatically overwritten by these functions.
 */
write(text := "", time := "", x := "", y := "", index := "")
{
	if (Tooltip1.toSkip > 0)
		return Tooltip1.toSkip--
	
	if (index >= 1 && index <= 20) {
		
	}
	else {
		index := 0
		Loop (Tooltip1.maxIndex - 1) {
			if (Tooltip1.available[A_Index]) {
				index := A_Index
				break
			}
		}
		if (index == 0)
			index := Tooltip1.maxIndex
	}
	
	if (x == "")
		x := 50
	
	if (y == "")
		y := 50 + 25 * (index - 1)
	
	if (time == "")
		time := 1500
	
	Tooltip(text, x, y, index)
	if (time <= 0)
		{}
	else {
		Tooltip1.available[index] := false
		SetTimer(Tooltip1.timerClear.Bind(Tooltip1, index), -time)
	}
}

clear(index)
{
	Tooltip(,,, index)
	Tooltip1.available[index] := true
}

writeStatic(text)
{
	if (Tooltip1.toSkip > 0)
		return Tooltip1.toSkip--
	
	if (Tooltip1.staticIndex == 0) {
		Loop(19) {
			if (Tooltip1.available[A_Index]) {
				Tooltip1.staticIndex := A_Index
				break
			}
		}
		if (Tooltip1.staticIndex == 0)
			Tooltip1.staticIndex := 20
	}
	
	Tooltip1.write(text, 0,,, Tooltip1.staticIndex)
}

clearStatic()
{
	Tooltip1.write(, 0,,, Tooltip1.staticIndex)
	Tooltip1.staticIndex := 0
}

writeStaticTimed(text := "", time := "", x := "", y := "")
{
	if (Tooltip1.toSkip > 0)
		return Tooltip1.toSkip--
	
	if (Tooltip1.staticTimedIndex == 0) {
		Loop(Tooltip1.maxIndex - 1) {
			if (Tooltip1.available[A_Index]) {
				Tooltip1.staticTimedIndex := A_Index
				break
			}
		}
		if (Tooltip1.staticTimedIndex == 0)
			Tooltip1.staticTimedIndex := Tooltip1.maxIndex
	}
	
	if (x == "") {
		if (Tooltip1.staticTimedIndex <= 10)
			x := 50
		else
			x := 150
	}
	
	if (y == "")
		y := 50 + 25 * Mod(Tooltip1.staticTimedIndex - 1, 10)
	
	if (time == "")
		time := 1500
	
	Tooltip1.available[Tooltip1.staticTimedIndex] := false
	Tooltip(text, x, y, Tooltip1.staticTimedIndex)
	SetTimer(Tooltip1.timerClearStaticTimed, -time)
}

clearStaticTimed()
{
	Tooltip(,,, Tooltip1.staticTimedIndex)
	Tooltip1.available[Tooltip1.staticTimedIndex] := true
	Tooltip1.staticTimedIndex := 0
}

skip(amount)
{
	Tooltip1.toSkip += amount
}

}