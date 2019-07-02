# YouTube Stats Recorder

This application (written in AutoHotkey v2) downloads a YouTube channel's subscriber count and saves it to a Sqlite database along with a timestamp, so you can keep track of their subscriber count over time.

## Getting Started

You'll need to install AutoHotkey v2 (at https://www.autohotkey.com ). Then just double click **Record Youtube Stats (main).ahk**. It will download the YouTube channels' stats and save them in data.sqlite.

If you want to change which channels' stats are recorded, open the file **Record Youtube Stats (main).ahk** in a text editor and add or remove the channel's id to the array labeled "youtubeChannels". You can add as many channels as you want.

To get a YouTube channel's id, follow these steps:
1. Go to one of that channel's videos on YouTube.
2. In the description area under the video, right click their username and select "Copy Link Location" or something similar.
3. Paste that into a text editor. It should look like:
   ```
   https://www.youtube.com/channel/UC-lHPTN3Gqxm24_Vd_AJ5Yw
   ```
   In this case, the channel id would be
   ```
   UC-lHPTN3Gqxm24_Vd_AJ5Yw
   ```

To view all the data in a text file, double click **write data to text file.ahk**. This will read all the records stored in "data.sqlite" and write them to the file "youtube records.txt".

## Authors

**Robert Thorsberg** - [rothor](https://github.com/rothor)

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
