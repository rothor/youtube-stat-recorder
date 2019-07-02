#Include <MiscLocal>
#include <ErrorResponse>
#include <WebPageParser>
#include <Logger>
#include <HttpRequester>
#include <addRecordToDatabase>


class YoutubeStatGetter
{

static logger := new Logger("download logs.txt")

/* Function: recordYoutubeStats
 * Purpose:
 *   This function performs the simple task of iterating on a list of channel ids,
 *   calling the 'recordUserStats' function for each one, keeping
 *   track of how many of these calls fail (which it returns), and logging errors.
 * Input:
 *   - usernameList: Object - An array of youtube channel ids.
 * Output:
 *   - Return value: int - Returns the number of queries that failed
 *    (returns 0 on total success).
 * Notes:
 *   - You can find another youtube channel's id by clicking on the 'about' tab on a
 *     channel's page and looking at the url. Considering that these functions don't
 *     actually use the Youtube API, there is probably a better way to do this, but I'm
 *     too lazy to learn the API right now.
 *   - The reason why I decided to use a channel's id rather than its name is because
 *     I couldn't find a way to take a youtube username or a channel name and look up
 *     its channel id. To my knowledge, it may be possible for multiple channels (and also
 *     users) to have the same name, which would make this basically impossible.
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

/* Function: recordUserYoutubeStats
 * Purpose:
 *   This function takes a youtube channel id as input, and downloads its
 *   stats and adds it to the database.
 * Input:
 *   - user: string - A youtube channel id.
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

/* Function: downloadAndParseYoutubeUserStats
 * Purpose:
 *   This function takes a youtube channel id as input, and returns an Object
 *	 containing its stats (like views and subscribers, etc.).
 * Input:
 *   - user: string - A youtube channel id.
 *   - stats: any - Used for returning values.
 * Output:
 *   - Return value: ErrorResponse - Contains info on whether the funcion succeeded.
 *   - stats: Object - On success, will contain the youtube channel's stats. They
 *     are: channel name (which can be changed), subscribers, views
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