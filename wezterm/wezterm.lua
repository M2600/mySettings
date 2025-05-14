local wezterm = require 'wezterm'


local config = {
	use_ime = true,
	font = wezterm.font("fira code"),
	font_size = 14.0,
	color_scheme = 'Catppuccin Mocha',
	--color_scheme = 'Afterglow',
	window_background_opacity = 0.9,
	hide_tab_bar_if_only_one_tab = true,
	audible_bell = "Disabled"
}


-- Set open link with Ctrl+Click
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = 'Left'} },
		mods = 'CTRL',
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Disable the 'Down' event 
	{
		event = { Down = { streak = 1, button = 'Left'} },
		mods = 'CTRL',
		action = wezterm.action.Nop,
	},
	-- Disable the 'Click' event
	{
		event = { Up = {streak = 1, button = 'Left'} },
		mods = 'NONE',
		action = wezterm.action.Nop,
	},
}


return config

