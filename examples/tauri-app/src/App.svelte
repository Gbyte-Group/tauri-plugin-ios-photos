<script>
  import Greet from './lib/Greet.svelte'
  import {
    PhotosAuthorizationStatus,
    requestPhotosAuth,
    requestAlbums,
    requestAlbumMedias
  } from 'tauri-plugin-ios-photos-api'

  let response = $state('')
  let photoAuth = $state('未请求')
  /**
   * @type { import('tauri-plugin-ios-photos-api').AlbumItem[] }
   */
  let albums = $state([])
  let medias = $state([])

  function updateResponse(returnValue) {
    response +=
      `[${new Date().toLocaleTimeString()}] ` +
      (typeof returnValue === 'string' ? returnValue : JSON.stringify(returnValue)) +
      '<br>'
  }

  function _ping() {
    // ping('Pong!').then(updateResponse).catch(updateResponse)
  }

  function requestPhotoAuth() {
    requestPhotosAuth().then((status) => {
      switch (status) {
        case PhotosAuthorizationStatus.authorized:
          photoAuth = '已授权'
          break
        case PhotosAuthorizationStatus.denied:
          photoAuth = '拒绝'
          break
        case PhotosAuthorizationStatus.limited:
          photoAuth = '被限制'
          break
        case PhotosAuthorizationStatus.restricted:
          photoAuth = '有限的'
          break
        case PhotosAuthorizationStatus.notDetermined:
          photoAuth = '非持久的'
          break
      }
    })
  }

  function getAlbums() {
    requestAlbums().then((value) => {
      console.log({ value })
      albums = value
    })
  }

  function requestMedia(id) {
    console.log({ id })
    requestAlbumMedias({ id, height: 800, width: 800, quality: 0.9 })
      .then((v) => {
        console.log({ v })
        medias = v
      })
      .catch((e) => {
        console.log('request media e', e)
      })
      .finally(() => {
        console.log('request media finish')
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
    <Greet />
  </div>

  <div>
    <button onclick={_ping}>Ping</button>
    <div>{@html response}</div>
    <button onclick={requestPhotoAuth}>requestPhotoAuth</button>
    <div>{@html photoAuth}</div>
    <button onclick={getAlbums}>getAlbums</button>
    <ul>
      {#each albums as album}
        <li
          style="height: 3rem; width: 100%; background: pink;"
          onclick={() => requestMedia(album.id)}
        >
          {album.name}
        </li>
      {/each}
    </ul>
    <ul>
      {#each medias as media}
        <li>
          <img
            src={`temp:/${media?.data ?? ''}`}
            alt={media.id}
          />
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
