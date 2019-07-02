CoordMode "ToolTip", "Screen"
ComObjError(false) ; disable error dialog

#include <Tooltip1>
#include <Sqlite>


Tooltip1.writeStatic("Getting records from database...")

file := FileOpen("youtube records.txt", "w")
file.Write("Subscribers	Datetime`n`n")
sql := new Sqlite()
sql.open("data.sqlite")
stmt := "SELECT Name FROM YoutubeChannel;"
sql.execGet(stmt, channels)
for _, channel in channels {
	name := channel.name
	file.Write(Name "`n")
	stmt := "SELECT R.Subscribers AS Subscribers, R.TimeOf AS TimeOf FROM YoutubeRecord AS R INNER JOIN YoutubeChannel AS C ON R.ChannelId = C.Id WHERE C.Name = '" name "';"
	sql.execGet(stmt, records)
	for _, record in records {
		file.Write(record.Subscribers "`t" record.TimeOf "`n")
	}
	file.Write("`n")
}

Tooltip1.writeStatic("Done.")
Sleep 1500
