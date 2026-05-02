{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) optional mkOption types;
  cfg = config.glyph.security;
in
{
  options.glyph.security = {
    lockdown = mkOption {
      description = ''
        Kernel lockdown mode. 

        Enabling kernel lockdown mode break hibernation.
        Confidentiality additionally comes with a performance hit.

        Requires lockdown to be enabled in kconfig, which nixos 
        currently (03/2026) does not do.
      '';
      default = "integrity";
      type = types.nullOr (
        types.enum [
          "integrity"
          "confidentiality"
        ]
      );
    };
  };

  config = {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    boot.kernelModules = [ "jitterentropy_rng" ];

    boot.blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    boot.kernel.sysctl = {
      # Relaxed mode
      "yama.ptrace_scope" = "1"; # default

      "fs.protected_hardlinks" = "1"; # default
      "fs.protected_symlinks" = "1"; # default

      # Protect kernel mem from mmap
      "vm.mmap_min_addr" = "65536"; # default

      # Disable support for legacy glibc
      "abi.vsyscall32" = "0";

      # Disable SysRq
      "kernel.sysrq" = "0";

      # No eBPF without CAP_BPF
      "kernel.unprivileged_bpf_disabled" = "1";

      "dev.tty.ldisc_autoload" = "0";

      "kernel.kexec_load_disabled" = "1";

      # Enable strong ASLR
      "kernel.randomize_va_space" = "2"; # default

      # Only allow dmesg for root and CAP_SYSLOG
      "kernel.dmesg_restrict" = "1";
    };

    boot.kernelParams = [
      # Don't merge slabs
      "slab_nomerge"

      # Don't trust HW RNG
      "random.trust_cpu=off"
      "random.trust_bootloader=off"

      # Zero newly-allocated pages
      "init_on_alloc=1"

      # Overwrite free'd pages / check poison on alloc
      # Probably not worth the hit
      # "init_on_free=1"
      # "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"

      # Disable debugfs
      # Apparently causes bugs in networkmanager
      # "debugfs=off"

      # randomises the kernel stack offset on each syscall
      "randomize_kstack_offset=on"

      # disable outdated syscall mechanism
      "vsyscall=none"

      # disable legacy support for old glibc
      "vdso32=0"

      # LSMs
      "apparmor=1"
      "lsm=landlock,lockdown,yama,apparmor"

      "iommu=force"
      "iommu.strict=1"

      # Prevent writing to block devices that are mounted
      "bdev_allow_write_mounted=0"

      # kfence sampling-based memory safety checker
      "kfence.sample_interval=100"
      "kfence.deferrable=1"
    ]
    ++ optional (cfg.lockdown != null) "lockdown=${cfg.lockdown}";

    services.jitterentropy-rngd.enable = true;
  };
}
