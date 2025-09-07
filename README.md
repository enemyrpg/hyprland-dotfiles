# Dotfiles

This directory contains dotfiles for my Hyprland configuration

## Requirements

Ensure the following packages are installed

### Git & GNU Stow

```
sudo pacman -S --needed git stow
```

### Required Hyprland packages

```
sudo pacman -S --needed hyprland kitty hyprpaper hyprlock waybar wlogout swaync hyprshot wofi thunar gvfs kvantum kvantum-qt5 nwg-look papirus-icon-theme polkit-gnome qt5ct qt6ct
```
```
paru -S catppuccin-gtk-theme-mocha
```
### Additional packages

```
sudo pacman -S --needed fastfetch neovim starship yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick ttf-cascadia-code-nerd
```

## Installation

Clone the dotfiles repo to $HOME directory using git and then symlink using GNU Stow (eg. `stow kitty`)

```
git clone https://github.com/enemyrpg/hyprland-dotfiles.git
cd dotfiles
```
