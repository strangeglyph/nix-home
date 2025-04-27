{ stylix }:

let
  colors = stylix.base16Scheme;
  fonts = stylix.fonts;
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
  background-color: alpha(#${colors.alt-base}, 0.8);
  padding: .5em;
  color: #${colors.main-text};
  box-shadow: 0px 2px 7px 2px alpha(#${colors.main-base}, 0.5);
  border: 2px solid #${colors.accent};
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
  background: #${colors.main-base};
}

#workspaces button {
  transition: none;
  color: #${colors.main-text};
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
  color: #${colors.alt-accent};
  border-color: #${colors.alt-accent}; 
}

#workspaces button.focused {
  color: #${colors.accent};
  border-top: 2px solid #${colors.accent};
  border-bottom: 2px solid #${colors.accent};
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
  border-left: 2px solid #${colors.accent};
}

#workspaces button.focused:last-child {
  border-right: 2px solid #${colors.accent};
}

#workspaces button.focused:hover {
  color: #${colors.alt-accent};
}

#workspaces button.urgent {
  color: #${colors.urgent};
  border-top: 2px solid #${colors.urgent};
  border-bottom: 2px solid #${colors.urgent};
}

#workspaces button.urgent:first-child {
  border-left: 2px solid #${colors.urgent};
}

#workspaces button.urgent:last-child {
  border-right: 2px solid #${colors.urgent};
}

#workspaces button.urgent:hover {
  color: #${colors.alt-accent};
}

#mode {
  background: #${colors.main-base};
  border-radius: 10px;
  margin-top: 6px;
  margin-left: 12px;
  margin-bottom: 6px;
  color: #${colors.highlight};
}


#network {
  color: #${colors.main-base};
  background: #${colors.pastel-purple};
  padding-left: 10px;
  padding-right: 10px;
  margin: 6px;
}

#battery {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-yellow-green};
}

#battery.charging, #battery.plugged {
  color: #${colors.main-base};
  background: #${colors.pastel-yellow-green};
}

#battery.critical:not(.charging) {
  color: #${colors.main-base};
  background: #${colors.urgent};
  border: 2px solid #${colors.urgent};
  animation-name: blink;
  animation-duration: 0.5s;
  animation-timing-function: ease-in-out;
  animation-iteration-count: infinite;
  animation-direction: alternate;  
}

@keyframes blink {
  to {
    color: #${colors.urgent};
    background: #${colors.main-base};
  }
}

#backlight {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-blue};
}

#pulseaudio  {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-green-blue};
}

#clock {
  margin: 6px; 
  padding-left: 10px; 
  padding-right: 10px; 
  color: #${colors.main-base}; 
  background: #${colors.pastel-yellow};
}

#disk {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-purple-pink};
}

#memory {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-pink};
}

#cpu {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-red};
}

#tray {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-text};
  background: #${colors.main-base};
  font-family: ${fonts.sansSerif.name};
}

#tray menu {
  background: alpha(#${colors.main-base}, 0.8);
  color: #${colors.main-text};
  box-shadow: 0px 2px 7px 2px alpha(#${colors.main-base}, 0.5);
  border: 2px solid #${colors.accent};
  border-radius: 10px;
  background-clip: border-box;
}

#custom-notifications {
  margin: 6px;
  padding-left: 10px;
  padding-right: 10px;
  color: #${colors.main-base};
  background: #${colors.pastel-green};
}
''
