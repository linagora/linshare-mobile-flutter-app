# 11. make-offline-mode-file

Date: 2021-06-14

## Status

Accepted

## Context

In LinShare Flutter application, we can make offline mode files one by one from "My Space", "Received Shares" or "Shared Spaces" with the library [`sqflite`](https://pub.dev/packages/sqflite):

SQLite plugin for Flutter. Supports iOS, Android and MacOS.

- Support transactions and batches
- Automatic version management during open
- Helpers for insert/query/update/delete queries
- DB operation executed in a background thread on iOS and Android

Usage 

- Data

 - Document Table: Help save documents when it make available offline in MySpace

````
Table Document {
  documentId TEXT PRIMARY KEY // Id of document file
  description TEXT // Description of document file
  creationDate Integer // Creation date of document file
  modificationDate Integer // Modification date of document file
  expirationDate Integer // Expiration date of document file
  ciphered Integer // Document file has been set code not?
  name TEXT // Name of document file
  size Integer // Size of document file
  sha256sum TEXT // SHA of document file
  hasThumbnail Integer // Check if the file is downloadable as an thumbnail.
  shared Integer // Number shares of document file.
  mediaType TEXT // mediaType of document file.
  localPath TEXT // local storage path of document file.
}
````
 - SharedSpace Table: Help save shared space when it contains at least one file make available offline in SharedSpace

````
Table SharedSpace {
    sharedSpaceId TEXT PRIMARY KEY,
    sharedSpaceRoleId TEXT,
    sharedSpaceRoleName TEXT,
    sharedSpaceRoleEnable Integer,
    creationDate Integer,
    modificationDate Integer,
    name TEXT,
    nodeType TEXT,
    quotaId TEXT,
    versioningParameters Integer
}
````

 - WorkGroupNode Table: Help save file/folder when it contains at least one file make available offline in SharedSpace

````
Table WorkGroupNode {
    nodeId TEXT PRIMARY KEY,
    sharedSpaceId TEXT,
    parentNodeId TEXT,
    creationDate Integer,
    modificationDate Integer,
    name TEXT,
    nodeType TEXT,
    description TEXT,
    nameAccount TEXT,
    mailAccount TEXT,
    firstNameAccount TEXT,
    lastNameAccount TEXT,
    accountId TEXT,
    accountType TEXT,
    size Integer,
    mediaType TEXT,
    hasThumbnail Integer,
    uploadDate Integer,
    hasRevision Integer,
    sha256sum TEXT,
    localPath TEXT
}
````

- Deployment

 - Example 1: 
 
 + Make available file `A.png` in SharedSpace `SP1` has path: `SP1 > A.png`
 + The data is stored as follows: 
 
Information of SharedSpace `SP1` will be saved in the SharedSpace table:
```
SharedSpace {
    sharedSpaceId = SP1_ID,
    name = SP1_NAME,
    ...
}
```

Information of file `A.png` will be saved in the WorkGroupNode table:
```
WorkGroupNode {
    nodeId = A_ID,
    sharedSpaceId = SP1_ID,
    parentNodeId = null,
    name = A,
    nodeType = DOCUMENT
    ...
}
```
 
 - Example 2: 
 
 + Make available file `file.png` in folders `B` & `B1` of SharedSpace `SP2` has path: `SP2 > B > B2 > A.png`
 + The data is stored as follows: 
 
Information of SharedSpace `SP2` will be saved in the SharedSpace table:
```
SharedSpace {
    sharedSpaceId = SP2_ID,
    name = SP2_NAME,
    ...
}
```

Information of folder `B` will be saved in the WorkGroupNode table:
```
WorkGroupNode {
    nodeId = B_ID,
    sharedSpaceId = SP2_ID,
    parentNodeId = null,
    name = B,
    nodeType = FOLDER
    ...
}
```

Information of folder `B1` will be saved in the WorkGroupNode table:
```
WorkGroupNode {
    nodeId = B1_ID,
    sharedSpaceId = SP2_ID,
    parentNodeId = B_ID,
    name = B1,
    nodeType = FOLDER
    ...
}
```

Information of file `file.png` will be saved in the WorkGroupNode table:
```
WorkGroupNode {
    nodeId = file_ID,
    sharedSpaceId = SP1_ID,
    parentNodeId = B1_ID,
    name = file,
    nodeType = DOCUMENT
    ...
}
```

## Decision

We decided that LinShare could currently make offline mode a file one by one.

## Consequences

We can preview files and perform actions with them when there is no network.