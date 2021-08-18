{ pkgs, ... }:

{
  enable = true;
  settings = rec {
    global = {
      font = "Noto Sans 11";
      markup = "full";
      format = "<b>%s</b>\\n%b";
      show_indicators = true;

      sort = true;
      indicate_hidden = true;
      stack_duplicates = true;
      sticky_history = true;
      history_length = 20;

      alignment = "right";
      word_wrap = true;
      ignore_newline = false;

      show_age_threshold = 60;

      frame_width = 3;
      geometry = "300x5-20+20";
      shrink = false;
      max_icon_size = 32;
      transparency = 0;
      monitor = 0;
      follow = "keyboard";
      line_height = 5;
      separator_height = 2;
      padding = 10;
      horizontal_padding = 10;
      separator_color = "auto"; 
      icon_position = "left"; 
      frame_color = "#3f3f3f";

      idle_threshold = 120; 
      startup_notification = false; 

      dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst"; 
      browser = "${pkgs.latest.firefox-nightly-bin}/bin/firefox -new-tab"; 
    };
    frame = {
      color = "#282828";
      width = 0;
    };
    urgency_low = {
      background = "#282828";
      foreground = "#ebdbb2";
      timeout = 5;
    };
    urgency_normal = urgency_low;
    urgency_critical = urgency_low;
  };
}
