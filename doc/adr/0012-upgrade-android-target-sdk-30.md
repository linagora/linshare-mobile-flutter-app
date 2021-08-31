# 12. upgrade-android-target-sdk-30

Date: 2021-08-31

## Status

Pending

## Context

- Download feature does not work when targeting into SDK 30 and above
- From Android 11 and above, the [scoped storage](https://developer.android.com/training/data-storage#scoped-storage) has enabled that makes the access into external storage is limited. So, we need to adapt with this change.
- We need to target to Android SDK 30 for any updates version beyond November 2021

## Decision

### Solution 1: Request permission [MANAGE_EXTERNAL_STORAGE](https://developer.android.com/training/data-storage/manage-all-files) for application:

- Pros:
    - Have access to manage all files (include app-specific and shared storage)
    - Has less code change implementation

- Cons:
    - Need to send a request form to Google Play for reviewing the policy: [Google Play notice](https://developer.android.com/training/data-storage/manage-all-files#all-files-access-google-play)

- Detail solution:

    - In `android/app/main/AndroidManifest.xml`, add this permission:

    ```xml
        <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>    
    ```

    - In `android/app/build.gradle`, change to:

    ```groovy
        android {
            compileSdkVersion 30
            ...
            defaultConfig {
                ...
                targetSdkVersion 30
            }
        }
    ```

    - For all current implementation code which has checked `storage` permission, change to `manageExternalStorage`:

  For eg: `my_space_viewmodel.dart`:

        ```dart
            final status = await Permission.storage.status;
            ...
            final requested = await Permission.storage.request();
        ```

        Change to:

        ```dart
            final status = await Permission.manageExternalStorage.status;
            ...
            final requested = await Permission.manageExternalStorage.request();
        ```


### Solution 2:

## Consequences

### Solution 1:
- The Google Play team may not accept the request form. It all will depend on their review.