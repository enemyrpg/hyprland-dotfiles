source /usr/share/cachyos-fish-config/cachyos-config.fish

# initialize starship prompt
starship init fish | source

# use theme for MANPAGER
export MANPAGER="less -R --use-color -Dd+r -Du+b"

# add y alias helper for yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# set neovim as default editor
export EDITOR=nvim

# set QT6 theme
set -gx QT_QPA_PLATFORMTHEME qt6ct

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
