# users
## users.*
### users.*.audioLanguagePreference
The audio language preference. Defaults to 'Any Language'

**Type**: null or string

**Default**: `<null>`

### users.*.authenticationProviderId

**Type**: string

**Default**: `"Jellyfin.Server.Implementations.Users.DefaultAuthenticationProvider"`

### users.*.castReceiverId

**Type**: string

**Default**: `"F007D354"`

### users.*.displayCollectionsView
Whether to show the Collections View

**Type**: boolean

**Default**: `false`

### users.*.displayMissingEpisodes
Whether to show missing episodes

**Type**: boolean

**Default**: `false`

### users.*.enableAutoLogin

**Type**: boolean

**Default**: `false`

### users.*.enableLocalPassword

**Type**: boolean

**Default**: `false`

### users.*.enableNextEpisodeAutoPlay
Automatically play the next episode

**Type**: boolean

**Default**: `true`

### users.*.enableUserPreferenceAccess

**Type**: boolean

**Default**: `true`

### users.*.hashedPassword
A pbkdf2-sha512 hash of the users password. Can be generated with the genhash flake app.
See docs for `HashedPasswordFile` for details on how to generate a hash


**Type**: null or string

**Default**: `<null>`

### users.*.hashedPasswordFile
A path to a pbkdf2-sha512 hash
in this format [PHC string](https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md).
You can use the packaged 'genhash' tool in this flake.nix to generate a hash
```
# default values:
nix run gitlab:SpoodyTheOne/declarative-jellyfin#genhash -- \\
  -k <password> \\
  -i 210000 \\
  -l 128 \\
  -u
# Usage:
nix run gitlab:SpoodyTheOne/declarative-jellyfin#genhash -h

```


**Type**: null or absolute path

**Default**: `<null>`

### users.*.hidePlayedInLatest
Whether to hide already played titles in the 'Latest' section

**Type**: boolean

**Default**: `true`

### users.*.id
The ID of the user

**Type**: null or string

**Default**: `<null>`

### users.*.internalId
The index of the user in the database. Be careful setting this option. 1 indexed.

**Type**: null or signed integer

**Default**: `<null>`

### users.*.invalidLoginAttemptCount

**Type**: signed integer

**Default**: `0`

### users.*.lastActivityDate

**Type**: null or string

**Default**: `<null>`

### users.*.lastLoginDate

**Type**: null or string

**Default**: `<null>`

### users.*.loginAttemptsBeforeLockout
The number of login attempts the user can make before they are locked out. 0 for default (3 for normal users, 5 for admins). null for unlimited

**Type**: null or signed integer

**Default**: `3`

### users.*.maxActiveSessions
The maximum number of active sessions the user can have at once. 0 for unlimited

**Type**: signed integer

**Default**: `0`

### users.*.maxParentalAgeRating

**Type**: null or signed integer

**Default**: `<null>`

### users.*.maxParentalRatingSubScore

**Type**: null or signed integer

**Default**: `<null>`

### users.*.mustUpdatePassword

**Type**: signed integer

**Default**: `0`

### users.*.mutable
Functions like mutableUsers in NixOS users.users."user"
If true, the first time the user is created, all configured options
are overwritten. Any modifications from the GUI will take priority,
and no nix configuration changes will have any effect.
If false however, all options are overwritten as specified in the nix configuration,
which means any change through the Jellyfin GUI will have no effect after a rebuild.


**Type**: boolean

**Default**: `true`

### users.*.password

**Type**: null or string

**Default**: `<null>`

### users.*.passwordResetProviderId

**Type**: string

**Default**: `"Jellyfin.Server.Implementations.Users.DefaultPasswordResetProvider"`

### users.*.permissions
#### users.*.permissions.enableAllChannels
Whether the user has access to all channels

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableAllDevices
Whether the user has access to all devices

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableAllFolders
Whether the user has access to all folders

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableAudioPlaybackTranscoding
Whether the server should transcode audio for the user if requested

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableCollectionManagement
Whether the user can create, modify and delete collections

**Type**: boolean

**Default**: `false`

#### users.*.permissions.enableContentDeletion
Whether the user can delete content

**Type**: boolean

**Default**: `false`

#### users.*.permissions.enableContentDownloading
Whether the user can download content

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableLiveTvAccess
Whether the user can access live tv

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableLiveTvManagement
Whether the user can manage live tv

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableLyricManagement
Whether the user can edit lyrics

**Type**: boolean

**Default**: `false`

#### users.*.permissions.enableMediaConversion
Whether the user can do media conversion

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableMediaPlayback
Whether the user can play media

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enablePlaybackRemuxing
Whether the user is permitted to do playback remuxing

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enablePublicSharing
Whether to enable public sharing for the user

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableRemoteAccess
Whether the user can access the server remotely

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableRemoteControlOfOtherUsers
Whether the user can remotely control other users

**Type**: boolean

**Default**: `false`

#### users.*.permissions.enableSharedDeviceControl
Whether the user can control shared devices

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableSubtitleManagement
Whether the user can edit subtitles

**Type**: boolean

**Default**: `false`

#### users.*.permissions.enableSyncTranscoding
Whether to enable sync transcoding for the user

**Type**: boolean

**Default**: `true`

#### users.*.permissions.enableVideoPlaybackTranscoding
Whether the server should transcode video for the user if requested

**Type**: boolean

**Default**: `true`

#### users.*.permissions.forceRemoteSourceTranscoding
Whether the server should force transcoding on remote connections for the user

**Type**: boolean

**Default**: `false`

#### users.*.permissions.isAdministrator
Whether the user is an administrator

**Type**: boolean

**Default**: `false`

#### users.*.permissions.isDisabled
Whether the user is disabled

**Type**: boolean

**Default**: `false`

#### users.*.permissions.isHidden
Whether the user is hidden

**Type**: boolean

**Default**: `true`

### users.*.playDefaultAudioTrack

**Type**: boolean

**Default**: `true`

### users.*.preferences
#### users.*.preferences.enabledLibraries
A list of libraries this user as access to.
If it is empty, it means that the user has access to all libraries.
The libraries are specified by the library name specified in
`services.declarative-jellyfin.libraries.<name>`


**Type**: list of string

**Default**: `[]`

### users.*.rememberAudioSelections

**Type**: boolean

**Default**: `true`

### users.*.rememberSubtitleSelections

**Type**: boolean

**Default**: `true`

### users.*.remoteClientBitrateLimit
0 for unlimited

**Type**: signed integer

**Default**: `0`

### users.*.rowVersion

**Type**: signed integer

**Default**: `0`

### users.*.subtitleLanguagePreference
The subtitle language preference. Defaults to 'Any Language'

**Type**: null or string

**Default**: `<null>`

### users.*.subtitleMode
Default: The default subtitle playback mode.
Always: Always show subtitles.
OnlyForced: Only show forced subtitles.
None: Don't show subtitles.
Smart: Only show subtitles when the current audio stream is in a different language.


**Type**: one of "default", "always", "onlyForced", "none", "smart"

**Default**: `"default"`

### users.*.syncPlayAccess
Whether or not this user has access to SyncPlay

**Type**: boolean

**Default**: `false`
