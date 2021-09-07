# 12. upgrade-android-target-sdk-30

Date: 2021-09-07

## Status

Accepted

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


### Solution 2: Update the dependence [`flutter_downloader`](https://github.com/fluttercommunity/flutter_downloader) to support Android SDK 30

- Pros:
    - Have a good UX for user: User does not need to grant `MANAGE_EXTERNAL_STORAGE` permission in Settings app (Solution 1 does)
    - Don't need to wait Google team review

- Detail solution:

    1. In the dependence project, we resolve two issue that relate to Android 11 changes:
        - [ScopedStorage](https://developer.android.com/about/versions/11/privacy/storage): Require to use MediaStore or SAF to work with files
        - [PackageVisibility](https://developer.android.com/about/versions/11/privacy/package-visibility): Fix issue that can not open downloaded file with default OS application from notification
        - For more detail, look at PR [Upgrade to support Android SDK 30](https://github.com/fluttercommunity/flutter_downloader/pull/522)
        - Version updated: `flutter_downloader: ^1.7.0`

    2. In Linshare project:
       
        - In `android/app/main/AndroidManifest.xml`, add this permission:
      
            ```xml
                <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>    
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
          
        - In `pubspec.yaml` and `data/pubspec.yaml`:
            
            ```yaml
                flutter_downloader: 1.7.0
            ```

        - For all current implementation code which has checked `storage` permission, add checking Android version before request `storage` permission:
          
          For eg: `my_space_viewmodel.dart`:
    
              ```dart
                  final status = await Permission.storage.status;
                  switch (status) {
                    case PermissionStatus.granted: _download(documentIds, itemSelectionType: itemSelectionType);
                    break;
                    case PermissionStatus.permanentlyDenied:
                      _appNavigation.popBack();
                      break;
                    default: {
                      final requested = await Permission.storage.request();
                      switch (requested) {
                        case PermissionStatus.granted: _download(documentIds, itemSelectionType: itemSelectionType);
                        break;
                        default: _appNavigation.popBack();
                        break;
                      }
                    }
                  }
              ```
    
              Change to:
    
              ```dart
                  final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();
                  if(Platform.isAndroid && needRequestPermission) {
                    final status = await Permission.storage.status;
                    switch (status) {
                      case PermissionStatus.granted: _download(documentIds, itemSelectionType: itemSelectionType);
                      break;
                      case PermissionStatus.permanentlyDenied:
                        _appNavigation.popBack();
                        break;
                      default: {
                        final requested = await Permission.storage.request();
                        switch (requested) {
                          case PermissionStatus.granted: _download(documentIds, itemSelectionType: itemSelectionType);
                          break;
                          default: _appNavigation.popBack();
                          break;
                        }
                      }
                    }
                  } else {
                    _download(documentIds, itemSelectionType: itemSelectionType);
                  }
              ```
          
          Do the same for: `RecevedShare`, `SharedSpace` and `UploadRequest`.   


## Decision

We decided to use `Solution 2` which has a better UX for user (focus on user behavior)

## Consequences

- We can save the file in public storage directory without asking special permission or picking saved destination
- We can release new Android version on Google Play

## References

- https://developer.android.com/about/versions/11/privacy/storage
- https://developer.android.com/guide/topics/providers/document-provider
- https://proandroiddev.com/scoped-storage-on-android-11-2c5da70fb077
- https://betterprogramming.pub/android-scoped-storage-demystified-3024a062ba24
- https://medium.com/androiddevelopers/modern-user-storage-on-android-e9469e8624f9