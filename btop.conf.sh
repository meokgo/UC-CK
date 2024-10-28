#!/bin/sh
#This script creates btop config file for use in split screen tmux session
  cp ~/.config/btop/btop.conf ~/.config/btop/btop.conf.bak
  sed -i 's|color_theme = "Default"|color_theme = "TTY"|g' ~/.config/btop/btop.conf
  sed -i 's|theme_background = True|theme_background = False|g' ~/.config/btop/btop.conf
  sed -i 's|shown_boxes = "cpu mem net proc"|shown_boxes = "net mem"|g' ~/.config/btop/btop.conf
  sed -i 's|rounded_corners = True|rounded_corners = False|g' ~/.config/btop/btop.conf
  sed -i 's|graph_symbol_mem = "default"|graph_symbol_mem = "block"|g' ~/.config/btop/btop.conf
  sed -i 's|graph_symbol_net = "default"|graph_symbol_net = "braille"|g' ~/.config/btop/btop.conf
  sed -i 's|disks_filter = ""|disks_filter = "/ /srv"|g' ~/.config/btop/btop.conf
  sed -i 's|only_physical = True|only_physical = False|g' ~/.config/btop/btop.conf
  sed -i 's|use_fstab = True|use_fstab = False|g' ~/.config/btop/btop.conf
  sed -i 's|show_battery = True|show_battery = False|g' ~/.config/btop/btop.conf
  sed -i 's|net_iface = ""|net_iface = "eth0"|g' ~/.config/btop/btop.conf
