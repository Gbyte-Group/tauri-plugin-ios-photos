import AVFoundation
import Photos
import SwiftRs
import Tauri
import UIKit
import UniformTypeIdentifiers
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

class CreateAlbumArgs: Decodable {
  let title: String
}

class CreateMediaArgs: Decodable {
  let album: String
  let files: [String]
}

class DeleteAlbumArgs: Decodable {
  let identifiers: [String]
}

class DeleteMediasArgs: Decodable {
  let album: String
  let identifiers: [String]
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

func exportVideo(asset: PHAsset, completion: @escaping (URL?) -> Void) {
  let options = PHVideoRequestOptions()

  options.version = .current
  options.deliveryMode = .fastFormat
  options.isNetworkAccessAllowed = true  // download iCloud asset

  PHImageManager.default().requestExportSession(
    forVideo: asset,
    options: options,
    exportPreset: AVAssetExportPresetMediumQuality
  ) { exportSession, _ in

    guard let exportSession = exportSession else {
      completion(nil)
      return
    }

    guard let fileType = exportSession.supportedFileTypes.first else {
      completion(nil)
      return
    }

    let fileExt = {
      switch fileType {
      case .mov:
        return "mov"
      case .m4v:
        return "m4v"
      default:
        return "mp4"
      }
    }()

    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(fileExt)

    exportSession.outputFileType = fileType

    exportSession.outputURL = tempURL

    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .completed:
        completion(tempURL)
      default:
        completion(nil)
      }
    }
  }
}

func getAlbumMedias(
  id: String, targetSize: CGSize, quality: CGFloat = 0.8,
  completion: @escaping ([MediaItem]) -> Void
) {
  var result: [MediaItem] = []
  let albums = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
  let pmanager = PHImageManager.default()
  let options = PHImageRequestOptions()
  let group = DispatchGroup()

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

          // PHImageRequestOptions.isSynchronous is true
          // so can sync append jpg item
          result.append(item)
        }
      case .video:
        group.enter()

        exportVideo(asset: media) { url in

          defer { group.leave() }

          if let path = url?.path {
            item.data = path
          }
          // PHImageRequestOptions.isSynchronous not work on request video
          // so must move append item to callback
          result.append(item)
        }
      default:
        break
      }
    }
  }

  group.notify(queue: .main) {
    completion(result)
  }
}

func createMedias(_ invoke: Invoke, _ isPhoto: Bool) throws {
  let args: CreateMediaArgs = try invoke.parseArgs(CreateMediaArgs.self)
  var albumLocalIdentifiers: [String] = []

  if let album = PHAssetCollection.fetchAssetCollections(
    withLocalIdentifiers: [args.album], options: nil
  ).firstObject {
    PHPhotoLibrary.shared().performChanges(
      {
        guard
          let addAssetRequest = PHAssetCollectionChangeRequest(
            for: album)
        else {
          invoke.reject("Create add asset request failed")
          return
        }

        var requests: [PHObjectPlaceholder] = []

        let createMediaAsset = { url in
          isPhoto
            ? PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            : PHAssetChangeRequest
              .creationRequestForAssetFromVideo(atFileURL: url)
        }

        for file in args.files {
          if let request: PHAssetChangeRequest =
            createMediaAsset(URL(fileURLWithPath: file))
          {
            requests.append(request.placeholderForCreatedAsset!)
            albumLocalIdentifiers.append(request.placeholderForCreatedAsset!.localIdentifier)
          }
        }

        addAssetRequest.addAssets(requests as NSArray)
      },
      completionHandler: { success, error in
        if success {
          invoke.resolve(["value": albumLocalIdentifiers])
        } else {
          invoke.reject("error create photo \(String(describing: error))")
        }
      }
    )
  } else {
    invoke.reject("not found album")
  }
}

func deleteMedias(_ invoke: Invoke) throws {
  let args: DeleteMediasArgs = try invoke.parseArgs(DeleteMediasArgs.self)

  guard
    let album = PHAssetCollection.fetchAssetCollections(
      withLocalIdentifiers: [args.album], options: nil
    ).firstObject
  else {
    invoke.reject("not found album")
    return
  }

  PHPhotoLibrary.shared().performChanges {
    let assets = PHAsset.fetchAssets(withLocalIdentifiers: args.identifiers, options: nil)

    PHAssetChangeRequest.deleteAssets(assets)
  } completionHandler: { success, error in
    if success {
      invoke.resolve(["value": true])
    } else {
      invoke.reject("delete failed, \(String(describing: error))")
    }
  }

}

func removeMediasFromAlbum(_ invoke: Invoke) throws {
  let args: DeleteMediasArgs = try invoke.parseArgs(DeleteMediasArgs.self)

  guard
    let album = PHAssetCollection.fetchAssetCollections(
      withLocalIdentifiers: [args.album], options: nil
    ).firstObject
  else {
    invoke.reject(
      "not found album by \"\(args.album)\""
    )
    return
  }

  PHPhotoLibrary.shared().performChanges {
    guard
      let removeAssetRequest = PHAssetCollectionChangeRequest(
        for: album)
    else {
      invoke.reject("Create remove asset request failed")
      return
    }

    let assets = PHAsset.fetchAssets(withLocalIdentifiers: args.identifiers, options: nil)

    removeAssetRequest.removeAssets(assets)

  } completionHandler: { success, error in
    if success {
      invoke.resolve(["value": true])
    } else {
      invoke.reject("delete failed, \(String(describing: error))")
    }
  }
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

    let subtype = args.subtype == -1 ? 9_223_372_036_854_775_807 : args.subtype

    guard let subtype = PHAssetCollectionSubtype.init(rawValue: subtype) else {
      invoke.reject("Not parse arg subtype \"\(args.subtype)\" to PHAssetCollectionSubtype")
      return
    }

    invoke.resolve(["value": getAlbums(with, subtype)])
  }

  @objc public func requestAlbumMedias(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(GetAlbumMediasArgs.self)

    getAlbumMedias(
      id: args.id, targetSize: CGSize(width: args.width, height: args.height),
      quality: args.quality
    ) { medias in
      invoke.resolve(["value": medias])
    }
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

  @objc public func createAlbum(_ invoke: Invoke) throws {
    let args: CreateAlbumArgs = try invoke.parseArgs(CreateAlbumArgs.self)
    var albumLocalIdentifier: String?

    PHPhotoLibrary.shared().performChanges(
      {
        let request: PHAssetCollectionChangeRequest =
          PHAssetCollectionChangeRequest
          .creationRequestForAssetCollection(withTitle: args.title)
        albumLocalIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier
      },
      completionHandler: { success, error in
        if success, let id = albumLocalIdentifier {
          invoke.resolve(["value": id])
        } else {
          invoke.reject("error create album \(String(describing: error))")
        }
      }
    )
  }

  @objc public func createPhotos(_ invoke: Invoke) throws {
    try createMedias(invoke, true)
  }

  @objc public func createVideos(_ invoke: Invoke) throws {
    try createMedias(invoke, false)
  }

  @objc public func deleteAlbum(_ invoke: Invoke) throws {
    let args: DeleteAlbumArgs = try invoke.parseArgs(DeleteAlbumArgs.self)

    if args.identifiers.isEmpty {
      invoke.resolve(["value": true])

      return
    }

    PHPhotoLibrary.shared().performChanges(
      {
        let albums = PHAssetCollection.fetchAssetCollections(
          withLocalIdentifiers: args.identifiers, options: nil
        )

        PHAssetCollectionChangeRequest.deleteAssetCollections(albums)
      },
      completionHandler: { success, error in
        if success {
          invoke.resolve(["value": true])
        } else {
          invoke.reject("delete albums failed \(String(describing: error))")
        }
      })
  }

  @objc public func deleteAlbumMedias(_ invoke: Invoke) throws {
    try deleteMedias(invoke)
  }

  @objc public func removeAlbumMedias(_ invoke: Invoke) throws {
    try removeMediasFromAlbum(invoke)
  }
}

@_cdecl("init_plugin_ios_photos")
func initPlugin() -> Plugin {
  return PhotosPlugin()
}
