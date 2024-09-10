<script>

  import xtermWebFont from "@liveconfig/xterm-webfont";

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
          // initial dimension to match with the shell spawned in backend
          cols: 100,
          rows: 100,

          cursorBlink: true,
          screenKeys: true,
          useStyle: true,

          fontFamily: "VT323",
          fontSize: 24,

        });
  
        if (term) {
          
          const fitAddon = new FitAddon();
          const linksAddon = new WebLinksAddon();
          term.loadAddon(fitAddon);
          term.loadAddon(linksAddon);
          term.loadAddon(new xtermWebFont())
          
          window.addEventListener("resize", () => {
            fitAddon.fit()}
          )

          term.onResize(function(event) {
            // Send the resize data as a JSON string via WebSocket
            websocket.send(JSON.stringify({cols: event.cols, rows: event.rows}));
          })

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
          
          term.loadWebfontAndOpen(terminalDiv);
          
          term.focus();
          
          // Display a greeting!
          websocket.send("./welcome\n")
          
        }
      }
  
    })
  
  
  </script>
  
  <style>
    :global(body) {
      margin: 0;
      background-color: black;
      overflow: hidden; /* Hide scrollbars */
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
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=VT323&display=swap" rel="stylesheet">
</svelte:head>

