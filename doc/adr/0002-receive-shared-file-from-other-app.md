# 2. receive-shared-file-from-other-app as Unix shell scripts

Date: 2020-10-27

## Status

Accepted

## Context

In flutter application, we can receive file that is shared from other app. At this moment, LinShare app support receiving single file shared.

The following config is for receiving single file shared IOS (LinShareExtension/info.plist):
```
    <key>NSExtensionActivationSupportsImageWithMaxCount</key>
    <integer>1</integer>
    <key>NSExtensionActivationSupportsMovieWithMaxCount</key>
    <integer>1</integer>
    <key>NSExtensionActivationSupportsFileWithMaxCount</key>
    <integer>1</integer>
```
The following config is for receiving single file shared Android (AndroidManifest.xml):
```
    <intent-filter>
         <action android:name="android.intent.action.SEND" />
         <category android:name="android.intent.category.DEFAULT" />
         <data android:mimeType="*/*" />
     </intent-filter>
```
## Decision

We decided that LinShare app support receiving single file shared at the moment.

## Consequences

Base on our implementation, the application is working well on both Android and IOS
