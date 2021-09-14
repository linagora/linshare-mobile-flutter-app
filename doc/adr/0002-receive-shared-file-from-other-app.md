# 2. receive-shared-file-from-other-app

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

- Update on 14/09/2021:
    
    - By the issue from [here](https://github.com/KasemJaffer/receive_sharing_intent/issues/81), need to update setting on Android `AndroidManifest.xml`:
      Change from:
      ```xml
          android:launchMode="singleTop"
      ```
      to:
      ```xml
          android:launchMode="singleTask"
      ```
  
    - Adapt to version change [`1.4.5`](https://pub.dev/packages/receive_sharing_intent/changelog#145):
      - Support null-safety
      - New CFBundleURLSchemes 
  
## Decision

We decided that LinShare app support receiving single file shared at the moment.

## Consequences

Base on our implementation, the application is working well on both Android and IOS
