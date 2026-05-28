#!/bin/bash

# Терминальные цвета для красивого вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Hyprland Environment & Dotfiles Installer ===${NC}\n"

# 1. Check and install packages via pacman
echo -e "${GREEN}[1/4] Checking core dependencies...${NC}"

# Core packages matching your configuration
PACKAGES=(
    hyprland 
    waybar 
    rofi 
    fish 
    fastfetch 
    hyprpaper 
    kitty 
    perl 
    grim 
    slurp
)

for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        echo -e "${YELLOW}Package '$pkg' not found. Installing...${NC}"
        sudo pacman -S --noconfirm "$pkg"
    fi
done

# 2. Backing up existing configurations
echo -e "\n${GREEN}[2/4] Backing up old configurations...${NC}"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Array of your dotfiles folders
FOLDERS_TO_DEPLOY=("fastfetch" "fish" "hypr" "kitty" "rofi" "waybar")

for folder in "${FOLDERS_TO_DEPLOY[@]}"; do
    if [ -d "$CONFIG_DIR/$folder" ]; then
        echo -e "${YELLOW}Found existing $folder folder. Moving to backup...${NC}"
        mv "$CONFIG_DIR/$folder" "$BACKUP_DIR/"
    fi
done

# Remove backup directory if it remained empty
if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    rm -rf "$BACKUP_DIR"
else
    echo -e "${GREEN}Old configurations backed up to: $BACKUP_DIR${NC}"
fi

# 3. Deploying new files
echo -e "\n${GREEN}[3/4] Copying new configurations to $CONFIG_DIR...${NC}"
mkdir -p "$CONFIG_DIR"

for folder in "${FOLDERS_TO_DEPLOY[@]}"; do
    if [ -d "./config/$folder" ]; then
        echo -e "Deploying: $folder"
        cp -r "./config/$folder" "$CONFIG_DIR/"
    else
        echo -e "${RED}Critical Error: Folder ./config/$folder not found in the repository!${NC}"
    fi
done

# 4. Setting execution permissions for scripts
echo -e "\n${GREEN}[4/4] Setting permissions for internal scripts...${NC}"

# Automatically find and make executable all .sh and .pl scripts
if [ -d "$CONFIG_DIR/hypr" ]; then
    find "$CONFIG_DIR/hypr" -type f \( -name "*.sh" -o -name "*.pl" \) -exec chmod +x {} \; 2>/dev/null
fi

if [ -d "$CONFIG_DIR/rofi" ]; then
    find "$CONFIG_DIR/rofi" -type f \( -name "*.sh" -o -name "*.pl" \) -exec chmod +x {} \; 2>/dev/null
fi

echo -e "\n${GREEN}=== Installation successfully completed! ===${NC}"
echo -e "Please restart Hyprland to apply the changes."
