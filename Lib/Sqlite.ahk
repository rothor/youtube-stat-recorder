#include <sqlite3>


class Sqlite
{

hDb := 0
dbOpen := false

__New()
{
	sqlite3.loadLibrary()
}

__Delete()
{
	if (this.dbOpen)
		this.close()
}

open(dbFile)
{
	hTemp := 0
	rc := sqlite3.open(dbFile, hTemp)
	if (rc != sqlite3.OK)
		return rc
	
	this.hDb := hTemp
	this.dbOpen := true
	return sqlite3.OK
}

close()
{
	rc := sqlite3.close_v2(this.hDb)
	if (rc != sqlite3.OK)
		return rc
	
	this.dbOpen := false
	return sqlite3.OK
}

exec(stmtStr)
{
	rc := this.newStmt(stmtStr, stmt)
	if (rc != sqlite3.OK)
		return rc
	rc := stmt.step()
	if (rc != sqlite3.DONE) {
		stmt.finalize()
		return rc
	}
	return stmt.finalize()
}

execGet(stmtStr, ByRef r_results)
{
	rc := this.newStmt(stmtStr, stmt)
	if (rc != sqlite3.OK)
		return rc
	rc := stmt.getResults(r_results)
	if (rc != sqlite3.DONE) {
		stmt.finalize()
		return rc
	}
	return stmt.finalize()
}

; Returns an Sqlite.Statment object on success, error code on failure
newStmt(stmtStr, ByRef r_stmtOut)
{
	rc := sqlite3.prepare_v2(this.hDb, stmtStr, hStmt)
	if (rc == sqlite3.OK)
		r_stmtOut := new Sqlite.Statement(hStmt)
	return rc
}

beginTransaction()
{
	str := "BEGIN TRANSACTION;"
	this.newStmt(str, stmt)
	stmt.step()
	stmt.finalize()
}

commit()
{
	str := "COMMIT;"
	this.newStmt(str, stmt)
	stmt.step()
	stmt.finalize()
}

rollback()
{
	str := "ROLLBACK;"
	this.newStmt(str, stmt)
	stmt.step()
	stmt.finalize()
}

class Statement
{
	finalized := false
	hStmt := 0
	colNameArr := []
	
	__New(hStmt)
	{
		this.hStmt := hStmt
		this.colNameArr := []
		colCount := sqlite3.column_count(this.hStmt)
		Loop (colCount) {
			this.colNameArr.Push(sqlite3.column_name(this.hStmt, A_Index - 1))
		}
	}
	
	__Delete()
	{
		if (!this.finalized)
			this.finalize()
	}

	step()
	{
		return sqlite3.step(this.hStmt)
	}

	finalize()
	{
		rc := sqlite3.finalize(this.hStmt)
		if (rc == sqlite3.OK)
			this.finalized := true
		return rc
	}
	
	getNextRow(ByRef r_row)
	{
		nextRow := sqlite3.step(this.hStmt)
		if (nextRow == sqlite3.ROW) {
			rowObj := []
			for key, colName in this.colNameArr {
				type := sqlite3.column_type(this.hStmt, key - 1)
				value := ""
				if (type == sqlite3.TEXT)
					value := sqlite3.column_text(this.hStmt, key - 1)
				else if (type == sqlite3.FLOAT)
					value := sqlite3.column_double(this.hStmt, key - 1)
				else if (type == sqlite3.INTEGER)
					value := sqlite3.column_int(this.hStmt, key - 1)
				rowObj[colName] := value
			}
			
			r_row := rowObj
		}
		
		return nextRow
	}
	
	; Don't call step() if you call getResult()
	getResults(ByRef r_rows)
	{
		rowArr := []
		nextRow := sqlite3.step(this.hStmt)
		while (nextRow == sqlite3.ROW) {
			rowObj := []
			for key, colName in this.colNameArr {
				type := sqlite3.column_type(this.hStmt, key - 1)
				value := ""
				if (type == sqlite3.TEXT)
					value := sqlite3.column_text(this.hStmt, key - 1)
				else if (type == sqlite3.FLOAT)
					value := sqlite3.column_double(this.hStmt, key - 1)
				else if (type == sqlite3.INTEGER)
					value := sqlite3.column_int(this.hStmt, key - 1)
				rowObj[colName] := value
			}
			
			rowArr.Push(rowObj)
			nextRow := sqlite3.step(this.hStmt)
		}
		
		if (nextRow == sqlite3.DONE)
			r_rows := rowArr
		return nextRow
	}
	
	reset()
	{
		sqlite3.reset(this.hStmt)
	}
	
	clearBindings()
	{
		sqlite3.clear_bindings(this.hStmt)
	}
	
	bindText(colIndex, value)
	{
		sqlite3.bind_text(this.hStmt, colIndex, value)
	}
	
	bindInt(colIndex, value)
	{
		sqlite3.bind_int(this.hStmt, colIndex, value)
	}
	
	bindDouble(colIndex, value)
	{
		sqlite3.bind_double(this.hStmt, colIndex, value)
	}
}

}