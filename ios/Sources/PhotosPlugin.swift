import Photos
import SwiftRs
import Tauri
import UIKit
import WebKit

class GetAlbumArgs: Decodable {
  let with: Int
  let subtype: Int
}

class GetAlbumMediasArgs: Decodable {
  let id: String
  let height: Int
  let width: Int
  let quality: CGFloat
}

class CheckAlbumCanOperationArgs: Decodable {
  let id: String
  let operation: Int
}

public struct MediaItem: Encodable {
  public let id: String
  public let mediaType: Int
  public let createAt: Double
  public var data: String? = nil
}

public struct AblumItem: Encodable {
  public let id: String
  public let name: String
}

func requestPhotosAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
  if #available(iOS 14, *) {
    PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
  } else {
    PHPhotoLibrary.requestAuthorization(handler)
  }
}

func getPhotosAuthorizationStatus() -> PHAuthorizationStatus {
  if #available(iOS 14, *) {
    PHPhotoLibrary.authorizationStatus(for: .readWrite)
  } else {
    PHPhotoLibrary.authorizationStatus()
  }
}

func getAlbums(_ with: PHAssetCollectionType, _ subtype: PHAssetCollectionSubtype) -> [AblumItem] {
  var result: [AblumItem] = []

  let albums = PHAssetCollection.fetchAssetCollections(
    with: with, subtype: subtype, options: nil)

  for i in 0..<albums.count {
    let album = albums[i]

    result.append(AblumItem(id: album.localIdentifier, name: album.localizedTitle ?? ""))
  }

  return result
}

func writeTempFile(_ data: Data, _ ext: String) -> String? {
  let dir = FileManager.default.temporaryDirectory
  let filename = "\(UUID().uuidString).\(ext)"
  let file = dir.appendingPathComponent(filename)

  do {
    try data.write(to: file)
    return file.path
  } catch {
    print("write failed \(error.localizedDescription)")
    return nil
  }
}

func getAlbumMedias(id: String, targetSize: CGSize, quality: CGFloat = 0.8) -> [MediaItem] {
  var result: [MediaItem] = []
  let albums = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
  let pmanager = PHImageManager.default()
  let amanager = PHAssetResourceManager.default()
  let options = PHImageRequestOptions()

  options.deliveryMode = .highQualityFormat
  options.isSynchronous = true
  options.resizeMode = .exact

  albums.enumerateObjects { album, _, _ in
    PHAsset.fetchAssets(in: album, options: nil).enumerateObjects { media, _, _ in
      var item = MediaItem(
        id: media.localIdentifier,
        mediaType: media.mediaType.rawValue,
        createAt: media.creationDate?.timeIntervalSince1970 ?? 0.0
      )

      switch media.mediaType {
      case .image:
        pmanager.requestImage(
          for: media, targetSize: targetSize, contentMode: .aspectFit, options: options
        ) { raw, _ in
          if let img = raw {
            if let jpg = img.jpegData(compressionQuality: quality) {
              item.data = writeTempFile(jpg, "jpg")
            }
          }
        }
      case .video:
        let resource = PHAssetResource.assetResources(for: media)
        if let resource = resource.first(where: { $0.type == .video }) {
          let buffer = NSMutableData()
          amanager.requestData(for: resource, options: nil) { chunk in
            buffer.append(chunk)
          } completionHandler: { error in
            if error == nil {
              // item.data = (buffer as Data).base64EncodedString()
              item.data = writeTempFile(buffer as Data, "mp4")
            }
          }
        }
      default:
        break
      }

      result.append(item)
    }
  }

  return result
}

class PhotosPlugin: Plugin {
  @objc public func requestPhotosAuth(_ invoke: Invoke) throws {
    print("exec requestPhotosAuth methods")

    requestPhotosAuthorization { status in
      invoke.resolve(["value": status.rawValue])
    }
  }

  @objc public func getPhotosAuthStatus(_ invoke: Invoke) throws {
    let status = getPhotosAuthorizationStatus()
    invoke.resolve(["value": status.rawValue])
  }

  @objc public func requestAlbums(_ invoke: Invoke) throws {
    let args: GetAlbumArgs = try invoke.parseArgs(GetAlbumArgs.self)
    guard let with = PHAssetCollectionType.init(rawValue: args.with) else {
      invoke.reject("Not parse arg with \"\(args.with)\" to PHAssetCollectionType")
      return
    }
    guard let subtype = PHAssetCollectionSubtype.init(rawValue: args.subtype) else {
      invoke.reject("Not parse arg subtype \"\(args.subtype)\" to PHAssetCollectionSubtype")
      return
    }

    invoke.resolve(["value": getAlbums(with, subtype)])
  }

  @objc public func requestAlbumMedias(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(GetAlbumMediasArgs.self)
    invoke.resolve([
      "value": getAlbumMedias(
        id: args.id, targetSize: CGSize(width: args.width, height: args.height),
        quality: args.quality)
    ])
  }

  @objc public func checkAlbumCanOperation(_ invoke: Invoke) throws {
    let args: CheckAlbumCanOperationArgs = try invoke.parseArgs(CheckAlbumCanOperationArgs.self)

    guard
      let album = PHAssetCollection.fetchAssetCollections(
        withLocalIdentifiers: [args.id], options: nil
      ).firstObject
    else {
      // invoke.resolve(["value": false])
      invoke.reject("Not found album by id \(args.id)")
      return
    }

    guard let operation = PHCollectionEditOperation.init(rawValue: args.operation) else {
      // invoke.resolve(["value": false])
      invoke.reject("Need check input operation \(args.operation)")
      return
    }

    invoke.resolve([
      "value": album.canPerform(operation)
    ])
  }
}

@_cdecl("init_plugin_ios_photos")
func initPlugin() -> Plugin {
  return PhotosPlugin()
}
