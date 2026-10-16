local wezterm = require 'wezterm'
local act = wezterm.action

-- セッション保存/復元プラグイン
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")


local config = {
	use_ime = true,
	font = wezterm.font_with_fallback({
		"fira code",
		"Cica",
	}),
	font_size = 14.0,
	color_scheme = 'Catppuccin Mocha',
	--color_scheme = 'Afterglow',
	window_background_opacity = 0.9,
	hide_tab_bar_if_only_one_tab = true,
	audible_bell = "Disabled"
}

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
	-- Ctrl + Shift + r でペインを回転
	{
		key = 'r',
		mods = 'CTRL|SHIFT',
		action = act.RotatePanes 'Clockwise',
	},
	-- LEADER + s でセッション保存
	{
		key = 's',
		mods = 'LEADER',
		action = wezterm.action_callback(function(win, _)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
			-- toast は環境によって自動で消えないため、タブバーに一時表示する
			win:set_config_overrides({ hide_tab_bar_if_only_one_tab = false })
			win:set_right_status("Session saved ")
			wezterm.time.call_after(2, function()
				win:set_right_status("")
				win:set_config_overrides({})
			end)
		end),
	},
	-- LEADER + r でセッション復元 (あいまい検索)
	{
		key = 'r',
		mods = 'LEADER',
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, _)
				local kind = string.match(id, "^([^/]+)")
				id = string.match(id, "([^/]+)$")
				id = string.match(id, "(.+)%..+$")
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if kind == "workspace" then
					resurrect.workspace_state.restore_workspace(resurrect.state_manager.load_state(id, "workspace"), opts)
				elseif kind == "window" then
					resurrect.window_state.restore_window(pane:window(), resurrect.state_manager.load_state(id, "window"), opts)
				elseif kind == "tab" then
					resurrect.tab_state.restore_tab(pane:tab(), resurrect.state_manager.load_state(id, "tab"), opts)
				end
			end)
		end),
	},
}

-- 15分ごとに自動保存
resurrect.state_manager.periodic_save({
	interval_seconds = 15 * 60,
	save_workspaces = true,
	save_windows = true,
	save_tabs = true,
})

-- 起動時に直前のワークスペースを復元
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

-- 切り離し時に保存
wezterm.on("gui-detached", function(_)
	resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
	resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
end)


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


-- Performance settings
--config.front_end = "WebGpu"
--config.front_end = "OpenGL"
config.max_fps = 60


return config

