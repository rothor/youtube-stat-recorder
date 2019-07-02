#include ../Lib/Sqlite.ahk


sql := new Sqlite()
sql.open("data.sqlite")
sql.exec("PRAGMA foreign_keys = ON;")
sql.exec(FileRead("CREATE TABLE YoutubeChannel.txt"))
sql.exec(FileRead("CREATE TABLE YoutubeRecord.txt"))
sql.close()