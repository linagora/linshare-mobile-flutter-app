# 8. upgrade-android-target-sdk-29

Date: 2021-03-17

## Status

Accepted

## Context

- Download feature does not work when targeting into SDK 29 and above
- From Android 10 and above, the [scoped storage](https://developer.android.com/training/data-storage#scoped-storage) has enabled that makes the access into external storage is limited. So, we need to adapt with this change.

## Decision

- Target to Android 10 (SDK 29) first, then adapt to Android 11 (SDK 30) later.
- Temporarily [opt-out of scoped storage](https://developer.android.com/training/data-storage/use-cases#opt-out-scoped-storage) in Android 10:

```xml
<manifest ... >
<!-- This attribute is "false" by default on apps targeting
     Android 10 or higher. -->
  <application android:requestLegacyExternalStorage="true" ... >
    ...
  </application>
</manifest>
```

```groovy
defaultConfig {
    ...
    targetSdkVersion 29
    ...
}
```

## Consequences

- The download feature can work in Android 10 (SDK 29) and below
- Android 11 (SDK 30) will be updated in the near future.
