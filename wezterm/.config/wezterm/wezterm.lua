-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
-- config.font = wezterm.font("MesloLGS Nerd Font") -- Defaults are fine
config.font_size = 9
config.color_scheme = "Catppuccin Mocha"

-- Window configuration.
-- config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- config.macos_window_background_blur = 10

-- Window padding configuration.
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Finally, return the configuration to wezterm:
return config
