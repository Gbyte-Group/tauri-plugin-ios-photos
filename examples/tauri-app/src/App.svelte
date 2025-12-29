<script>
  import Greet from './lib/Greet.svelte'
  import {
    PhotosAuthorizationStatus,
    PHCollectionEditOperation,
    PHAssetCollectionType,
    PHAssetCollectionSubtype,
    requestPhotosAuth,
    getPhotosAuthStatus,
    requestAlbums,
    requestAlbumMedias,
    checkAlbumCanOperation,
    createPhotos,
    createVideos,
    deleteAlbum,
    deleteAlbumMedias,
    removeAlbumMedias
  } from 'tauri-plugin-ios-photos-api'

  let response = $state('')
  let photoAuth = $state('not request')
  let albumID = $state('')
  let msg = $state('')
  let subtype = $state(PHAssetCollectionSubtype.albumRegular)

  /**
   * @type { import('tauri-plugin-ios-photos-api').AlbumItem[] }
   */
  let albums = $state([])
  /**
   * @type { import('tauri-plugin-ios-photos-api').MediaItem[] }
   */
  let medias = $state([])
  let selectAlbumId = $state('')

  function matchStatus(status) {
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
  }

  function requestPhotoAuth() {
    requestPhotosAuth().then(matchStatus)
  }

  function getPhotoAuthStatus() {
    getPhotosAuthStatus().then(matchStatus)
  }

  function getSmartAlbums() {
    requestAlbums({
      with: PHAssetCollectionType.smartAlbum,
      subtype
    }).then((value) => {
      console.log({ value })
      albums = value
    })
  }

  function getAlbums() {
    requestAlbums({
      with: PHAssetCollectionType.album,
      subtype
    }).then((value) => {
      console.log({ value })
      albums = value
    })
  }

  function requestMedia(id, title) {
    response = ''
    for (const [key, val] of Object.entries(PHCollectionEditOperation)) {
      checkAlbumCanOperation({
        id,
        operation: val
      })
        .then((status) => {
          response += `<br/>${title} ${key} status: [${status}]`
        })
        .catch((e) => {
          console.log({ e })
        })
    }

    requestAlbumMedias({ id, height: 800, width: 800, quality: 0.9 })
      .then((v) => {
        console.log({ v })
        selectAlbumId = id
        medias = v
      })
      .catch((e) => {
        console.log('request media e', e)
      })
      .finally(() => {
        console.log('request media finish')
      })
  }

  function createMedia(file) {
    console.log({ file, albumID })

    const fn = file.endsWith('.mp4') ? createVideos : createPhotos

    fn({
      album: albumID,
      files: [file]
    }).then((ids) => {
      console.log({ ids })
      msg += '<br/>' + ids.join('<br/>')
    })
  }

  function deleteSelectAlbum(id) {
    deleteAlbum({ identifiers: [id] })
      .then((r) => {
        msg += '<br/>' + `delete album by ${id} [${r ? 'success' : 'fail'}] <br/>`
      })
      .catch((e) => {
        msg += '<br/>' + `delete album by ${id} error: ${e?.message ?? e} <br/>`
      })
  }

  function deleteSelectAlbumMedias(medias) {
    deleteAlbumMedias({
      album: selectAlbumId,
      identifiers: medias
    })
      .then((r) => {
        msg +=
          '<br/>' +
          `delete album ${selectAlbumId} medias by ${medias.join('<br/><hr/><br/>')} [${r ? 'success' : 'fail'}] <br/>`
      })
      .catch((e) => {
        msg +=
          '<br/>' +
          `delete album ${selectAlbumId} medias by ${medias.join('<br/><hr/><br/>')} error: ${e?.message ?? e} <br/>`
      })
  }

  function removeSelectAlbumMedias(medias) {
    removeAlbumMedias({
      album: selectAlbumId,
      identifiers: medias
    })
      .then((r) => {
        msg +=
          '<br/>' +
          `delete album ${selectAlbumId} medias by ${medias.join('<br/><hr/><br/>')} [${r ? 'success' : 'fail'}] <br/>`
      })
      .catch((e) => {
        msg +=
          '<br/>' +
          `delete album ${selectAlbumId} medias by ${medias.join('<br/><hr/><br/>')} error: ${e?.message ?? e} <br/>`
      })
  }
</script>

<main class="container">
  <h1>Welcome to Tauri!</h1>

  <div class="row">
    <a
      href="https://vite.dev"
      target="_blank"
    >
      <img
        src="/vite.svg"
        class="logo vite"
        alt="Vite Logo"
      />
    </a>
    <a
      href="https://tauri.app"
      target="_blank"
    >
      <img
        src="/tauri.svg"
        class="logo tauri"
        alt="Tauri Logo"
      />
    </a>
    <a
      href="https://svelte.dev"
      target="_blank"
    >
      <img
        src="/svelte.svg"
        class="logo svelte"
        alt="Svelte Logo"
      />
    </a>
  </div>

  <p>Click on the Tauri, Vite, and Svelte logos to learn more.</p>

  <div class="row">
    <Greet
      receiveID={(id) => {
        albumID = id
      }}
    />
  </div>

  <div>
    <button onclick={getPhotoAuthStatus}>get status</button>
    <div>{@html response}</div>
    <button onclick={requestPhotoAuth}>requestPhotoAuth</button>
    <div>{@html photoAuth}</div>
    <button onclick={getAlbums}>get normal albums</button>
    <button onclick={getSmartAlbums}>get smart albums</button>
    <div>{@html msg}</div>
    <input
      type="number"
      value={subtype}
      onchange={(e) => {
        subtype = e.target.valueAsNumber
      }}
    />
    <ul>
      {#each albums as album}
        <li
          style="height: 3rem; width: 100%; background: pink;"
          onclick={() => requestMedia(album.id, album.name)}
        >
          {album.name}
          <button onclick={() => deleteSelectAlbum(album.id)}>delete this album</button>
        </li>
      {/each}
    </ul>
    <ul>
      {#each medias as media}
        <li onclick={() => createMedia(media.data)}>
          <img
            src={`temp:/${media?.data ?? ''}`}
            alt={media.id}
          />
          <button onclick={() => deleteSelectAlbumMedias([media.id])}>delete</button>
          <button onclick={() => removeSelectAlbumMedias([media.id])}>remove</button>
        </li>
      {/each}
    </ul>
  </div>
</main>

<style>
  .logo.vite:hover {
    filter: drop-shadow(0 0 2em #747bff);
  }

  .logo.svelte:hover {
    filter: drop-shadow(0 0 2em #ff3e00);
  }
</style>
