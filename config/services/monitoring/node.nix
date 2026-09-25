{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.glyph.monitoring.node;
in
{
  options.glyph.monitoring.node = {
    enable = mkOption {
      description = "Enable node metrics collection";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    glyph.monitoring.exporters = [
      "node"
      "smartctl"
      "systemd"
    ];

    services.prometheus.exporters.smartctl.maxInterval = "10m";

    glyph.transpose.prometheus.rules."node-health".records = {
      "fs:disk_usage_ratio" =
        ''1 - node_filesystem_free_bytes{fstype!="ramfs",fstype!="tmpfs"} / node_filesystem_size_bytes'';
      "system:uptime_seconds" = "time() - node_boot_time_seconds";
      "system:cores_total" = ''count by(instance,job) (node_cpu_seconds_total{mode="idle"})'';
      "system:cpu_utilization" = "sum without(cpu) (irate(node_cpu_seconds_total[5m]))";
      "system:cpu_utilization_normalized_ratio" =
        "system:cpu_utilization / on(instance,job) group_left() system:cores_total";
      "system:load_normalized_ratio" = "node_load15 / system:cores_total";
      "system:mem_used_ratio" = "1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)";
    };
    glyph.transpose.prometheus.rules."node-health".alerts = {
      "FileSystemSpaceHeadsUp" = {
        expr = "predict_linear(fs:disk_usage_ratio[14d], 12 * 7 * 24 * 3600) > 0.95";
        for = "1d";
        labels.severity = "low";
        annotations.summary = "{{ $labels.instance }} is low on disk space";
        annotations.description = "File system at {{ $labels.mountpoint }} (device {{ $labels.device }}) will fill up within 12 weeks";
      };
      "FileSystemSpaceUrgentHeadsUp" = {
        expr = "predict_linear(fs:disk_usage_ratio[14d], 2 * 7 * 24 * 3600) >= 0.95";
        for = "1d";
        labels.severity = "severe";
        annotations.summary = "{{ $labels.instance }} is very low on disk space";
        annotations.description = "File system at {{ $labels.mountpoint }} (device {{ $labels.device }}) will fill up within 2 weeks";
      };
      "FileSystemSpaceCriticallyLow" = {
        expr = "fs:disk_usage_ratio >= 0.95";
        for = "15m";
        labels.severity = "critical";
        annotations.summary = "{{ $labels.instance }} is critically low on disk space";
        annotations.description = "The file system at {{ $labels.mountpoint }} (device {{ $labels.device }}) is over 95% full";
      };
      "NeedsReboot" = {
        expr = "system:uptime_seconds > 2 * 14 * 24 * 3600";
        labels.severity = "low";
        annotations.summary = "{{ $labels.instance }} needs a reboot";
        annotations.description = "Not rebooted for {{ $value | humanizeDuration }}";
      };
      "PersistentElevatedLoad" = {
        expr = "system:load_normalized_ratio > 0.5";
        for = "24h";
        labels.severity = "low";
        annotations.summary = "{{ $labels.instance }} has elevated load";
        annotations.description = "Above 50% for at least 24h (currently {{ $value | humanizePercentage }})";
      };
      "MemLow" = {
        expr = "system:mem_used_ratio > 0.8";
        for = "1h";
        labels.severity = "low";
        annotations.summary = "{{ $labels.instance }} is low on memory";
        annotations.description = "Memory usage above 80%";
      };
      "MemVeryLow" = {
        expr = "system:mem_used_ratio > 0.9";
        for = "10m";
        labels.severity = "moderate";
        annotations.summary = "{{ $labels.instance }} is very low on memory";
        annotations.description = "Memory usage above 90%";
      };
    };
    glyph.transpose.prometheus.rules."service-health".alerts = {
      "ServiceFailed" = {
        expr = ''systemd_unit_state{state="failed"} > 0'';
        for = "5m";
        labels.severity = "severe";
        annotations.summary = "Instance {{ $labels.instance }}: Unit {{ $labels.name }} failed";
      };
      "ServiceHanging" = {
        expr = ''systemd_unit_state{state="starting"} > 0'';
        for = "10m";
        labels.severity = "severe";
        annotations.summary = "Instance {{ $labels.instance }}: Unit {{ $labels.name }} is hanging";
      };
      "MonitorDown" = {
        expr = "up == 0";
        for = "10m";
        labels.severity = "moderate";
        annotations.summary = "Instance {{ $labels.instance }}: Monitor {{ $labels.job }} is down";
      };
    };
  };
}
