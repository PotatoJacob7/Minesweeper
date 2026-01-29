# Godot Window Aspect Ratio Enforcer

[🇺🇸 English](README.md) | [🇨🇳 简体中文](README.zh.md)

A lightweight GDScript tool that allows your Godot project window to maintain a consistent aspect ratio during resizing — with support for edge-based and corner-based behaviors, as well as clamped ratio ranges. Works on all major desktop platforms.

## ✨ Features

- 🖼️ **Aspect Ratio Locking**: Automatically maintains the desired aspect ratio while resizing.
- 🖱️ **Intelligent Resize Detection**: Detects whether the user is dragging a window edge or corner and adapts scaling behavior accordingly.
- 🕒 **Debounced Resize Handling**: Prevents lag/stuttering during window resizing using a timer-based debounce.
- ⚙️ **Customizable Ratio Range**: Define min and max allowed aspect ratios.
- ✅ **Plug-and-Play**: Minimal setup; just autoload the script.

## 📦 Installation

1. Download `WindowAspectRatio.gd` into your project directory (e.g. `addons/`).
2. Go to **Project → Project Settings → Autoload**.
3. Add the script as an Autoload singleton
4. Done! It will now run automatically when the project starts.

## 🧠 How It Works

The script connects to the window's `size_changed` signal and waits for the user to stop resizing (using a `Timer`). It then analyzes the resize direction:

- If **width changed more** → scale height to match aspect ratio (horizontal resize).
- If **height changed more** → scale width to match aspect ratio (vertical resize).
- If both changed → perform proportional scaling from the corner.

The adjusted size is clamped between a min and max aspect ratio defined in `ratio_range`.

## 🛠️ Usage & Configuration

You can customize the following exported variable in the script:

```gdscript
@export var ratio_range: Vector2 = Vector2(1.0, 16.0 / 9.0)
````

This defines the minimum and maximum aspect ratios:

* `1.0` means 1:1 (square)
* `16.0 / 9.0` means widescreen

To enforce a fixed aspect ratio (e.g. always 16:9), set both values the same:

```gdscript
@export var ratio_range: Vector2 = Vector2(16.0 / 9.0, 16.0 / 9.0)
```

### Example Code Snippet (Main Logic)

```gdscript
var current_size = get_window().size
var delta = current_size - previous_size

if abs(delta.x) > abs(delta.y) * 1.5:
    # Horizontal edge dragged
    new_size = constrain_width(current_size)
elif abs(delta.y) > abs(delta.x) * 1.5:
    # Vertical edge dragged
    new_size = constrain_height(current_size)
else:
    # Corner drag, proportional resize
    new_size = enforce_aspect_ratio(current_size)
```

## 💡 Tips

* This only affects desktop platforms (`OS.has_feature("desktop")`)
* Works best in `Windowed` or `Borderless` mode (not fullscreen)
* You can modify the debounce time by changing `resize_timer.wait_time`

## 📄 License

MIT License

---

Made with ❤️ using Godot Engine.
