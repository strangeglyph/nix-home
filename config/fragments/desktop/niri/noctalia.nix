{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  inherit (config) glib;
  theme = config.glyph.theme;
  scheme = theme.color.schemes.${theme.color.noctalia};
  cfg = config.glyph.dm.noctalia;
in
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  options = {
    glyph.dm.noctalia = {
      enable = mkOption {
        description = "Enable the Noctalia shell";
        default = config.glyph.dm.niri.enable;
        type = types.bool;
      };
      animations = mkOption {
        description = "Enable animations for Noctalia (causes sluggish behavior on slower machines)";
        default = true;
        type = types.bool;
      };
      shadows = mkOption {
        description = "Enable shadows for Noctalia (causes some overhead, and may be better suited to compositor)";
        default = true;
        type = types.bool;
      };
    };

    glyph.theme.color.noctalia = mkOption {
      description = "Noctalia color scheme";
      type = types.str;
      default = config.glyph.theme.color.niri;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users = glib.eachHumanUser' (
      name: hm_args: {
        imports = [
          inputs.noctalia.homeModules.default
        ];

        programs = {
          noctalia-shell = {
            enable = true;
            # To allow interactive templating with the noctalia GUI before applying
            # Noctalia v5 has GUI override files, which makes this obsolete
            # nb. Noctalia v5 has GUI override files which may shadow values here
            settings = lib.optionalAttrs true {
              settingsVersion = 59;
              appLauncher = {
                autoPasteClipboard = false;
                enableClipPreview = true;
                enableClipboardChips = true;
                enableClipboardHistory = true;
                enableClipboardSmartIcons = true;
                clipboardWatchImageCommand = "${pkgs.wl-clipboard-rs}/bin/wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store";
                clipboardWatchTextCommand = "${pkgs.wl-clipboard-rs}/bin/wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store";

                enableSessionSearch = true;
                enableSettingsSearch = true;
                enableWindowsSearch = true;

                position = "center";
                overviewLayer = false;
                density = "compact";
                iconMode = "tabler";
                viewMode = "list";
                sortByMostUsed = true;
                showCategories = false;

                pinnedApps = [ ];
                terminalCommand = "${lib.getExe pkgs.alacritty} -e";
              };
              bar = {
                barType = "floating";
                density = "spacious";
                position = "top";
                displayMode = "always_visible";
                hideOnOverview = false;
                background_opacity = 0.93;
                useSeparateOpacity = false;

                fontScale = 1;
                frameRadius = 12;
                frameThickness = 8;
                marginHorizontal = 4;
                marginVertical = 4;
                outerCorners = true;
                showOutline = false;

                showCapsule = true;
                capsuleColorKey = "none";
                capsuleOpacity = 1;
                contentPadding = 2;

                enableExclusionZoneInset = true;

                middleClickAction = "none";
                middleClickCommand = "";
                middleClickFollowMouse = false;

                mouseWheelAction = "none";
                mouseWheelWrap = true;
                reverseScroll = false;

                rightClickAction = "controlCenter";
                rightClickCommand = "";
                rightClickFollowMouse = true;

                screenOverrides = [ ];
                monitors = [ ];

                widgetSpacing = 6;
                widgets = {
                  left = [
                    {
                      id = "Launcher";

                      useDistroLogo = true;
                      icon = "rocket";
                      iconColor = "none";
                      customIconPath = "";

                      enableColorization = false;
                      colorizeSystemIcon = "none";
                      colorizeSystemText = "none";
                    }
                    {
                      id = "SystemMonitor";

                      iconColor = "none";
                      textColor = "none";
                      useMonospaceFont = true;
                      usePadding = false;

                      compactMode = true;

                      showCpuUsage = true;
                      showCpuCores = false;
                      showCpuFreq = false;
                      showCpuTemp = false;
                      showLoadAvage = false;

                      showDiskUsage = true;
                      showDiskUsageAsPercent = false;
                      showDiskAvailable = false;

                      showGpuTemp = false;

                      showMemoryUsage = true;
                      showMemoryAsPercent = false;
                      showSwapUsage = false;

                      showNetworkStats = false;
                    }
                    {
                      id = "Network";

                      displayMode = "onhover";

                      iconColor = "none";
                      textColor = "none";
                    }
                    {
                      id = "MediaMini";

                      compactMode = false;
                      panelShowAlbumArt = true;

                      hideMode = "hidden";
                      hideWhenIdle = true;

                      maxWidth = 150;
                      useFixedWidth = false;

                      textColor = "none";

                      scrollingMode = "always";
                      showArtistFirst = false;
                      showProgressRing = true;
                      showAlbumArt = false;
                      showVisualizer = false;
                    }
                  ];
                  center = [
                    {
                      id = "Workspace";
                      labelMode = "index";

                      emptyColor = "secondary";
                      occupiedColor = "secondary";
                      focusedColor = "primary";

                      enableScrollWheel = true;
                      followFocusedScreen = false;
                      hideUnoccupied = false;
                      showApplications = false;
                      showApplicationsHover = false;
                      showLabelsOnlyWhenOccupied = true;

                      characterCount = 2;
                      fontWeight = "bold";
                      iconScale = 0.8;
                      pillSize = 0.6;
                      colorizeIcons = false;
                      groupedBorderOpacity = 1;
                      unfocusedIconsOpacity = 1;
                      showBadge = true;
                    }
                  ];
                  right = [
                    {
                      id = "Brightness";

                      displayMode = "always";
                      applyToAllMonitors = false;

                      iconColor = "none";
                      textColor = "none";
                    }
                    {
                      id = "Volume";

                      displayMode = "always";
                      middleClickCommand = "${lib.getExe pkgs.pwvucontrol}";

                      iconColor = "none";
                      textColor = "none";
                    }
                    {
                      id = "Battery";

                      deviceNativePath = "__default__";
                      displayMode = "graphic-clean";

                      hideIfIdle = false;
                      hideIfNotDetected = true;

                      showNoctaliaPerformance = false;
                      showPowerProfiles = false;
                    }
                    {
                      id = "NotificationHistory";

                      hideWhenZero = true;
                      hideWhenZeroUnread = false;
                      showUnreadBadge = true;

                      iconColor = "none";
                      unreadBadgeColor = "primary";
                    }
                    {
                      id = "Tray";

                      pinned = [ ];
                      blacklist = [ ];

                      chevronColor = "none";
                      colorizeIcons = false;
                      drawerEnabled = true;
                      hidePassive = false;
                    }
                    {
                      id = "Clock";

                      formatHorizontal = "dd.MM. HH:mm";
                      formatVertical = "HH mm";
                      tooltipFormat = "dd.MM. HH:mm";

                      useCustomFont = false;
                      customFont = "";
                      clockColor = "none";
                    }
                  ];
                };
              };
              brightness = {
                brightnessStep = 5;
                enforeMinimum = true;
                backlightDeviceMappings = [ ];
                enableDdcSupport = false;
              };
              calendar = {
                cards = [
                  {
                    id = "calendar-header-card";
                    enabled = true;
                  }
                  {
                    id = "calendar-month-card";
                    enabled = false;
                  }
                ];
              };
              colorSchemes = {
                darkMode = true;
                schedulingMode = "off";
                #manualSunrise = "07:00";
                #manualSunset = "20:00";
                useWallpaperColors = true;
                generationMethod = "fruit-salad";
                syncGsettings = true;
              };
              controlCenter = {
                cards = [
                  {
                    enabled = true;
                    id = "profile-card";
                  }
                  {
                    enabled = true;
                    id = "shortcuts-card";
                  }
                  {
                    enabled = true;
                    id = "audio-card";
                  }
                  {
                    enabled = true;
                    id = "brightness-card";
                  }
                  {
                    enabled = true;
                    id = "media-sysmon-card";
                  }
                ];
                diskPath = "/";
                position = "close_to_bar_button";
                shortcuts = {
                  left = [
                    { id = "Network"; }
                    { id = "Bluetooth"; }
                    { id = "WallpaperSelector"; }
                    { id = "NoctaliaPerformance"; }
                  ];
                  right = [
                    { id = "Notifications"; }
                    { id = "PoerProfile"; }
                    { id = "KeepAwake"; }
                    { id = "NightLight"; }
                  ];
                };
              };
              desktopWidgets = {
                enabled = false;
              };
              dock = {
                enabled = false;
              };
              general = {
                allowPanelsOnScreenWithoutBar = true;
                boxRadiusRatio = 1;
                iRadiusRatio = 1;
                radiusRatio = 1;
                scaleRatio = 1.1;
                screenRadiusRatio = 1;
                forceBlackScreenCorners = false;
                showScreenCorners = false;
                avatarImage = "/dev/null";
                dimmerOpacity = 0.3;
                enableBlurBehind = true;

                animationDisabled = !cfg.animations;
                animationSpeed = 1;
                enableShadows = cfg.shadows;
                shadowDirection = "bottom_right";
                shadowOffsetX = 2;
                shadowOffsetY = 3;

                reverseScroll = false;
                smoothScrollEanbles = true;

                showChangelogOnStartup = true;
                telemetryEnabled = false;

                # lock screen
                allowPasswordWithFprintd = true;
                autoStartAuth = false;
                clockFormat = "HH\\nmm";
                clockStyle = "custom";
                compactLockScreen = true;
                enableLockScreenCountdown = true;
                enableLockScreenMediaControls = true;
                lockOnSuspend = true;
                lockScreenAnimations = true;
                lockScreenBlur = 0.3;
                lockScreenCountdownDuration = 10000;
                lockScreenMonitors = [ ];
                lockScreenTint = 0.3;
                passwordChars = false;
                showHibernateOnLockScreen = false;
                showSessionButtonsOnLockScreen = true;

                keybinds = {
                  keyDown = [ "Down" ];
                  keyEnter = [
                    "Return"
                    "Enter"
                  ];
                  keyEscape = [ "Esc" ];
                  keyLeft = [ "Left" ];
                  keyRemove = [ "Del" ];
                  keyRight = [ "Right" ];
                  keyUp = [ "Up" ];
                };

                language = "";
              };
              hooks = {
                enabled = false;
              };
              idle = {
                enabled = true;
                customCommands = [ ];

                fadeDuration = 5;
                lockTimeout = 600;
                lockCommand = "";
                resumeLockComand = "";

                screenOffTimeout = 0;
                screenOffCommand = "";
                resumeScreenOffCommand = "";

                suspendTimeout = 0;
                suspendCommand = "";
                resumeSuspendCommand = "";
              };
              location = { };
              network = {
                disableDiscoverability = false;
                bluetoothAutoConnect = true;
                bluetoothDetailsViewMode = "grid";
                bluetoothHideUnnamedDevices = true;
                bluetoothRssiPollIntervalMs = 60000;
                bluetoothRssiPollingEnabled = false;
                networkPanelView = "wifi";
                wifiDetailsViewMode = "grid";
              };
              nightLight = {
                enabled = false;
                forced = false;

                autoSchedule = true;
                dayTemp = 6500;
                nightTemp = 4000;
              };
              noctaliaPerformance = {
                disableDesktopWidgets = true;
                disableWallpaper = false;
              };
              notifications = {
                enabled = true;
                clearDismissed = true;
                density = "default";
                location = "top_right";
                overlayLayer = true;
                monitors = [ ];

                backgroundOpacity = 0.8;
                enableMarkdown = true;

                enableBatterToast = true;
                enableKeyboardLayoutToast = true;
                enableMediaToast = false;

                lowUrgencyDuration = 1;
                normalUrgencyDuration = 2;
                criticalUrgencyDuration = 15;
                respectExpireTimeout = false;

                saveToHistory = {
                  critical = true;
                  normal = true;
                  low = false;
                };

                sounds = {
                  enabled = false;
                  separateSounds = true;
                  volume = 0.5;
                  lowSoundFile = "";
                  normalSoundFile = "";
                  criticalSoundFile = "";
                  excludedApps = "discord,firefox,chrome,chromium,edge";
                };
              };
              osd = {
                # On-Screen-Display - overlays for vol and backlight changes etc
                enabled = true;
                autoHideMs = 2000;
                backgroundOpacity = 1;
                enabledTypes = [
                  0
                  1
                  2
                ];
                location = "top_right";
                monitors = [ ];
                overlayLayer = true;
              };
              plugins = {
                autoUpdate = false;
                notifyUpdates = true;
              };
              sessionMenu = {
                enableCountdown = true;
                countdownDuration = 1000;
                largeButtonsStyle = true;
                largeButtonsLayout = "single-row";
                position = "center";
                showHeader = true;
                showKeybinds = true;

                powerOptions = [
                  {
                    action = "lock";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "l";
                  }
                  {
                    action = "suspend";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "s";
                  }
                  {
                    action = "logout";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "o";
                  }
                  {
                    action = "reboot";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "r";
                  }
                  {
                    action = "shutdown";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "d";
                  }
                ];
              };
              systemMonitor = {
                batteryWarningThreshold = 20;
                batteryCriticalThreshold = 5;

                cpuWarningThreshold = 80;
                cpuCriticalThreshold = 90;

                diskAvailWarningThreshold = 20;
                diskAvailCriticalThreshold = 10;

                diskWarningThreshold = 80;
                diskCriticalThreshold = 90;

                gpuWarningThreshold = 80;
                gpuCriticalThreshold = 90;

                memWarningThreshold = 80;
                memCriticalThreshold = 90;

                swapWarningThreshold = 80;
                swapCriticalThreshold = 90;

                tempWarningThreshold = 80;
                tempCriticalThreshold = 90;

                useCustomColors = false;
                warningColor = "";
                cricialColor = "";
                enableDgpuMonitoring = false;
                externalMonitor = "";
              };
              templates = { };
              ui = {
                fontDefault = "Sans Serif";
                fontDefaultScale = 1;
                fontFixed = "monospace";
                fontFixedScale = 1;

                panelBackgroundOpacity = 0.8;
                panelsAttachedToBar = true;
                boxBorderEnabled = false;

                scrollbarAlwaysVisible = true;
                settingsPanelMode = "attached";
                settingsPanelSideBarCardStyle = false;
                tooltipsEnabled = true;
                translucentWidgets = false;
              };
              wallpaper = {
                enabled = true;
                automationEnabled = true;
                directory = "${hm_args.config.home.homeDirectory}/Wallpapers";
                useWallHaven = false;
                useOriginalImages = true; # Do not rescale
                viewMode = "single";
                wallpaperChangeMode = "random";

                favorites = [ ];
                enableMultiMonitorDirectories = false;
                monitorDirectories = [ ];
                setWallpaperOnAllMonitors = true;

                fillColor = scheme.mnemonics.background.main;
                fillMode = "crop";

                showHiddenFiles = false;
                hideWallpaperFilenames = true;
                linkLightAndDarkWallpapers = true;

                overviewBlur = 0.4;
                overviewtint = 0.6;
                overviewEnabled = false;

                panelPosition = "follow_bar";
                sortOrder = "name";

                randomIntervalSec = 1800;
                skipStartupTransition = false;
                transitionDuration = 1000;
                transitionEdgeSmoothness = 0.05;
                transitionType = [
                  "fade"
                  "disc"
                  "stripes"
                  "wipe"
                  "pixelate"
                  "honeycomb"
                ];
                solidColor = scheme.mnemonics.background.main;
              };
            };
          };
        };
      }
    );
  };
}
