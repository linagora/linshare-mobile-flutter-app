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

- Table Document: Help save documents when it make available offline in MySpace

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

## Decision

We decided that LinShare could currently make offline mode a file one by one.

## Consequences

We can preview files and perform actions with them when there is no network.