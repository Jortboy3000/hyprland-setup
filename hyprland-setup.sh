#!/bin/bash

# Enhanced Hyprland Setup Script for Arch Linux
# Last updated: 30/05/2025
# By Jortboy3000

set -e

# Colors for output

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root

if [[ $EUID -eq 0 ]]; then
   error "Don't run this script as root!"
fi

# Check if we're on Arch Linux

if ! command -v pacman &> /dev/null; then
    error "This script is designed for Arch Linux (pacman not found)"
fi

log "Starting Hyprland setup..."

# BACKUP EXISTING CONFIGS 
log "Backing up existing configurations..."
BACKUP_DIR="$HOME/.config/hyprland-setup-backup-$(date +%s)"
mkdir -p "$BACKUP_DIR"

for config_dir in hypr kitty waybar wofi; do
    if [[ -d "$HOME/.config/$config_dir" ]]; then
        cp -r "$HOME/.config/$config_dir" "$BACKUP_DIR/"
        log "Backed up ~/.config/$config_dir"
    fi
done

# SYSTEM UPDATE 
log "Updating system packages..."
sudo pacman -Syu --noconfirm || error "System update failed"

# INSTALL ESSENTIAL PACKAGES
log "Installing essential packages..."
PACKAGES=(
    # Core Hyprland components
    hyprland kitty waybar wofi swww wl-clipboard
    # Desktop portal support
    xdg-desktop-portal-hyprland xdg-desktop-portal
    # System utilities
    networkmanager brightnessctl playerctl
    # Fonts
    ttf-ibm-plex ttf-font-awesome
    # Additional utilities
    grim slurp dunst libnotify pavucontrol
    # File manager
    thunar
)

sudo pacman -S --noconfirm "${PACKAGES[@]}" || error "Package installation failed"

# ENABLE NETWORK MANAGER
log "Enabling NetworkManager..."
if ! systemctl is-enabled NetworkManager &> /dev/null; then
    sudo systemctl enable --now NetworkManager
    log "NetworkManager enabled and started"
else
    log "NetworkManager already enabled"
fi

# CREATE CONFIG DIRECTORIES
log "Creating configuration directories..."
mkdir -p ~/.config/{hypr,kitty,waybar,wofi,dunst} ~/Pictures/wallpapers

# DOWNLOAD DEFAULT WALLPAPER 
log "Setting up wallpaper..."
WALLPAPER_PATH="$HOME/Pictures/wallpapers/default.jpg"
if [[ ! -f "$WALLPAPER_PATH" ]]; then
    log "Downloading default wallpaper..."
    curl -s -o "$WALLPAPER_PATH" "https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=1920&h=1080&fit=crop" || {
        warn "Failed to download wallpaper, creating placeholder"
        # Create a simple gradient wallpaper using ImageMagick if available
        if command -v convert &> /dev/null; then
            convert -size 1920x1080 gradient:#1a1a2e-#16213e "$WALLPAPER_PATH"
        fi
    }
fi

# === HYPRLAND CONFIG ===
log "Creating Hyprland configuration..."
cat > ~/.config/hypr/hyprland.conf <<'EOF'
# Hyprland Configuration

# === MONITORS ===
monitor=,preferred,auto,1

# === AUTOSTART ===
exec-once = swww init
exec-once = swww img ~/Pictures/wallpapers/default.jpg --transition-type grow --transition-fps 60
exec-once = waybar
exec-once = dunst
exec-once = /usr/lib/xdg-desktop-portal-hyprland
exec-once = /usr/lib/xdg-desktop-portal

# === INPUT ===
input {
    kb_layout = us
    kb_variant = 
    kb_model =
    kb_options =
    kb_rules =
    
    follow_mouse = 1
    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = true
    }
    sensitivity = 0
}

# === GENERAL ===
general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
    col.active_border = rgba(5ec9f3ee) rgba(31a6ffcc) 45deg
    col.inactive_border = rgba(444444aa)
    layout = dwindle
    allow_tearing = false
}

# === DECORATION ===
decoration {
    rounding = 10
    
    blur {
        enabled = true
        size = 10
        passes = 3
        new_optimizations = true
    }
    

# === ANIMATIONS ===
animations {
    enabled = true
    bezier = ease, 0.25, 0.1, 0.25, 1
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1
    
    animation = windows, 1, 7, ease, slide
    animation = windowsOut, 1, 7, smoothOut, slide
    animation = windowsMove, 1, 7, ease, slide
    animation = fade, 1, 7, ease
    animation = border, 1, 10, ease
    animation = borderangle, 1, 8, ease
    animation = workspaces, 1, 7, ease
}

# === LAYOUTS ===
dwindle {
    pseudotile = true
    preserve_split = true
}


# === MISC ===
misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
    disable_splash_rendering = true
}

# === WINDOW RULES ===
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = float,class:^(blueman-manager)$
windowrulev2 = float,class:^(nm-connection-editor)$
windowrulev2 = float,class:^(file-roller)$
windowrulev2 = float,class:^(kitty)$,title:^(float_kitty)$

# === KEYBINDINGS ===
$mainMod = SUPER

# Applications
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, B, exec, firefox
bind = $mainMod, E, exec, thunar
bind = $mainMod, D, exec, wofi --show drun

# Window management
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, V, togglefloating
bind = $mainMod, P, pseudo
bind = $mainMod, J, togglesplit
bind = $mainMod, F, fullscreen

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move windows
bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d

# Resize windows
bind = $mainMod CTRL, left, resizeactive, -20 0
bind = $mainMod CTRL, right, resizeactive, 20 0
bind = $mainMod CTRL, up, resizeactive, 0 -20
bind = $mainMod CTRL, down, resizeactive, 0 20

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through workspaces
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mouse
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Media keys
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ +5%
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ -5%
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioPause, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Screenshots
bind = $mainMod, PRINT, exec, grim -g "$(slurp)" - | wl-copy
bind = , PRINT, exec, grim - | wl-copy
bind = $mainMod SHIFT, PRINT, exec, grim -g "$(slurp)" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png

# Special keys
bind = $mainMod, L, exec, swaylock
bind = $mainMod SHIFT, RETURN, exec, kitty --title float_kitty
EOF

# === KITTY CONFIG ===
log "Creating Kitty configuration..."
cat > ~/.config/kitty/kitty.conf <<'EOF'
# Kitty Configuration

# Font
font_family      IBM Plex Mono
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        13.0

# Window
background_opacity 0.85
confirm_os_window_close 0
window_padding_width 10

# Colors (Catppuccin Mocha)
foreground              #CDD6F4
background              #1E1E2E
selection_foreground    #1E1E2E
selection_background    #F5E0DC

# Cursor
cursor                  #F5E0DC
cursor_text_color       #1E1E2E

# URL underline color when hovering
url_color               #F5E0DC

# Kitty window border colors
active_border_color     #B4BEFE
inactive_border_color   #6C7086
bell_border_color       #F9E2AF

# OS Window titlebar colors
wayland_titlebar_color system
macos_titlebar_color system

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline
tab_powerline_style slanted
tab_title_template {title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}

# Mouse-based copy/paste
mouse_map left press ungrabbed select_to_copy
mouse_map right press ungrabbed paste_from_clipboard

# Also enable keyboard shortcuts for consistency
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard

# Key mappings
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+q close_window
map ctrl+shift+enter new_window
map ctrl+shift+t new_tab
map ctrl+shift+w close_tab
map ctrl+shift+right next_tab
map ctrl+shift+left previous_tab
map ctrl+shift+equal change_font_size all +2.0
map ctrl+shift+minus change_font_size all -2.0
map ctrl+shift+backspace change_font_size all 0
EOF

# === WAYBAR CONFIG ===
log "Creating Waybar configuration..."
cat > ~/.config/waybar/config <<'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 40,
    "spacing": 4,
    "margin-top": 6,
    "margin-left": 12,
    "margin-right": 12,
    
    "modules-left": ["hyprland/workspaces", "hyprland/mode"],
    "modules-center": ["clock"],
    "modules-right": ["idle_inhibitor", "pulseaudio", "network", "cpu", "memory", "temperature", "battery", "tray"],

    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "hyprland/mode": {
        "format": "<span style=\"italic\">{}</span>"
    },
    
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "format": "{:%H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""]
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    }
}
EOF

# === WAYBAR STYLING ===
log "Creating Waybar styling..."
cat > ~/.config/waybar/style.css <<'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "IBM Plex Mono", "Font Awesome 6 Free";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(26, 26, 46, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 0;
}

button:hover {
    background: inherit;
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button {
    padding: 0 8px;
    background-color: transparent;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#mpd {
    padding: 0 10px;
    color: #ffffff;
}

#window,
#workspaces {
    margin: 0 4px;
}

.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: #1f2937;
    border-radius: 8px;
    margin: 4px;
    padding: 0 12px;
}

#battery {
    background-color: #ffffff;
    color: #000000;
    border-radius: 8px;
    margin: 4px 2px;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: #26A65B;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#cpu {
    background-color: #2ecc71;
    color: #000000;
    border-radius: 8px;
    margin: 4px 2px;
}

#memory {
    background-color: #9b59b6;
    border-radius: 8px;
    margin: 4px 2px;
}

#disk {
    background-color: #964B00;
    border-radius: 8px;
    margin: 4px 2px;
}

#backlight {
    background-color: #90b1b1;
    border-radius: 8px;
    margin: 4px 2px;
}

#network {
    background-color: #2980b9;
    border-radius: 8px;
    margin: 4px 2px;
}

#network.disconnected {
    background-color: #f53c3c;
}

#pulseaudio {
    background-color: #f1c40f;
    color: #000000;
    border-radius: 8px;
    margin: 4px 2px;
}

#pulseaudio.muted {
    background-color: #90b1b1;
    color: #2a5c45;
}

#temperature {
    background-color: #f0932b;
    border-radius: 8px;
    margin: 4px 2px;
}

#temperature.critical {
    background-color: #eb4d4b;
}

#tray {
    background-color: #2980b9;
    border-radius: 8px;
    margin: 4px 2px;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #eb4d4b;
}

#idle_inhibitor {
    background-color: #2d3748;
    border-radius: 8px;
    margin: 4px 2px;
}

#idle_inhibitor.activated {
    background-color: #ecf0f1;
    color: #2d3748;
}
EOF

# === WOFI CONFIG ===
log "Creating Wofi configuration..."
cat > ~/.config/wofi/config <<'EOF'
width=600
height=400
location=center
show=drun
prompt=Search...
filter_rate=100
allow_markup=true
no_actions=true
halt_on_select=true
orientation=vertical
content_halign=fill
insensitive=true
allow_images=true
image_size=32
gtk_dark=true
EOF

cat > ~/.config/wofi/style.css <<'EOF'
window {
    margin: 0px;
    border: 2px solid #5ec9f3;
    background-color: rgba(26, 26, 46, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    font-family: "IBM Plex Mono";
}

#input {
    padding: 12px;
    margin: 12px;
    border: none;
    color: #ffffff;
    font-weight: bold;
    background-color: rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    outline: none;
}

#inner-box {
    margin: 12px;
    padding: 0px;
    border: none;
    background-color: transparent;
    border-radius: 0px;
}

#outer-box {
    margin: 0px;
    padding: 0px;
    border: none;
    background-color: transparent;
    border-radius: 0px;
}

#scroll {
    margin: 0px;
    border: none;
    border-radius: 0px;
}

#text {
    margin: 8px;
    border: none;
    color: #ffffff;
}

#entry {
    padding: 8px;
    margin: 4px;
    border: none;
    background-color: transparent;
    border-radius: 8px;
}

#entry:selected {
    background-color: rgba(94, 201, 243, 0.3);
    border-radius: 8px;
}

#text:selected {
    color: #ffffff;
}
EOF

# === DUNST CONFIG ===
log "Creating Dunst configuration..."
cat > ~/.config/dunst/dunstrc <<'EOF'
[global]
    monitor = 0
    follow = none
    geometry = "300x60-20+48"
    indicate_hidden = yes
    shrink = no
    transparency = 10
    notification_height = 0
    separator_height = 2
    padding = 12
    horizontal_padding = 12
    frame_width = 2
    frame_color = "#5ec9f3"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    font = IBM Plex Mono 11
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    min_icon_size = 0
    max_icon_size = 32
    sticky_history = yes
    history_length = 20
    always_run_script = true
    startup_notification = false
    verbosity = mesg
    corner_radius = 8
    ignore_dbusclose = false
    force_xinerama = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period

[urgency_low]
    background = "#1a1a2e"
    foreground = "#ffffff"
    timeout = 10

[urgency_normal]
    background = "#1a1a2e"
    foreground = "#ffffff"
    timeout = 10

[urgency_critical]
    background = "#eb4d4b"
    foreground = "#ffffff"
    frame_color = "#eb4d4b"
    timeout = 0
EOF

# === SET HYPRLAND AUTOSTART ===
log "Setting up Hyprland autostart..."
if ! grep -q "exec Hyprland" ~/.bash_profile 2>/dev/null; then
    echo -e '\n# Auto-start Hyprland on TTY1' >> ~/.bash_profile
    echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then' >> ~/.bash_profile
    echo '    exec Hyprland' >> ~/.bash_profile
    echo 'fi' >> ~/.bash_profile
    log "Added Hyprland autostart to ~/.bash_profile"
else
    log "Hyprland autostart already configured"
fi

# === FINAL SETUP ===
log "Performing final setup..."

# Enable dunst service
systemctl --user enable --now dunst || warn "Could not enable dunst service"

# Create desktop entries directory if it doesn't exist
mkdir -p ~/.local/share/applications

# === SUCCESS MESSAGE ===
echo
echo -e "${GREEN}✅ Hyprland setup completed successfully!${NC}"
echo
echo -e "${BLUE}📁 Backup created at:${NC} $BACKUP_DIR"
echo -e "${BLUE}🖼️  Default wallpaper:${NC} $WALLPAPER_PATH"
echo
echo -e "${YELLOW}🎯 Key bindings:${NC}"
echo "  Super + Enter       → Terminal"
echo "  Super + D           → Application launcher"
echo "  Super + Q           → Close window"
echo "  Super + M           → Exit Hyprland"
echo "  Super + 1-0         → Switch workspace"
echo "  Super + Shift + 1-0 → Move window to workspace"
echo "  Super + Print       → Screenshot selection"
echo "  Print               → Screenshot full screen"
echo
echo -e "${GREEN}🚀 Reboot now to enter your new Hyprland environment!${NC}"
echo -e "${BLUE}💡 Tip:${NC} You can customize your wallpaper by placing images in ~/Pictures/wallpapers/"
EOF
