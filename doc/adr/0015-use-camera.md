# 15. Use Camera

Date: 2024-06-11

## Status

accepted

## Context

We want to add the ability to use the camera in order to order to take photos or record videos

## Decision

We dediced to use wechat_camera_picker for camera access

## Consequences

 we need to add permissions for camera access for android

    ```
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

    ```
some methods in camera api uses some methods which were added in guauva-31-android in consequece we need to upgrade the used guava version from 27 to 31

```

configurations.all {
       exclude group: 'com.google.guava', module: 'failureaccess'

        resolutionStrategy {
            eachDependency { details ->
                if('guava' == details.requested.name) {
                    details.useVersion '31.0-android'
                }
            }
        }
    }

```

we need also to upgrade to used guava versio

and also add permission for camera usage in ios :

```

<key>NSCameraUsageDescription</key>
<string>You can take photos and videos and upload them directly</string>

```
