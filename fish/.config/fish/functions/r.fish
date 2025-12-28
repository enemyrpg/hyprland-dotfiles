function r --wraps='sudo pacman -Rns' --description 'alias r=sudo pacman -Rns'
    sudo pacman -Rns $argv
end
