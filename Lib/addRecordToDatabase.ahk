#include <Sqlite>
#include <Logger>


/* Function: addRecordToDatabase
 * Purpose:
 *   Adds a new record to the database.
 * Input:
 *   - channelIdStr: string - the channel's id string
 *   - timeOf: string - timestamp
 *   - subscribers: int - the subscriber count
 *   - totalViews: int - the total view count
 *   - name: string - the channel's name
 * Output:
 *   - Return value: nothing
 * Last updated: Jul 1, 2019
 * Author: Robert Thorsberg
 */
addRecordToDatabase(channelIdStr, timeOf, subscribers := "", totalViews := "", name := "")
{
	paramStr := "channelIdStr=" channelIdStr ", timeOf=" timeOf ", subscribers=" subscribers ", totalViews=" totalViews ", name=" name
	logger := new Logger("sqlite logs.txt")
	sql := new Sqlite()
	rc := sql.open("data.sqlite")
	if (rc != sqlite3.OK)
		return logger.log("Failed to open database. Error code: " rc ". " paramStr)
	sql.exec("PRAGMA foreign_keys = ON;")
	
	stmt := "INSERT OR IGNORE INTO YoutubeChannel (IdStr) VALUES ('" channelIdStr "')"
	rc := sql.exec(stmt)
	if (rc != sqlite3.OK)
		return logger.log("Failed to insert row into YoutubeChannel. Error code: " rc ". " paramStr)
	
	if (name != "") {
		stmt := "UPDATE YoutubeChannel SET Name = '" name "' WHERE IdStr = '" channelIdStr "'"
		rc := sql.exec(stmt)
		if (rc != sqlite3.OK)
			logger.log("Failed to update name. Error code: " rc ". " paramStr) ; not a critical error, so don't return
	}
	
	stmt := "SELECT Id FROM YoutubeChannel WHERE IdStr = '" channelIdStr "';"
	rc := sql.execGet(stmt, result)
	if (rc != sqlite3.OK)
		return logger.log("Failed to execute query to get YoutubeChannel id. Error code: " rc ". " paramStr)
	channelId := result[1].Id
	
	stmt := "INSERT INTO YoutubeRecord (ChannelId, TimeOf, Subscribers, TotalViews) VALUES (" channelId ", '" timeOf "', " subscribers ", " totalViews ");"
	rc := sql.exec(stmt)
	if (rc != sqlite3.OK)
		return logger.log("Failed to execute insert query for YoutubeRecord. Error code: " rc ". " paramStr)
}