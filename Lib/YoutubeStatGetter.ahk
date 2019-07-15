#Include <MiscLocal>
#include <ErrorResponse>
#include <WebPageParser>
#include <Logger>
#include <HttpRequester>
#include <addRecordToDatabase>


class YoutubeStatGetter
{

static logger := new Logger("download logs.txt")

/* Function: recordStats
 * Purpose:
 *   Records the YouTube stats of a list of channels, and logs any errors.
 * Input:
 *   - channelList: Object - An array of youtube channel ids.
 * Output:
 *   - nothing.
 * Last updated: Mar 10, 2019
 * Author: Robert Thorsberg
 */
recordStats(channelList)
{
	errorCount := 0
	allErrorStrs := ""
	
	for _, channel in channelList {
		status := YoutubeStatGetter.recordUserStats(channel)
		if (!status.success) {
			errorCount++
			allErrorStrs .= status.msg . "`n"
		}
	}
	
	if (errorCount)
		YoutubeStatGetter.logger.log(allErrorStrs)
	
	return errorCount
}

/* Function: recordUserStats
 * Purpose:
 *   Downloads a channel's stats and adds a new record to the database.
 * Input:
 *   - channelId: string - A youtube channel id.
 * Output:
 *   - Return value: ErrorResponse - Contains info on whether the funcion succeeded.
 * Last updated: July 1, 2019
 * Author: Robert Thorsberg
 */
recordUserStats(channelId)
{
	status := YoutubeStatGetter.downloadAndParseUserStats(channelId, stats)
	
	; If failed
	if (!status.success)
		return new ErrorResponse(false, 1, "channelId=" . channelId . ", errorMessage=" . status.msg)
	
	; Add to database
	addRecordToDatabase(channelId, MiscLocal.getUtcDatetime(), stats.subscribers, stats.views, stats.channelName)
	
	return new ErrorResponse(true)
}

/* Function: downloadAndParseUserStats
 * Purpose:
 *   Downloads and returns channel's stats.
 * Input:
 *   - channelId: string - A youtube channel id.
 * Output:
 *   - Return value: ErrorResponse - Contains info on whether the funcion succeeded.
 *   - r_stats: Object - On success, will contain the youtube channel's stats. They
 *     are: channelName, subscribers, views
 * Last updated: Mar 10, 2019
 * Author: Robert Thorsberg
 */
downloadAndParseUserStats(channelId, ByRef stats)
{
	url := "https://www.youtube.com/channel/" . channelId . "/about"
	requestParams := new HttpRequester.Params(url,,, "GET")
	response := HttpRequester.send(requestParams)
	if (response.statusCode != 200)
		return new ErrorResponse(false, 1, "error downloading web page.")
	wpp := new WebPageParser(response.body, 100)
	stats := {}
	
	; channel name
	if (!wpp.getNextBetween("<title>", "- YouTube</title>", result)) {
		FileDelete "logs\youtube second search string error.json"
		FileAppend response, "logs\youtube second search string error.json"
		return new ErrorResponse(false, 1, "channelName: " . wpp.getErrorStr())
	}
	stats.channelName := Trim(result, " `t`l`n")
	
	; subscribers
	wpp.setMaxSearchStrSize(15)
	wpp.gotoNext("`"about-stat`"")
	if (!wpp.getNextBetween("<b>", "</b>", result))
		return new ErrorResponse(false, 1, "subscribers: " . wpp.getErrorStr())
	result := StrReplace(result, ",", "")
	if (!MiscLocal.isDigit(result))
		return new ErrorResponse(false, 1, "subscribers: result '" . result . "' not a number.")
	stats.subscribers := result
	
	; views
	wpp.gotoNext("`"about-stat`"")
	if (!wpp.getNextBetween("<b>", "</b>", result))
		return new ErrorResponse(false, 1, "views: " . wpp.getErrorStr())
	result := StrReplace(result, ",", "")
	if (!MiscLocal.isDigit(result))
		return new ErrorResponse(false, 1, "views: result '" . result . "' not a number.")
	stats.views := result
	
	return new ErrorResponse(true)
}

}