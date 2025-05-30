Hyprland Setup - Updates & Fixes 

Fix: 31/05/25 - 01:28 AWST 

## Script Enhancements

Script Validity & Execution

    Fixed shebang issue (#!/bin/bash\ ➝ #!/bin/bash)
    Removed RTF corruption caused by macOS TextEdit
    Converted line endings from CRLF to LF using dos2unix
    Verified as ASCII text executable with correct permissions


## Package Cleanup

    Removed ttf-courier-prime (not in Arch repos)
    Removed neofetch (deprecated from Arch repos)
    Added fallback logic for missing wallpaper downloads using imagemagick

## Feature Additions

    macOS-style screenshot keybind:

        SUPER + SHIFT + S: Region screenshot → clipboard only
        Implemented via: grim -g "$(slurp)" - | wl-copy

    Kitty mouse-based copy & paste:
        Left-click: select-to-copy
        Right-click: paste from clipboard
        Also mapped: Ctrl+Shift+C / Ctrl+Shift+V

## Config Fixes
Removed Deprecated Hyprland Options:

    decoration:drop_shadow
    shadow_range
    shadow_render_power
    col.shadow
    master:new_is_master

## Updated Layout Section:

    Removed master layout
    Retained dwindle layout only

## Fixed windowrulev2 Syntax:

OLD:
windowrulev2 = float, ^(pavucontrol)$

NEW:
windowrulev2 = float, class:^(pavucontrol)$
