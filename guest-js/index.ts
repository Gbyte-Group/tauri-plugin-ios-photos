import { invoke } from '@tauri-apps/api/core'

export const PhotosAuthorizationStatus = {
  notDetermined: 0,
  restricted: 1,
  denied: 2,
  authorized: 3,
  limited: 4
} as const satisfies Record<string, number>

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

export type RequestAlbumMediasRequest = {
  id: string
  height: number
  width: number
  quality: number
}

export type PhotosAuthorizationStatus =
  (typeof PhotosAuthorizationStatus)[keyof typeof PhotosAuthorizationStatus]

export async function requestPhotosAuth(): Promise<PhotosAuthorizationStatus | null> {
  return await invoke<{ value?: PhotosAuthorizationStatus }>(
    'plugin:ios-photos|request_photos_auth',
    { payload: {} }
  ).then((r) => r.value ?? null)
}

export async function requestAlbums(): Promise<AlbumItem[]> {
  return await invoke<{ value?: AlbumItem[] }>('plugin:ios-photos|request_albums', {
    payload: {}
  }).then((r) => r.value ?? [])
}

export async function requestAlbumMedias(payload: RequestAlbumMediasRequest): Promise<MediaItem[]> {
  return await invoke<{ value?: MediaItem[] }>('plugin:ios-photos|request_album_medias', {
    payload
  }).then((r) => r.value ?? [])
}
