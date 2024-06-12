# 14. Record audio

Date: 2024-06-11

## Status

accepted

## Context

We want to add the ability to record voice messages directly form inside linshare

## Decision

We decided to use the dependecie audio_waveforms since it gives the possibility to display waveforms and also
voice recording and playback

## Consequences

add audio_waveforms: 0.1.5+1 to `pubspec.yaml` this is the newest supported version

 we need to add permission for using microphone in android

    ```
     <uses-permission android:name="android
     permission.RECORD_AUDIO" />

    ```
and also for ios :

```
<key>NSMicrophoneUsageDescription</key>
    <string>Record voice messages and upload them directly</string>
```
