CoordMode "ToolTip", "Screen"
ComObjError(false) ; disable error dialog

#include <Tooltip1>
#Include <YoutubeStatGetter>


Tooltip1.writeStatic("Downloading youtube channel stats...")

; Add the channel id's of all the channels you want to track
; to this array.
youtubeChannels := ["UC-lHJZR3Gqxm24_Vd_AJ5Yw" ;PewDiePie's channel id
	, "UCq-Fj5jknLsUf-MWSy4_brA"] ;T-Series' channel id

errorCount := YoutubeStatGetter.recordStats(youtubeChannels)

Tooltip1.writeStatic("Done.")
Sleep 1500

ExitApp errorCount
