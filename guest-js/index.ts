import { invoke } from '@tauri-apps/api/core'

/**
 * Information about your app’s authorization to access the user’s photo library.
 *
 * @see [PHAuthorizationStatus](https://developer.apple.com/documentation/photos/phauthorizationstatus)
 */
export const PhotosAuthorizationStatus = {
  notDetermined: 0,
  restricted: 1,
  denied: 2,
  authorized: 3,
  limited: 4
} as const satisfies Record<string, number>

/**
 * Values identifying possible actions that a collection can support.
 *
 * @see [PHCollectionEditOperation](https://developer.apple.com/documentation/photos/phcollectioneditoperation)
 */
export const PHCollectionEditOperation = {
  deleteContent: 1,
  removeContent: 2,
  addContent: 3,
  createContent: 4,
  rearrangeContent: 5,
  delete: 6,
  rename: 7
} as const satisfies Record<string, number>

/**
 * Major distinctions between kinds of asset collections.
 *
 * @see [PHAssetCollectionType](https://developer.apple.com/documentation/photos/phassetcollectiontype)
 */
export const PHAssetCollectionType = {
  /**
   * An album in the Photos app.
   */
  album: 1,
  /**
   * A smart album whose contents update dynamically.
   */
  smartAlbum: 2
} as const satisfies Record<string, number>

/**
 * Minor distinctions between kinds of asset collections.
 *
 * @see [PHAssetCollectionSubtype](https://developer.apple.com/documentation/photos/phassetcollectionsubtype)
 */
export const PHAssetCollectionSubtype = {
  albumRegular: 2,
  albumSyncedEvent: 3,
  albumSyncedFaces: 4,
  albumSyncedAlbum: 5,
  albumImported: 6,
  albumMyPhotoStream: 100,
  albumCloudShared: 101,
  smartAlbumGeneric: 200,
  smartAlbumPanoramas: 201,
  smartAlbumVideos: 202,
  smartAlbumFavorites: 203,
  smartAlbumTimelapses: 204,
  smartAlbumAllHidden: 205,
  smartAlbumRecentlyAdded: 206,
  smartAlbumBursts: 207,
  smartAlbumSlomoVideos: 208,
  smartAlbumUserLibrary: 209,
  smartAlbumSelfPortraits: 210,
  smartAlbumScreenshots: 211,
  smartAlbumDepthEffect: 212,
  smartAlbumLivePhotos: 213,
  smartAlbumAnimated: 214,
  smartAlbumLongExposures: 215,
  smartAlbumUnableToUpload: 216,
  smartAlbumRAW: 217,
  smartAlbumCinematic: 218,
  smartAlbumSpatial: 219,
  any: -1
}

export type PhotosAuthorizationStatus =
  (typeof PhotosAuthorizationStatus)[keyof typeof PhotosAuthorizationStatus]

export type PHCollectionEditOperation =
  (typeof PHCollectionEditOperation)[keyof typeof PHCollectionEditOperation]

export type PHAssetCollectionType =
  (typeof PHAssetCollectionType)[keyof typeof PHAssetCollectionType]

export type PHAssetCollectionSubtype =
  (typeof PHAssetCollectionSubtype)[keyof typeof PHAssetCollectionSubtype]

export type AlbumItem = {
  id: string
  name: string
}

export type MediaItem = {
  id: string
  mediaType: number
  createAt: number
  data?: string
}

export type RequestAlbumRequest = {
  with: PHAssetCollectionType
  subtype: PHAssetCollectionSubtype
}

export type RequestAlbumMediasRequest = {
  id: string
  height: number
  width: number
  quality: number
}

export type CheckAlbumCanOperationRequest = {
  id: string
  operation: PHCollectionEditOperation
}

export type CreateAlbumRequest = {
  title: string
}

export type CreateMediaRequest = {
  album: string
  files: string[]
}

export type Identifier = string

export type Identifiers = Identifier[]

export type DeleteAlbumRequest = {
  identifiers: Identifiers
}

export type DeleteAlbumMediasRequest = {
  album: string
  identifiers: Identifiers
}

export type PluginReturnValue<T> = {
  value?: T
}

/**
 * request photo auth
 *
 * @returns auth status
 */
export async function requestPhotosAuth(): Promise<PhotosAuthorizationStatus | null> {
  return await invoke<PluginReturnValue<PhotosAuthorizationStatus>>(
    'plugin:ios-photos|request_photos_auth',
    { payload: {} }
  ).then((r) => r.value ?? null)
}

/**
 * get authorized status
 *
 * @returns auth status
 */
export async function getPhotosAuthStatus(): Promise<PhotosAuthorizationStatus | null> {
  return await invoke<PluginReturnValue<PhotosAuthorizationStatus>>(
    'plugin:ios-photos|get_photos_auth_status',
    { payload: {} }
  ).then((r) => r.value ?? null)
}

/**
 * request user device albums
 *
 * @param payload request payload
 * @returns album list
 */
export async function requestAlbums(payload: RequestAlbumRequest): Promise<AlbumItem[]> {
  return await invoke<PluginReturnValue<AlbumItem[]>>('plugin:ios-photos|request_albums', {
    payload
  }).then((r) => r.value ?? [])
}

/**
 * request user medias by album
 *
 * @param payload request payload
 * @returns album contain medias list
 */
export async function requestAlbumMedias(payload: RequestAlbumMediasRequest): Promise<MediaItem[]> {
  return await invoke<PluginReturnValue<MediaItem[]>>('plugin:ios-photos|request_album_medias', {
    payload
  }).then((r) => r.value ?? [])
}

/**
 * check album support operation status
 *
 * @param payload request payload
 * @returns does the album support operation status
 */
export async function checkAlbumCanOperation(
  payload: CheckAlbumCanOperationRequest
): Promise<boolean> {
  return await invoke<PluginReturnValue<boolean>>('plugin:ios-photos|check_album_can_operation', {
    payload
  }).then((r) => r.value ?? false)
}

/**
 * create album
 *
 * @param payload request payload
 * @returns created album identifier
 */
export async function createAlbum(payload: CreateAlbumRequest): Promise<Identifier | null> {
  return await invoke<PluginReturnValue<Identifier>>('plugin:ios-photos|create_album', {
    payload
  }).then((r) => r.value ?? null)
}

/**
 * create photo to album
 *
 * @param payload request payload
 * @returns created photos identifiers
 */
export async function createPhotos(payload: CreateMediaRequest): Promise<Identifiers | null> {
  return await invoke<PluginReturnValue<Identifiers>>('plugin:ios-photos|create_photos', {
    payload
  }).then((r) => r.value ?? [])
}

/**
 * create videos to album
 *
 * @param payload request payload
 * @returns created videos identifiers
 */
export async function createVideos(payload: CreateMediaRequest): Promise<Identifiers | null> {
  return await invoke<PluginReturnValue<Identifiers>>('plugin:ios-photos|create_videos', {
    payload
  }).then((r) => r.value ?? [])
}

/**
 * delete album, is forever
 *
 * @param payload request payload
 * @returns was the delete album success
 */
export async function deleteAlbum(payload: DeleteAlbumRequest): Promise<boolean> {
  return await invoke<PluginReturnValue<boolean>>('plugin:ios-photos|delete_album', {
    payload
  }).then((r) => r.value ?? false)
}

/**
 * delete medias from album, is forever
 *
 * @param payload request payload
 * @returns was the delete album medias success
 */
export async function deleteAlbumMedias(payload: DeleteAlbumMediasRequest): Promise<boolean> {
  return await invoke<PluginReturnValue<boolean>>('plugin:ios-photos|delete_album_medias', {
    payload
  }).then((r) => r.value ?? false)
}

/**
 * remove medias from album , is not forever
 *
 * @param payload request payload
 * @returns was the remove album medias success
 */
export async function removeAlbumMedias(payload: DeleteAlbumMediasRequest): Promise<boolean> {
  return await invoke<PluginReturnValue<boolean>>('plugin:ios-photos|remove_album_medias', {
    payload
  }).then((r) => r.value ?? false)
}
