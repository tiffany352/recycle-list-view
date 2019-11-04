-- luacheck: ignore

stds.roblox = {
	globals = {
		"game",
	},
	read_globals = {
		-- Roblox globals
		"script",

		-- Extra functions
		"warn",
		"wait",
		"spawn",
		"delay",
		"tick",
		"UserSettings",
		"settings",
		"time",
		"typeof",
		"unpack",
		"getfenv",
		"setfenv",
		"shared",
		"workspace",
		"plugin",
		"setmetatable",

		-- Types
		"Axes",
		"BrickColor",
		"CFrame",
		"Color3",
		"ColorSequence",
		"ColorSequenceKeypoint",
		"Enum",
		"Faces",
		"Instance",
		"NumberRange",
		"NumberSequence",
		"NumberSequenceKeypoint",
		"PhysicalProperties",
		"Ray",
		"Random",
		"Rect",
		"Region3",
		"Region3int16",
		"TweenInfo",
		"UDim",
		"UDim2",
		"Vector2",
		"Vector3",
		"Vector3int16",
		"DockWidgetPluginGuiInfo",

		-- Libraries
		"utf8",

		math = {
			fields = {
				"clamp",
				"sign",
				"noise",
			}
		},

		debug = {
			fields = {
				"profilebegin",
				"profileend",
				"traceback",
			}
		}
	}
}

ignore = {
	"212", -- Unused argument.
}

std = "lua51+roblox"

-- Prevent max line lengths
max_code_line_length = false
max_string_line_length = false
max_comment_line_length = false
