import { invoke } from '@tauri-apps/api/core'

export const PhotosAuthorizationStatus = {
  notDetermined: 0,
  restricted: 1,
  denied: 2,
  authorized: 3,
  limited: 4
} as const satisfies Record<string, number>

export const PHCollectionEditOperation = {
  deleteContent: 1,
  removeContent: 2,
  addContent: 3,
  createContent: 4,
  rearrangeContent: 5,
  delete: 6,
  rename: 7
} as const satisfies Record<string, number>

export const PHAssetCollectionType = {
  album: 1,
  smartAlbum: 2
} as const satisfies Record<string, number>

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
  any: 9223372036854775807n
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

export async function requestPhotosAuth(): Promise<PhotosAuthorizationStatus | null> {
  return await invoke<{ value?: PhotosAuthorizationStatus }>(
    'plugin:ios-photos|request_photos_auth',
    { payload: {} }
  ).then((r) => r.value ?? null)
}

export async function getPhotosAuthStatus(): Promise<PhotosAuthorizationStatus | null> {
  return await invoke<{ value?: PhotosAuthorizationStatus }>(
    'plugin:ios-photos|get_photos_auth_status',
    { payload: {} }
  ).then((r) => r.value ?? null)
}

export async function requestAlbums(payload: RequestAlbumRequest): Promise<AlbumItem[]> {
  return await invoke<{ value?: AlbumItem[] }>('plugin:ios-photos|request_albums', {
    payload
  }).then((r) => r.value ?? [])
}

export async function requestAlbumMedias(payload: RequestAlbumMediasRequest): Promise<MediaItem[]> {
  return await invoke<{ value?: MediaItem[] }>('plugin:ios-photos|request_album_medias', {
    payload
  }).then((r) => r.value ?? [])
}

export async function checkAlbumCanOperation(
  payload: CheckAlbumCanOperationRequest
): Promise<boolean> {
  return await invoke<{ value?: boolean }>('plugin:ios-photos|check_album_can_operation', {
    payload
  }).then((r) => r.value ?? false)
}

export async function createAlbum(payload: CreateAlbumRequest): Promise<Identifier | null> {
  return await invoke<{ value?: Identifier }>('plugin:ios-photos|create_album', { payload }).then(
    (r) => r.value ?? null
  )
}
export async function createPhotos(payload: CreateMediaRequest): Promise<Identifiers | null> {
  return await invoke<{ value?: Identifiers }>('plugin:ios-photos|create_photos', { payload }).then(
    (r) => r.value ?? []
  )
}
export async function createVideos(payload: CreateMediaRequest): Promise<Identifiers | null> {
  return await invoke<{ value?: Identifiers }>('plugin:ios-photos|create_videos', { payload }).then(
    (r) => r.value ?? []
  )
}
