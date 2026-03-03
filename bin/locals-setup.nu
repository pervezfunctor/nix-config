#! /usr/bin/env nu

print "Setting up local configuration files..."

print "Setting up niri files..."
mkdir ~/.config/niri/dms
touch ~/.config/niri/dms/{colors,cursor,layout,alttab,binds}.kdl
touch ~/.config/niri/local.kdl

print "Setting up mango files..."
mkdir ~/.config/mango/dms
touch ~/.config/mango/dms/{colors,cursor,layout,outputs}.conf
touch ~/.config/mango/local.conf

print "Setting up kitty files..."
mkdir ~/.config/kitty
touch ~/.config/kitty/local.conf

print "setting up zsh files..."
touch ~/.zshrc
