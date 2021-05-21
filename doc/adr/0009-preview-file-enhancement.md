# 9. preview_file_logic.md

Date: 2021-05-21

## Status

Accepted

## Context

### 1. Preview support file type

The current checking preview file is:

```dart
    final canPreviewReceivedShare = Platform.isIOS ? receivedShare.mediaType.isIOSSupportedPreview() : receivedShare.mediaType.isAndroidSupportedPreview();
    if (canPreviewReceivedShare || receivedShare.hasThumbnail) {
      final cancelToken = CancelToken();
      _showPrepareToPreviewFileDialog(context, receivedShare, cancelToken);
    
      var downloadPreviewType = DownloadPreviewType.original;
      if (receivedShare.mediaType.isImageFile()) {
        downloadPreviewType = DownloadPreviewType.image;
      } else if (canPreviewReceivedShare && receivedShare.hasThumbnail) {
        downloadPreviewType = DownloadPreviewType.thumbnail;
      }
      store.dispatch(_handleDownloadPreviewReceivedShare(receivedShare, downloadPreviewType, cancelToken));
    }
```

&#8594; With some `OpenOffice` (such as: .odt, .ods, etc...) files, the `canPreviewReceivedShare` will be `false`. In case `hasThumbnail` is false, user can not preview file. So, need to add supported file type for these.

## Decision

### 1. Preview support file type

Add more supported file type for `OpenOffice`: 

- androidSupportedTypes:
    ```
      'application/vnd.oasis.opendocument.text',
      'application/vnd.oasis.opendocument.text-template',
      'application/vnd.oasis.opendocument.text-web',
      'application/vnd.oasis.opendocument.text-master',
      'application/vnd.oasis.opendocument.graphics',
      'application/vnd.oasis.opendocument.graphics-template',
      'application/vnd.oasis.opendocument.presentation',
      'application/vnd.oasis.opendocument.presentation-template',
      'application/vnd.oasis.opendocument.spreadsheet',
      'application/vnd.oasis.opendocument.spreadsheet-template',
      'application/vnd.oasis.opendocument.chart',
      'application/vnd.oasis.opendocument.formula',
      'application/vnd.oasis.opendocument.database',
      'application/vnd.oasis.opendocument.image',
      'application/vnd.openofficeorg.extension',
    ```
    References:
    [https://www.openoffice.org/framework/documentation/mimetypes/mimetypes.html](https://www.openoffice.org/framework/documentation/mimetypes/mimetypes.html)
    
- iOSSupportedTypes:
    ```
    'application/vnd.oasis.opendocument.text' : 'org.oasis-open.opendocument.text',
    'application/vnd.oasis.opendocument.text-template' : 'org.oasis-open.opendocument.text-template',
    'application/vnd.oasis.opendocument.text-web' : 'org.oasis-open.opendocument.text-web',
    'application/vnd.oasis.opendocument.text-master' : 'org.oasis-open.opendocument.text-master',
    'application/vnd.oasis.opendocument.graphics' : 'org.oasis-open.opendocument.graphics',
    'application/vnd.oasis.opendocument.graphics-template' : 'org.oasis-open.opendocument.graphics-template',
    'application/vnd.oasis.opendocument.presentation' : 'org.oasis-open.opendocument.presentation',
    'application/vnd.oasis.opendocument.presentation-template' : 'org.oasis-open.opendocument.presentation-template',
    'application/vnd.oasis.opendocument.spreadsheet' : 'org.oasis-open.opendocument.spreadsheet',
    'application/vnd.oasis.opendocument.spreadsheet-template' : 'org.oasis-open.opendocument.spreadsheet-template',
    'application/vnd.oasis.opendocument.chart' : 'org.oasis-open.opendocument.chart',
    'application/vnd.oasis.opendocument.formula' : 'org.oasis-open.opendocument.formula',
    'application/vnd.oasis.opendocument.database' : 'org.oasis-open.opendocument.formula.database',
    'application/vnd.oasis.opendocument.image' : 'org.oasis-open.opendocument.image',
    ```
  
    References: (additional third-party UTIs)
        - [https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1)
        - [https://escapetech.eu/manuals/qdrop/uti.html](https://escapetech.eu/manuals/qdrop/uti.html)
 

## Consequences

- `OpenOffice` file types is supported
