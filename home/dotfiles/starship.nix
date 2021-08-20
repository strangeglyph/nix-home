{ pkgs, lib, ... }:

{
  enable = true;
  enableFishIntegration = true;
  settings = {
    format = lib.concatStrings [
      "[\\[$username@$hostname\\]](green)\n"
      "$nix_shell"
      "$directory" "$git_branch" "$git_commit" "$git_status" "\n"
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
  };
}
