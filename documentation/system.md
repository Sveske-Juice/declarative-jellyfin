# system
## system.UICulture

**Type**: string

**Default**: `"en-US"`

## system.activityLogRetentionDays

**Type**: signed integer

**Default**: `30`

## system.allowClientLogUpload

**Type**: boolean

**Default**: `true`

## system.cachePath
Specify a custom location for server cache files such as images.


**Type**: string

**Default**: `${cfg.cacheDir}`

## system.castReceiverApplications

**Type**: list of (attribute set)

**Default**: 
```nix
[
 {
  content = {
   Id = "F007D354";
   Name = "Stable";
  };
  tag = "CastRecieverApplication";
 }
 {
  content = {
   Id = "6F511C87";
   Name = "Unstable";
  };
  tag = "CastRecieverApplication";
 }
]
```

## system.chapterImageResolution
The resolution of the extracted chapter images.
Changing this will have no effect on existing dummy chapters.


**Type**: one of "MatchSource", "2160p", "1440p", "1080p", "720p", "480p", "360p", "240p", "144p"

**Default**: `"MatchSource"`

## system.codecsUsed

**Type**: list of string

**Default**: `[]`

## system.contentTypes

**Type**: list of string

**Default**: `[]`

## system.corsHosts

**Type**: list of string

**Default**: 
```nix
[
 "*"
]
```

## system.disableLiveTvChannelUserDataName

**Type**: boolean

**Default**: `true`

## system.displaySpecialsWithinSeasons

**Type**: boolean

**Default**: `true`

## system.dummyChapterDuration

**Type**: signed integer

**Default**: `0`

## system.enableCaseSensitiveItemIds

**Type**: boolean

**Default**: `true`

## system.enableExternalContentInSuggestions

**Type**: boolean

**Default**: `true`

## system.enableFolderView
Whether to enable .

**Type**: boolean

**Default**: `false`

## system.enableGroupingMoviesIntoCollections
Whether to enable Automatically group movies into collections.

**Type**: boolean

**Default**: `false`

## system.enableGroupingShowsIntoCollections
Whether to enable Automatically group shows into collections.

**Type**: boolean

**Default**: `false`

## system.enableMetrics
Whether to enable metrics.

**Type**: boolean

**Default**: `false`

## system.enableNormalizedItemByNameIds

**Type**: boolean

**Default**: `true`

## system.enableSlowResponseWarning

**Type**: boolean

**Default**: `true`

## system.imageExtractionTimeoutMs
Leave at 0 for no timeout

**Type**: signed integer

**Default**: `0`

## system.imageSavingConvention
i got no idea what this is

**Type**: value "Legacy" (singular enum)

**Default**: `"Legacy"`

## system.inactiveSessionThreshhold

**Type**: signed integer

**Default**: `0`

## system.isPortAuthorized

**Type**: boolean

**Default**: `true`

## system.isStartupWizardCompleted
Controls whether or not Declarative Jellyfin will mark the startup wizard as completed.
Set to `false` to show the startup wizard when visiting jellyfin (not recommended as this
will happen every time jellyfin is restarted)


**Type**: boolean

**Default**: `true`

## system.libraryMetadataRefreshConcurrency
Maximum number of parallel tasks during library scans.
Setting this to 0 will choose a limit based on your systems core count.
WARNING: Setting this number too high may cause issues with network file systems; if you encounter problems lower this number.


**Type**: signed integer

**Default**: `0`

## system.libraryMonitorDelay

**Type**: signed integer

**Default**: `60`

## system.libraryScanFanoutConcurrency
Maximum number of parallel tasks during library scans.
Setting this to 0 will choose a limit based on your systems core count.
WARNING: Setting this number too high may cause issues with network file systems; if you encounter problems lower this number.


**Type**: signed integer

**Default**: `0`

## system.libraryUpdateDuration

**Type**: signed integer

**Default**: `30`

## system.logFileRetentionDays
The amount of days that jellyfin should keep log files before deleting.


**Type**: signed integer

**Default**: `3`

## system.maxAudiobookResume
Titles are assumed fully played if stopped when the remaining duration is less than this value.


**Type**: signed integer

**Default**: `5`

## system.maxResumePct
Titles are assumed fully played if stopped after this time.


**Type**: signed integer

**Default**: `90`

## system.metadataCountryCode
Country code for language. Determines stuff like dates, comma placement etc.


**Type**: string

**Default**: `"US"`

## system.metadataOptions

**Type**: list of (attribute set)

**Default**: 
```nix
[
 {
  content = {
   disabledImageFetchers = [];
   disabledMetadataFetchers = [];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "Movie";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   disabledImageFetchers = [
    "The Open Movie Database"
   ];
   disabledMetadataFetchers = [
    "The Open Movie Database"
   ];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "MusicVideo";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   disabledImageFetchers = [];
   disabledMetadataFetchers = [];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "Series";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   disabledImageFetchers = [];
   disabledMetadataFetchers = [
    "TheAudioDB"
   ];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "MusicAlbum";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   ImageFetcherOrder = [];
   disabledImageFetchers = [];
   disabledMetadataFetchers = [
    "TheAudioDB"
   ];
   disabledMetadataSavers = [];
   itemType = "MusicArtist";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   disabledImageFetchers = [];
   disabledMetadataFetchers = [];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "BoxSet";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   disabledImageFetchers = [];
   disabledMetadataFetchers = [];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "Season";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
 {
  content = {
   disabledImageFetchers = [];
   disabledMetadataFetchers = [];
   disabledMetadataSavers = [];
   imageFetcherOrder = [];
   itemType = "Episode";
   localMetadataReaderOrder = [];
   metadataFetcherOrder = [];
  };
  tag = "MetadataOptions";
 }
]
```

## system.metadataPath
Specify a custom location for downloaded artwork and metadata.


**Type**: string

**Default**: `"/var/lib/jellyfin/metadata"`

## system.minAudiobookResume
Titles are assumed unplayed if stopped before this time.


**Type**: signed integer

**Default**: `5`

## system.minResumeDurationSeconds
The shortest video length in seconds that will save playback location and let you resume.


**Type**: signed integer

**Default**: `300`

## system.minResumePct
Titles are assumed unplayed if stopped before this time.


**Type**: signed integer

**Default**: `5`

## system.parallelImageEncodingLimit
Maximum number of image encodings that are allowed to run in parallel.
Setting this to 0 will choose a limit based on your systems core count.


**Type**: signed integer

**Default**: `0`

## system.pathSubstitutions

**Type**: list of string

**Default**: `[]`

## system.pluginRepositories
Configure which plugin repositories you use.

**Type**: list of (attribute set)

**Default**: 
```nix
[
 {
  content = {
   Enabled = true;
   Name = "Jellyfin Stable";
   Url = "https://repo.jellyfin.org/files/plugin/manifest.json";
  };
  tag = "RepositoryInfo";
 }
]
```

## system.preferredMetadataLanguage
Display language of jellyfin.

**Type**: string

**Default**: `"en"`

## system.quickConnectAvailable
Whether or not to enable quickconnect


**Type**: boolean

**Default**: `true`

## system.remoteClientBitrateLimit

**Type**: signed integer

**Default**: `0`

## system.removeOldPlugins

**Type**: boolean

**Default**: `true`

## system.saveMetadataHidden
Whether to enable .

**Type**: boolean

**Default**: `false`

## system.serverName
This name will be used to identify the server and will default to the server's hostname.


**Type**: string

**Default**: `"config.networking.hostName"`

## system.skipDeserializationForBasicTypes

**Type**: boolean

**Default**: `true`

## system.slowResponseThresholdMs
How slow (in ms) would a response have to be before a warning is shown

**Type**: signed integer

**Default**: `500`

## system.sortRemoveCharacters

**Type**: list of string

**Default**: 
```nix
[
 ","
 "&"
 "-"
 "{"
 "}"
 "'"
]
```

## system.sortRemoveWords

**Type**: list of string

**Default**: 
```nix
[
 "the"
 "a"
 "an"
]
```

## system.sortReplaceCharacters

**Type**: list of string

**Default**: 
```nix
[
 "."
 "+"
 "%"
]
```

## system.trickplayOptions
### system.trickplayOptions.enableHwAcceleration
Whether to enable Enable hardware acceleration.

**Type**: boolean

**Default**: `false`

### system.trickplayOptions.enableHwEncoding
Whether to enable Currently only available on QSV, VA-API, VideoToolbox and RKMPP, this option has no effect on other hardware acceleration methods..

**Type**: boolean

**Default**: `false`

### system.trickplayOptions.enableKeyFrameOnlyExtraction
Whether to enable Extract key frames only for significantly faster processing with less accurate timing.
If the configured hardware decoder does not support this mode, will use the software decoder instead.
.

**Type**: boolean

**Default**: `false`

### system.trickplayOptions.interval
Interval of time (ms) between each new trickplay image.


**Type**: signed integer

**Default**: `10000`

### system.trickplayOptions.jpegQuality
The JPEG compression quality for trickplay images.


**Type**: integer between 0 and 100 (both inclusive)

**Default**: `90`

### system.trickplayOptions.processPriority
Setting this lower or higher will determine how the CPU prioritizes the ffmpeg trickplay generation process in relation to other processes.
If you notice slowdown while generating trickplay images but don't want to fully stop their generation, try lowering this as well as the thread count.


**Type**: one of "High", "AboveNormal", "Normal", "BelowNormal", "Idle"

**Default**: `"BelowNormal"`

### system.trickplayOptions.processThreads
The number of threads to pass to the '-threads' argument of ffmpeg.


**Type**: signed integer

**Default**: `1`

### system.trickplayOptions.qscale
The quality scale of images output by ffmpeg, with 2 being the highest quality and 31 being the lowest.


**Type**: integer between 2 and 31 (both inclusive)

**Default**: `4`

### system.trickplayOptions.scanBehavior
The default behavior is non blocking, which will add media to the library before trickplay generation is done. Blocking will ensure trickplay files are generated before media is added to the library, but will make scans significantly longer.


**Type**: one of "NonBlocking", "Blocking"

**Default**: `"NonBlocking"`

### system.trickplayOptions.tileHeight
Maximum number of images per tile in the X direction.


**Type**: signed integer

**Default**: `10`

### system.trickplayOptions.tileWidth
Maximum number of images per tile in the X direction.


**Type**: signed integer

**Default**: `10`

### system.trickplayOptions.widthResolutions
List of the widths (px) that trickplay images will be generated at.
All images should generate proportionally to the source, so a width of 320 on a 16:9 video ends up around 320x180.


**Type**: list of (attribute set)

**Default**: 
```nix
[
 {
  content = 320;
  tag = "int";
 }
]
```
