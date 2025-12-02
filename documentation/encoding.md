# encoding
## encoding.allowAv1Encoding
Whether AV1 encoding is enabled

**Type**: boolean

**Default**: `false`

## encoding.allowHevcEncoding
Whether HEVC encoding is enabled

**Type**: boolean

**Default**: `false`

## encoding.allowOnDemandMetadataBasedKeyframeExtractionForExtensions
imma be real i have no idea what this option is. Just leave it as the default

**Type**: list of string

**Default**: 
```nix
[
 "mkv"
]
```

## encoding.deinterlaceDoubleRate
Whether to enable This setting uses the field rate when deinterlacing, often referred to as bob deinterlacing, which doubles the frame rate of the video to provide full motion like what you would see when viewing interlaced video on a TV.
.

**Type**: boolean

**Default**: `false`

## encoding.deinterlaceMethod
Select the deinterlacing method to use when software transcoding interlaced content.
When hardware acceleration supporting hardware deinterlacing is enabled the hardware deinterlacer will be used instead of this setting.


**Type**: one of "yadif", "bwdif"

**Default**: `"yadif"`

## encoding.downMixAudioBoost
Boost audio when downmixing. A value of one will preserve the original volume.

**Type**: signed integer or floating point number

**Default**: `2`

## encoding.downMixStereoAlgorithm
Algorithm used to downmix multi-channel audio to stereo.

**Type**: one of "None", "Dave750", "NightmodeDialogue", "RFC7845", "AC-4"

**Default**: `"None"`

## encoding.enableAudioVbr
Whether to enable Enable VBR Audio.

**Type**: boolean

**Default**: `false`

## encoding.enableDecodingColorDepth10Hevc
Whether to enable Enable hardware decoding for HEVC 10bit.

**Type**: boolean

**Default**: `false`

## encoding.enableDecodingColorDepth10HevcRext
Whether to enable Enable hardware decoding for HEVC RExt 8/10bit.

**Type**: boolean

**Default**: `false`

## encoding.enableDecodingColorDepth10Vp9
Whether to enable Enable hardware decoding for VP9 10bit.

**Type**: boolean

**Default**: `false`

## encoding.enableDecodingColorDepth12HevcRext
Whether to enable Enable hardware decoding for HEVC RExt 12bit.

**Type**: boolean

**Default**: `false`

## encoding.enableFallbackFont
Whether to enable Enable fallback font.

**Type**: boolean

**Default**: `false`

## encoding.enableHardwareEncoding
Whether to do Hardware Acceleration

**Type**: boolean

**Default**: `true`

## encoding.enableIntelLowPowerH264HwEncoder
Whether to enable Low-Power Encoding can keep unnecessary CPU-GPU sync. On Linux they must be disabled if the i915 HuC firmware is not configured.

https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#configure-and-verify-lp-mode-on-linux
.

**Type**: boolean

**Default**: `false`

## encoding.enableIntelLowPowerHevcHwEncoder
Whether to enable Low-Power Encoding can keep unnecessary CPU-GPU sync. On Linux they must be disabled if the i915 HuC firmware is not configured.

https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#configure-and-verify-lp-mode-on-linux
.

**Type**: boolean

**Default**: `false`

## encoding.preferSystemNativeHwDecoder
Prefer OS native DXVA or VA-API hardware decoders

https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#tone-mapping-methods
.

**Type**: boolean

**Default**: `false`

## encoding.enableSegmentDeletion
Whether to enable Delete old segments after they have been downloaded by the client.
This prevents having to store the entire transcoded file on disk.
Turn this off if you experience playback issues.
.

**Type**: boolean

**Default**: `false`

## encoding.enableSubtitleExtraction
Embedded subtitles can be extracted from videos and delivered to clients in plain text, in order to help prevent video transcoding.
On some systems this can take a long time and cause video playback to stall during the extraction process.
Disable this to have embedded subtitles burned in with video transcoding when they are not natively supported by the client device.


**Type**: boolean

**Default**: `true`

## encoding.enableThrottling
Whether to enable When a transcode or remux gets far enough ahead from the current playback position, pause the process so it will consume fewer resources.
This is most useful when watching without seeking often. Turn this off if you experience playback issues.
.

**Type**: boolean

**Default**: `false`

## encoding.enableTonemapping
Whether to enable Tone-mapping can transform the dynamic range of a video from HDR to SDR while maintaining image details and colors, which are very important information for representing the original scene.
Currently works only with 10bit HDR10, HLG and DoVi videos. This requires the corresponding GPGPU runtime.
.

**Type**: boolean

**Default**: `false`

## encoding.enableVppTonemapping
Whether to enable Full Intel driver based tone-mapping. Currently works only on certain hardware with HDR10 videos. This has a higher priority compared to another OpenCL implementation.
.

**Type**: boolean

**Default**: `false`

## encoding.encoderAppPathDisplay
The path to the FFmpeg application file or folder containing FFmpeg.

**Type**: string

**Default**: `${pkgs.jellyfin-ffmpeg}`

## encoding.encoderPreset
Pick a faster value to improve performance, or a slower value to improve quality.


**Type**: one of "auto", "veryslow", "slower", "slow", "medium", "fast", "faster", "veryfast", "superfast", "ultrafast"

**Default**: `"auto"`

## encoding.encodingThreadCount
Amount of threads used for encoding.

Set to -1 for automatic and 0 for max.


**Type**: signed integer

**Default**: `-1`

## encoding.h254Crf
The 'Constant Rate Factor' (CRF) is the default quality setting for the x264 and x265 software encoders.
You can set the values between 0 and 51, where lower values would result in better quality (at the expense of higher file sizes).
Sane values are between 18 and 28.

Hardware encoders do not use these settings.


**Type**: signed integer

**Default**: `23`

## encoding.h256Crf
The 'Constant Rate Factor' (CRF) is the default quality setting for the x264 and x265 software encoders.
You can set the values between 0 and 51, where lower values would result in better quality (at the expense of higher file sizes).
Sane values are between 18 and 28.

Hardware encoders do not use these settings.


**Type**: signed integer

**Default**: `28`

## encoding.hardwareAccelerationType
Whether or not to use hardware acceleration for transcoding.

If you misconfigure this your streams **will not work**!.
More info: https://jellyfin.org/docs/general/administration/hardware-acceleration/


**Type**: one of "none", "qsv", "amf", "nvenc", "vaapi", "rkmpp", "videotoolbox", "v4l2m2m"

**Default**: `"none"`

## encoding.hardwareDecodingCodecs
List of codec types to enable hardware decoding for.
Should only include codecs your hardware has support for.

Consult https://jellyfin.org/docs/general/administration/hardware-acceleration/ for more info.


**Type**: list of (one of "h264", "hevc", "mpeg2video", "vc1", "vp8", "vp9", "av1")

**Default**: 
```nix
[
 "h264"
 "hevc"
 "mpeg2video"
 "vc1"
]
```

## encoding.maxMuxingQueueSize
Maximum number of packets that can be buffered while waiting for all streams to initialize.
Try to increase it if you still meet "Too many packets buffered for output stream" error in FFmpeg logs.

The recommended value is `2048`.


**Type**: signed integer

**Default**: `2048`

## encoding.qsvDevice
Specify the device for Intel QSV on a multi-GPU system.
On Linux, this is the render node, e.g., /dev/dri/renderD128.
Leave blank unless you know what you are doing.


**Type**: string

**Default**: `""`

## encoding.segmentKeepSeconds
Time in seconds for which segments should be kept after they are downloaded by the client.
Only works if segment deletion is enabled.


**Type**: signed integer

**Default**: `720`

## encoding.throttleDelaySeconds
Time in seconds after which the transcoder will be throttled.
Must be large enough for the client to maintain a healthy buffer.
Only works if throttling is enabled.


**Type**: signed integer

**Default**: `180`

## encoding.tonemapingParam
Tune the tone mapping algorithm.
The recommended and default values are 0.

Recommended to leave unchanged


**Type**: signed integer or floating point number

**Default**: `0`

## encoding.tonemappingAlgorithm
Tone mapping can be fine-tuned.
If you are not familiar with these options, just keep the default.


**Type**: one of "none", "bt2390", "clip", "linear", "gamma", "reinhard", "hable", "mobius"

**Default**: `"bt2390"`

## encoding.tonemappingDesat
Apply desaturation for highlights that exceed this level of brightness.
The higher the parameter, the more color information will be preserved.
This setting helps prevent unnaturally blown-out colors for super-highlights, by (smoothly) turning into white instead.
This makes images feel more natural, at the cost of reducing information about out-of-range colors.

The recommended and default values are 0 and 0.5.


**Type**: signed integer or floating point number

**Default**: `0`

## encoding.tonemappingMode
Select the tone mapping mode.
If you experience blown out highlights try switching to the RGB mode.


**Type**: one of "auto", "max", "rgb", "lum", "itp"

**Default**: `"auto"`

## encoding.tonemappingPeak
Override signal/nominal/reference peak with this value.
Useful when the embedded peak information in display metadata is not reliable or when tone mapping from a lower range to a higher range.

The recommended and default values are 100 and 0.


**Type**: signed integer or floating point number

**Default**: `100`

## encoding.tonemappingRange
Select the output color range. Auto is the same as the input range.


**Type**: one of "auto", "tv", "pc"

**Default**: `"auto"`

## encoding.transcodingTempPath
Path for temporary transcoded files when streaming

**Type**: string

**Default**: `${cfg.cacheDir}/transcodes`

## encoding.vaapiDevice
This is the render node that is used for hardware acceleration.
Only used if `HardwareAccelerationType` is set to `vaapi`.


**Type**: string

**Default**: `"/dev/dri/renderD128"`

## encoding.vppTonemappingBrightness
Apply brightness gain in VPP tone mapping.

The recommended and default values are 16 and 0.


**Type**: signed integer or floating point number

**Default**: `16`

## encoding.vppTonemappingContrast
Apply contrast gain in VPP tone mapping.

Both recommended and default values are 1.


**Type**: signed integer or floating point number

**Default**: `1`
