{
  lib,
  config,
  ...
}:
let
  humanUsers = lib.attrNames config.glyph.users;
  # provided a function `f: name -> attrset -> attrset,
  # generate { [name :: f name (glyph.users.name)] }
  eachHumanUser = lib.flip lib.mapAttrs config.glyph.users;
  eachHumanUser' = lib.genAttrs humanUsers;
  eachHumanUserAndRoot = lib.flip lib.mapAttrs ({ root = { }; } // config.glyph.users);
  eachHumanUserAndRoot' = lib.genAttrs (lib.uniqueStrings (humanUsers ++ [ "root" ]));

  is-sluglike =
    c:
    lib.elem c [
      "a"
      "b"
      "c"
      "d"
      "e"
      "f"
      "g"
      "h"
      "i"
      "j"
      "k"
      "l"
      "m"
      "n"
      "o"
      "p"
      "q"
      "r"
      "s"
      "t"
      "u"
      "v"
      "w"
      "x"
      "y"
      "z"
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      " "
      "-"
      "_"
    ];
  slugify = str: with lib; replaceStrings [ "_" " " ] [ "-" "-" ] (filter is-sluglike (toLower str));

  color-strip = col: builtins.head (builtins.match "#?([[:xdigit:]]{6})" col);

  mkRo =
    val:
    lib.mkOption {
      readOnly = true;
      default = val;
    };
in
{

  options.glib = lib.mkOption {
    description = "glyph user lib";
    readOnly = true;
    default = { };
    type = lib.types.submodule {
      options = {
        humanUsers = mkRo humanUsers;
        eachHumanUser = mkRo eachHumanUser;
        eachHumanUser' = mkRo eachHumanUser';
        eachHumanUserAndRoot = mkRo eachHumanUserAndRoot;
        eachHumanUserAndRoot' = mkRo eachHumanUserAndRoot';

        str = {
          is-sluglike = mkRo is-sluglike;
          slugify = mkRo slugify;
        };

        color = {
          strip = mkRo color-strip;
        };

        mkRo = mkRo mkRo;

        systemd.mkParanoid = mkRo (
          {
            confinement ? true,
            confinementPackages ? [ ],
          }:
          serviceConfig@{
            ProtectHome ? true, # Restrict access to home directories, allowed are (in order of severity) false, read-only, tmpfs, true
            ProtectSystem ? "strict", # Restrict access to system directories, allowed are (in order of severity) false, true, strict, full
            PrivateTmp ? true, # Create a private tmpfs overlay
            DynamicUser ? true, # Allocate a dynamic user id (implies ProtectHome and ). UMask and BindPaths may help
            BindPaths ? [ ], # FS paths to make accessible (r/w) to the service (may contain mappings)
            BindReadOnlyPaths ? [ ], # FS paths to make accessible (r/0) to the service (may contain mappings)
            NoNewPrivileges ? true, # Prevent suid of process
            CapabilityBoundingSet ? [ "~" ], # Limit capabilities of service (default ~ is nothing). See below for details
            AmbientCapabilities ? [ ], # Grant default capabilities of service. See below for details
            PrivateDevices ? true, # Hide all devices but /dev/null, /dev/random, /dev/tty
            ProtectHostname ? true, # Unshare (but do not hide) hostname. Optionally a new hostname can be set by `yes:example.com`
            ProtectClock ? true, # Prevent changes to hardware clock
            ProtectKernelTunables ? true, # Protect /proc subsystem
            ProtectKernelModules ? true, # Prevent module loading/unloading
            ProtectKernelLogs ? true, # Prevent access to syslog
            ProtectControlGroups ? "strict", # Protect cgroup hierarchy, allowed are (in order of severity) false, private, true, strict
            RestrictAddressFamilies ? [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ],
            RestrictNamespaces ? true, # Prevent creation and switching of namespaces. Options are false, true, or space-separated list of namespaces
            LockPersonality ? true, # Prevent changes to personality(2) (https://man7.org/linux/man-pages/man2/personality.2.html)
            MemoryDenyWriteExecute ? true, # Prevent creation of writeable, executable memory (may be required for JIT runtimes)
            RestrictSUIDSGID ? true, # Prevent setting suid/sgid bits
            RemoveIPC ? true, # Remove IPC devices on process exit
            PrivateMounts ? true, # Do not propagate mounts of service to system
            SystemCallFilter ? [
              "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid"
            ],
            SystemCallArchitecture ? "native",
          }:
          # Capability primer
          #   - https://man7.org/linux/man-pages/man7/capabilities.7.html
          #   - systemd-analyze capability
          # Useful capabilities:
          # - CAP_NET_BIND_SERVICE for binding to ports < 1024
          # everything else is not useful for most services and you'll know when you need it :)
          systemdConfig:
          lib.mkMerge [
            systemdConfig
            { inherit serviceConfig; }
            {
              confinement.enable = confinement;
              confinement.packages = confinementPackages;
            }
          ]
        );
      };
    };
  };
}
