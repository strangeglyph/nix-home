{ config, pkgs, lib, inputs, ... }:
let
  starship-jj = inputs.starship-jj.packages.${pkgs.stdenv.hostPlatform.system}.starship-jj;
  starship-jj-bin = lib.getExe' starship-jj "starship-jj";
  jjMkModule = type: override: { inherit type; } // override;
  starship-jj-settings = {
    module = [
      (jjMkModule "Commit" {
        max_length = 30;
        empty_text = "[no description]";
        color = "Cyan";
      })
      (jjMkModule "Bookmarks" {
        separator = " / ";
        max_bookmarks = 3;
        surround_with_quotes = false;
      })
      (jjMkModule "State" {})
      (jjMkModule "Metrics" {
        changed_files.prefix = "~";
        changed_files.color = "Cyan";
        added_lines.prefix = "+";
        added_lines.color = "Green";
        removed_lines.prefix = "-";
        removed_lines.color = "Red";
      })
    ];
  };
  starship-jj-config = (pkgs.formats.toml {}).generate "starship-jj.toml" starship-jj-settings;
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = lib.concatStrings [
        "[\\[$username@$hostname\\]](green)\n"
        "$nix_shell"
        "$directory" 
        "$git_branch" "$git_commit" "$git_status" 
        "\${custom.jj}"
        "\n"
        "$character"
      ];
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      directory = {
        truncation_length = 100;
        truncate_to_repo = false;
        format = "in [$path](cyan) ";
      };
      git_branch = {
        format = "on [$branch](cyan) ";
        only_attached = true;
      };
      git_commit = {
        commit_hash_length = 6;
        format = "on [$hash](red)( [\\($tag\\)](yellow)) ";
      };
      git_status = {
        format = "([\\[$staged$deleted$modified$untracked\\]](red) )([\\[$ahead_behind\\]](green) )([\\[$conflicted\\]](red) )";
        staged = "+";
        deleted = "-";
        modified = "~";
        untracked = "?";
        conflicted = "has conflicts";
        ahead = "$count commit(s) ahead";
        behind = "$count commit(s) behind";
        diverged = "$ahead_count commit(s) ahead, $behind_count behind";
      };
      hostname = {
        ssh_only = false;
        trim_at = "";
        format = "$hostname";
      };
      nix_shell = {
        format = "([\\(nix-shell ('$name' )- $state\\)](bold blue))\n";
      };
      username = {
        show_always = true;
        style_root = "red";
        style_user = "green";
        format = "[$user]($style)";
      };
      custom.jj = {
        command = "${starship-jj-bin} --ignore-working-copy starship prompt --starship-config ${starship-jj-config}";
        format = "at $output";
        ignore_timeout = true;
        use_stdin = false;
        when = "jj --ignore-working-copy root >/dev/null 2>&1";
        shell = [ "bash" "-c" ];
      };
    };
  };
}
