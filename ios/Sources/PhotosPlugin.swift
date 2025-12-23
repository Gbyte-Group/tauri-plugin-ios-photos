import Photos
import SwiftRs
import Tauri
import UIKit
import WebKit

class PingArgs: Decodable {
  let value: String?
}

class GetAlbumMediasArgs: Decodable {
  let id: String
  let height: Int
  let width: Int
  let quality: CGFloat
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

func getAlbums() -> [AblumItem] {
  var result: [AblumItem] = []

  let albums = PHAssetCollection.fetchAssetCollections(
    with: .smartAlbum, subtype: .albumRegular, options: nil)

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
  @objc public func ping(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(PingArgs.self)
    invoke.resolve(["value": args.value ?? ""])
  }

  @objc public func requestPhotosAuth(_ invoke: Invoke) throws {
    print("exec requestPhotosAuth methods")

    requestPhotosAuthorization { status in
      invoke.resolve(["value": PHAuthorizationStatus.notDetermined])
    }
  }

  @objc public func requestAlbums(_ invoke: Invoke) throws {
    let albums = getAlbums()
    invoke.resolve(["value": albums])
  }

  @objc public func requestAlbumMedias(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(GetAlbumMediasArgs.self)
    invoke.resolve([
      "value": getAlbumMedias(
        id: args.id, targetSize: CGSize(width: args.width, height: args.height),
        quality: args.quality)
    ])
  }
}

@_cdecl("init_plugin_ios_photos")
func initPlugin() -> Plugin {
  return PhotosPlugin()
}
