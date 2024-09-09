<script>
  import "./font.css";
  import { onMount } from "svelte";
  
    let terminalDiv;

    export let title = "hoangtu47's porfolio!";
  
    onMount(async () => {
  
      let term = null;
  
      await import("@xterm/xterm/css/xterm.css");
  
      const { Terminal } = await import("@xterm/xterm");
  
      const { FitAddon } = await import("@xterm/addon-fit");
  
      const { WebLinksAddon } = await import("@xterm/addon-web-links");
  
      var websocket = new WebSocket("wss://shell-backend.mangofield-de3c28fa.southeastasia.azurecontainerapps.io");
  
      websocket.onopen = function (event) {
        term = new Terminal ( {
          cursorBlink: true,
          screenKeys: true,
          useStyle: true
        });
  
        if (term) {
          
          const fitAddon = new FitAddon();
          const linksAddon = new WebLinksAddon();
          term.loadAddon(new FitAddon());
          term.loadAddon(new WebLinksAddon());

          fitAddon.activate(term)
          fitAddon.fit()
          
          // Display a greeting!
          websocket.send("./welcome\n")
          
          term.onKey(keyObj => {
            websocket.send(keyObj.key);
          });
  
          websocket.onmessage = function(event) {
            fitAddon.fit();
            term.write(event.data);
          };
  
          websocket.onclose = function(event) {
            if (term) {
              term.write("Session terminated!");
            }
          };
  
          websocket.onerror = function (event) {
            if (typeof console.log == "function") {
              console.log(event);
            }
          };
  
          term.onTitleChange( function(title) {
            document.title = title;
          });
  
          term.options = {
            fontFamily: "VT323-Regular",
            fontSize: 24,
          };
  
          term.open(terminalDiv);
          term.focus();

          term.onResize(function(event) {
            // Send the resize data as a JSON string via WebSocket
            websocket.send(JSON.stringify({cols: event.cols, rows: event.rows}));
          })

          window.addEventListener("resize", () => {
            fitAddon.fit()});
        }
      }
  
    })
  
  
  </script>
  
  <style>
    :global(body) {
      margin: 0;
      background-color: black;
    }
  
    main {
      background-color: black;
      margin: 0;
      height: 100vh;
    }
  
    #xterm {
      width: 100%;
      height: 100%;
    }
  </style>
  
  <main>
    <div bind:this={terminalDiv} id="xterm" />
  </main>
  
<svelte:head>
  <title>{title}</title>
</svelte:head>

