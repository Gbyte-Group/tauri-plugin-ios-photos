# Tauri Plugin iOS Photos

A Tauri plugin for accessing and managing **iOS Photos albums and assets** using the native Photos framework.

This plugin allows Tauri applications to request photo permissions, read albums, access photos, and perform basic album/photo management on iOS devices.

> ⚠️ iOS only. This plugin relies on Apple Photos APIs and is not available on other platforms.

---

## Features

* Request and check photo library authorization
* List user photo albums
* Access photos from albums
* Filter albums
* Check album permission
* Create and remove albums
* Create, access, and delete photos

---

## Requirements

* Tauri 2.x (or compatible version)
* Xcode with iOS SDK
* Proper Photo Library permissions configured in `Info.plist`

---

## iOS Permissions

This plugin requires access to the user’s photo library.

Make sure the following keys are added to your **iOS `Info.plist`**:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Allow access to your photo library</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Allow saving photos to your photo library</string>
```

---

## Installation

```bash
pnpm add @gbyte/tauri-plugin-ios-photos
# or
npm install @gbyte/tauri-plugin-ios-photos
# or
yarn add @gbyte/tauri-plugin-ios-photos
```

Add the plugin to your Tauri project's `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-ios-photo = "0.1"
```

Configure the plugin permissions in your `capabilities/default.json`:

```json
{
  "permissions": [
    "ios-photos:default"
  ]
}
```

Register the plugin in your Tauri app:

```rust
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_ios_photos::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

---

## Usage (Conceptual Example)

```ts
import {
  requestPhotosAuth,
  PhotosAuthorizationStatus,
  requestAlbums,
  PHAssetCollectionType,
  PHAssetCollectionSubtype
} from '@gbyte/tauri-plugin-ios-photos'

let photoAuth = ''
let albums = []

requestPhotosAuth()
  .then((status) => {
    switch (status) {
      case PhotosAuthorizationStatus.authorized:
        photoAuth = 'authorized'
        break
      case PhotosAuthorizationStatus.denied:
        photoAuth = 'denied'
        break
      case PhotosAuthorizationStatus.limited:
        photoAuth = 'limited'
        break
      case PhotosAuthorizationStatus.restricted:
        photoAuth = 'restricted'
        break
      case PhotosAuthorizationStatus.notDetermined:
        photoAuth = 'notDetermined'
        break
    }
  })
  .then(() => {
    requestAlbums({
      with: PHAssetCollectionType.smartAlbum,
      subtype: PHAssetCollectionSubtype.albumRegular
    }).then((value) => {
      albums = value
    })
  })

```

---

## Authorization Status

Possible authorization states:

* `notDetermined`
* `restricted`
* `denied`
* `authorized`
* `limited`

The plugin exposes APIs to query and react to these states.

---

## Todos / Roadmap

* [x] Request access authorization
* [x] Check authorization type
* [x] List user device albums
* [x] Get photos from album
* [x] Filter album
* [x] Check album permission
* [x] Access photo
* [x] Create album
* [x] Create photo
* [x] Remove album
* [x] Remove photo
* [x] Delete photo
* [ ] Documentation improvements
* [ ] Example project
* [ ] Error handling standardization

---

## Notes

* All photo operations follow iOS privacy rules.
* Some actions may fail silently if permission is limited.
* Album and photo identifiers are system-generated.

---

## License

MIT
