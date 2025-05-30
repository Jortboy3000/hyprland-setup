# Ultimate Hyprland Rice Setup

**Transform your boring Arch Linux into a floating terminal paradise**

This script takes your fresh Arch install and turns it into a sick Hyprland rice that'll make your friends jealous. We're talking smooth animations, transparent terminals, and a setup so clean it belongs in r/unixporn.

## ✨ What You Get

- **Hyprland** - The wayland compositor that doesn't suck
- **Kitty** - Terminal so fast it makes other terminals cry
- **Waybar** - Status bar that actually looks good
- **Wofi** - App launcher with style
- **Swww** - Wallpaper engine for the sophisticated
- **Perfect keybinds** - Actually usable, not some vim wizard nonsense

## 🎯 Features

### Visual Candy
- Smooth 60fps animations
- Blur effects that hit different
- Rounded corners everywhere (because we're not animals)
- Glassmorphism vibes
- Color scheme that doesn't burn your retinas

### Actually Functional
- Smart workspace management
- Screenshot tools that work
- Audio controls that make sense
- Brightness keys (shocking, I know)
- Auto-wallpaper setup

### Quality of Life
- Backups your old configs (just in case)
- Error handling (won't brick your system)
- Colored output (because plain text is for peasants)
- Helpful keybind cheatsheet

## 🚦 Installation

**One command. That's it.**

```bash
curl -L -o hyprland-setup.sh "https://raw.githubusercontent.com/Jortboy3000/hyprland-setup/main/hyprland-setup.sh" && chmod +x hyprland-setup.sh && ./hyprland-setup.sh
```

Then reboot and watch the magic happen.

## ⌨️ Essential Keybinds

| Keys | Action | 
|------|--------|
| `Super + Enter` | Open terminal |
| `Super + D` | App launcher |
| `Super + Q` | Close window |
| `Super + 1-5` | Switch workspace |
| `Super + Shift + 1-5` | Move window to workspace |
| `Super + Arrow Keys` | Move focus |
| `Super + Print` | Screenshot area |
| `Print` | Screenshot everything |

## 🎨 Customization

Want to make it yours? 

- **Wallpapers**: Drop them in `~/Pictures/wallpapers/`
- **Colors**: Edit `~/.config/hypr/hyprland.conf`
- **Bar**: Tweak `~/.config/waybar/style.css`
- **Terminal**: Mess with `~/.config/kitty/kitty.conf`

## 🔧 Requirements

- Arch Linux (obviously)
- Internet connection
- About 5 minutes
- Willingness to flex on Ubuntu users

## 🆘 Troubleshooting

**Script won't run?**
```bash
chmod +x hyprland-setup.sh
```

**Looks broken after reboot?**
- Check if you're on TTY1 (Hyprland auto-starts there)
- Try `Super + Enter` to open terminal

**Want your old setup back?**
- Your configs are backed up in `~/.config/hyprland-setup-backup-*`

## 🤝 Contributing

Found a bug? Want to add something cool? PRs welcome. Just don't make it worse.

## 📸 Screenshots

*Coming soon - once you run this and take some fire screenshots*

## ⚡ Credits

Built for people who want their desktop to look incredible without spending 3 weeks reading Arch Wiki pages.

**Now stop reading and go install it.**

---

*P.S. - Yes, it works on a potato. No, you don't need 32GB of RAM.*
