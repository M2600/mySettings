local wezterm = require 'wezterm'


local config = {
	use_ime = true,
	font = wezterm.font("fira code"),
	font_size = 14.0,
	color_scheme = 'Catppuccin Mocha',
	hide_tab_bar_if_only_one_tab = true,
	audible_bell = "Disabled"
}


return config

