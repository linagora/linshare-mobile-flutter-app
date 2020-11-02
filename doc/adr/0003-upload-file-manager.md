# 3. upload-file-manager

Date: 2020-11-02

## Status

Accepted

## Context

In LinShare Flutter application, we can receive files shared from other app via `UploadFileManager`.
At the moment, we can add new single pending share file to queue by:
```
void setPendingSingleFile(String filePath)
```

We can clear all file in pending list by:
```
void clearPendingFile()
```

We can get SharingStream which is returned share file list from library `ReceiveSharingIntent` by:
```
Stream<List<SharedMediaFile>> getReceivingSharingStream()
```

## Decision

We decided that LinShare app can add new single pending share file to queue at the moment.

## Consequences

Base on our implementation, the application is working well on both Android and IOS
