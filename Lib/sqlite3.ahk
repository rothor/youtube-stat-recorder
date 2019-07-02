#include <DllCallWrapper>


class sqlite3
{

static libraryIsLoaded := false
; Encodings
static UTF8 := 1
static UTF16LE := 2
static UTF16BE := 3
static UTF16 := 4
static ANY := 5
static UTF16_ALIGNED := 8
; Data types
static INTEGER := 1
static FLOAT := 2
static TEXT := 3
static BLOB := 4
static NULL := 5
; Something
static STATIC := 0
static TRANSIENT := -1
; Non-error return codes
static OK := 0
static ROW := 100
static DONE := 101

/**
 *  Public methods:
 *
 *    loadLibrary(pathToSqlite3Dll)
 *    open(dbFile, ByRef hDb)
 *    close_v2(hDb)
 *    prepare_v2(hdb, stmtStr, ByRef stmtOut)
 *    step(hStmt)
 *    finalize(hStmt)
 *    exec(hdb, stmtStr)
 *    column_count(hStmt)
 *    column_name(hStmt, colIndex)
 *    column_type(hStmt, colIndex)
 *    column_text(hStmt, colIndex)
 *    column_double(hStmt, colIndex)
 *    column_int(hStmt, colIndex)
 *    bind_int(hStmt, paramIndex, paramValue)
 *    bind_double(hStmt, paramIndex, paramValue)
 *    bind_text(hStmt, paramIndex, paramStr)
 *    clear_bindings(hStmt)
 *    reset(hStmt)
 *    strToUtf8(Str, ByRef UTF8)
 *    utf8ToStr(UTF8, ByRef Str)
 */

loadLibrary()
{
	if (sqlite3.libraryIsLoaded == false) {
		sqlite3.dcw := new DllCallWrapper("Lib\sqlite3.dll", true)
		sqlite3.libraryIsLoaded := true
	}
}

; Returns SQLITE_OK (0) on success
open(dbFile, ByRef hDb)
{
	hDb := 0
	sqlite3.strToUtf8(dbFile, dbFileUtf8)
	return DllCall(sqlite3.dcw.func("sqlite3_open")
		, "Ptr", &dbFileUtf8
		, "Ptr*", hDb
		, "Int")
}

; close_v2 is meant for garbage collected languages, like AutoHotkey
close_v2(hDb)
{
	return DllCall(sqlite3.dcw.func("sqlite3_close")
		, "Ptr", hDb
		, "Int")
}

; prepare_v2 is preferred to prepare
prepare_v2(hdb, stmtStr, ByRef stmtOut)
{
	sqlite3.strToUtf8(stmtStr, stmtUtf8)
	return DllCall(sqlite3.dcw.func("sqlite3_prepare_v2")
		, "Ptr", hDb
		, "Ptr", &stmtUtf8
		, "Int", StrLen(stmtStr) + 1 ; + 1 to include the nul-terminator
		, "Ptr*", stmtOut
		, "Ptr*", 0
		, "Int")
}

step(hStmt)
{
	return DllCall(sqlite3.dcw.func("sqlite3_step")
		, "Ptr", hStmt
		, "Int")
}

finalize(hStmt)
{
	return DllCall(sqlite3.dcw.func("sqlite3_finalize")
		, "Ptr", hStmt
		, "Int")
}

exec(hdb, stmtStr)
{
	sqlite3.strToUtf8(stmtStr, stmtUtf8)
	return DllCall(sqlite3.dcw.func("sqlite3_exec")
		, "Ptr", hDb
		, "Ptr", &stmtUtf8
		, "Ptr", 0
		, "Ptr", 0
		, "Ptr*", 0
		, "Int")
}

column_count(hStmt)
{
	return DllCall(sqlite3.dcw.func("sqlite3_column_count")
		, "Ptr", hStmt
		, "Int")
}

; left-most column, for column methods, has index 0
column_name(hStmt, colIndex)
{
	utf8Str := DllCall(sqlite3.dcw.func("sqlite3_column_name")
		, "Ptr", hStmt
		, "Int", colIndex
		, "Str")
	sqlite3.utf8ToStr(utf8Str, str)
	return str
}

column_type(hStmt, colIndex)
{
	return DllCall(sqlite3.dcw.func("sqlite3_column_type")
		, "Ptr", hStmt
		, "Int", colIndex
		, "Int")
}

column_text(hStmt, colIndex)
{
	strUtf8 := DllCall(sqlite3.dcw.func("sqlite3_column_text")
		, "Ptr", hStmt
		, "Int", colIndex
		, "Str")
	sqlite3.utf8ToStr(strUtf8, str)
	return str
}

column_double(hStmt, colIndex)
{
	return DllCall(sqlite3.dcw.func("sqlite3_column_double")
		, "Ptr", hStmt
		, "Int", colIndex
		, "Double")
}

column_int(hStmt, colIndex)
{
	return DllCall(sqlite3.dcw.func("sqlite3_column_int")
		, "Ptr", hStmt
		, "Int", colIndex
		, "Int")
}

; The left-most parameter, for bind methods, has index 1
bind_int(hStmt, paramIndex, paramValue)
{
	return DllCall(sqlite3.dcw.func("sqlite3_bind_int")
		, "Ptr", hStmt
		, "Int", paramIndex
		, "Int", paramValue
		, "Int")
}

bind_double(hStmt, paramIndex, paramValue)
{
	return DllCall(sqlite3.dcw.func("sqlite3_bind_double")
		, "Ptr", hStmt
		, "Int", paramIndex
		, "Double", paramValue
		, "Int")
}

bind_text(hStmt, paramIndex, paramStr)
{
	sqlite3.strToUtf8(paramStr, paramStrUtf8)
	return DllCall(sqlite3.dcw.func("sqlite3_bind_text")
		, "Ptr", hStmt
		, "Int", paramIndex
		, "Ptr", &paramStrUtf8
		, "Int", -1 ;StrLen(paramStrUtf8) + 1 (this doesn't work)
		, "Ptr", sqlite3.TRANSIENT ; I don't know why, but this needs to be set to TRANSIENT
		, "Int")
}

clear_bindings(hStmt)
{
	return DllCall(sqlite3.dcw.func("sqlite3_clear_bindings")
		, "Ptr", hStmt
		, "Int")
}

reset(hStmt)
{
	return DllCall(sqlite3.dcw.func("sqlite3_reset")
		, "Ptr", hStmt
		, "Int")
}

strToUtf8(Str, ByRef UTF8)
{
	VarSetCapacity(UTF8, StrPut(Str, "UTF-8"), 0)
	Return StrPut(Str, &UTF8, "UTF-8")
}

utf8ToStr(UTF8, ByRef Str)
{
	Str := StrGet(&UTF8, "UTF-8")
	Return StrLen(Str)
}

}