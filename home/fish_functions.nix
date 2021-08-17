{
  hm-rollback = {
    body = "(home-manager generations | awk '{print $(NF)}' | head -n2 | tail -n1)/activate";
    description = "Roll back Home to the previous iteration";
  };
  __is_root = {
    body = ''test "(id -u)" = "0"'';
  };
  __highlighted_user = {
    body = ''
        if __is_root
            set_color red
        else
            set_color green
        end
        echo -n $USER
        set_color normal
    '';
  };
  __git_prompt = {
    body = ''
        if git status 1>/dev/null 2>/dev/null
            set_color normal
            echo -n "on "
            set -l ref_name (git symbolic-ref -q --short HEAD || git describe --all --always HEAD);
            set -l git_status_long (git status -uno | head -n2 | tail -n1)
            set -l git_status_short (git status -uno | head -n2 | tail -n1 | cut -d. -f1 | cut -d, -f1 | cut -d' ' -f4-)

            if test "(git status --porcelain)" = ""
                set_color green
            else
                set_color red
            end
            echo -n $ref_name

            if string match -eq 'Your branch' "$git_status_long"
                if string match -eq 'up to date' "$git_status_long"
                    set_color normal
                else
                    set_color magenta
                end
                echo " ($git_status_short)"
            end
        end
    '';
  };
  fish_prompt = {
    body = ''
        echo
        set_color green
        echo [(__highlighted_user)(set_color green)@(hostname)]

        set_color normal
        echo 'in' (set_color cyan) (pwd | sed s@/home/(whoami)@~@) (__git_prompt)

        if __is_root
            set_color red
            echo -n "[!]" (set_color cyan) '$ '
        else
            set_color cyan
            echo -n "> "
        end
        set_color normal
    '';
  };
}
