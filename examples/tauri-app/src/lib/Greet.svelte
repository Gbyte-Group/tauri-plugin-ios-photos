<script>
  import { createAlbum } from 'tauri-plugin-ios-photos-api'
  const { receiveID } = $props()

  let name = $state('')
  let greetMsg = $state('')

  function createNewAlbum(title) {
    createAlbum({ title }).then((id) => {
      console.log({ id })
      greetMsg = `create album id ${id}`
      receiveID(id)
    })
  }

  async function greet() {
    // Learn more about Tauri commands at https://v2.tauri.app/develop/calling-rust/#commands
    // greetMsg = await invoke('greet', { name })
    createNewAlbum(name)
  }
</script>

<div>
  <div class="row">
    <input
      id="greet-input"
      placeholder="Enter a name..."
      bind:value={name}
    />
    <button onclick={greet}> Greet </button>
  </div>
  <p>{greetMsg}</p>
</div>
