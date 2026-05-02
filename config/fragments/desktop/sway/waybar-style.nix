{ config }:

let
  theme = config.glyph.theme;
  scheme = theme.color.schemes.${theme.color.sway};
  fonts = theme.fonts;
  inherit (scheme.mnemonics)
    background
    foreground
    category
    color
    ;
in
''
  * {
    border: none;
    border-radius: 10px;
    font-family: ${fonts.monospace.name};
    font-size: 16px;
    min-height: 10px;
    background: transparent;
    min-width: 2em;
  }

  tooltip label {
    background-color: alpha(${background.secondary}, 0.8);
    padding: .5em;
    color: ${foreground.main};
    box-shadow: 0px 2px 7px 2px alpha(${foreground.main}, 0.5);
    border: 2px solid ${category.accent};
    border-radius: 10px;
    background-clip: border-box;
  }

  #window {
    margin-top: 6px;
    padding-left: 10px;
    padding-right: 10px;
    border-radius: 10px;
    transition: none;
    color: transparent;
    background: transparent;
  }


  #workspaces {
    margin-top: 6px;
    margin-left: 12px;
    margin-bottom: 6px;
    font-size: 4px;
    border-radius: 10px;
    background: ${background.main};
  }

  #workspaces button {
    transition: none;
    color: ${foreground.main};
    background: transparent;
    font-size: 16px;
    border-radius: 2px;
  }

  #workspaces button:not(.focused) {
    margin-top: 2px;
    margin-bottom: 2px;
  }


  #workspaces button:hover {
    transition: none;
    box-shadow: inherit;
    text-shadow: inherit;
    color: ${category.focus};
    border-color: ${category.focus}; 
  }

  #workspaces button.focused {
    color: ${category.accent};
    border-top: 2px solid ${category.accent};
    border-bottom: 2px solid ${category.accent};
  }

  #workspaces button:first-child {
    border-top-left-radius: 10px;
    border-bottom-left-radius: 10px;
  }

  #workspaces button:last-child {
    border-top-right-radius: 10px;
    border-bottom-right-radius: 10px;
  }

  #workspaces button.focused:first-child {
    border-left: 2px solid ${category.focus};
  }

  #workspaces button.focused:last-child {
    border-right: 2px solid ${category.focus};
  }

  #workspaces button.focused:hover {
    color: ${category.accent};
  }

  #workspaces button.urgent {
    color: ${category.alert};
    border-top: 2px solid ${category.alert};
    border-bottom: 2px solid ${category.alert};
  }

  #workspaces button.urgent:first-child {
    border-left: 2px solid ${category.alert};
  }

  #workspaces button.urgent:last-child {
    border-right: 2px solid ${category.alert};
  }

  #workspaces button.urgent:hover {
    color: ${category.accent};
  }

  #mode {
    background: ${background.main};
    border-radius: 10px;
    margin-top: 6px;
    margin-left: 12px;
    margin-bottom: 6px;
    color: ${category.focus};
  }


  #network {
    color: ${background.main};
    background: ${color.magenta.main};
    padding-left: 10px;
    padding-right: 10px;
    margin: 6px;
  }

  #battery {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.green.bright};
  }

  #battery.charging, #battery.plugged {
    color: ${background.main};
    background: ${color.green.bright};
  }

  #battery.critical:not(.charging) {
    color: ${background.main};
    background: ${category.error};
    border: 2px solid ${category.critical};
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: ease-in-out;
    animation-iteration-count: infinite;
    animation-direction: alternate;  
  }

  @keyframes blink {
    to {
      color: ${category.error};
      background: ${background.main};
    }
  }

  #backlight {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.blue.bright};
  }

  #pulseaudio  {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.green.bright};
  }

  #clock {
    margin: 6px; 
    padding-left: 10px; 
    padding-right: 10px; 
    color: ${background.main}; 
    background: ${color.yellow.main};
  }

  #disk {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.magenta.main};
  }

  #memory {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.magenta.bright};
  }

  #cpu {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.red.bright};
  }

  #tray {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${foreground.main};
    background: ${background.main};
    font-family: ${fonts.sans.name};
  }

  #tray menu {
    background: alpha(${background.main}, 0.8);
    color: ${foreground.main};
    box-shadow: 0px 2px 7px 2px alpha(${background.main}, 0.5);
    border: 2px solid ${category.accent};
    border-radius: 10px;
    background-clip: border-box;
  }

  #custom-notifications {
    margin: 6px;
    padding-left: 10px;
    padding-right: 10px;
    color: ${background.main};
    background: ${color.green.bright};
  }
''
