local Class = _G.StopwatchMod.Mod

Class.MOD_PATH = ModPath
Class.LOCALIZATION_PATH = ModPath .. "/lang"
Class.MENU_PATH = ModPath .. "/menu"

Class.COLOR_YELLOW = 1
Class.COLOR_GREEN = 2
Class.COLOR_ORANGE = 3
Class.COLOR_PINK = 4
Class.COLOR_RED = 5
Class.COLOR_BLUE = 6
Class.COLOR_CYAN = 7
Class.COLOR_WHITE = 8

Class.COLORS = {
    [Class.COLOR_YELLOW] = Color(1, 1, 1, 0.4),
    [Class.COLOR_GREEN] = Color(1, 0, 0.8, 0),
    [Class.COLOR_ORANGE] = Color(1, 1, 0.5, 0),
    [Class.COLOR_PINK] = Color(1, 1, 0, 0.4),
    [Class.COLOR_RED] = Color(1, 0.8, 0, 0),
    [Class.COLOR_BLUE] = Color(1, 0, 0.6, 1),
    [Class.COLOR_CYAN] = Color(1, 0, 1, 1),
    [Class.COLOR_WHITE] = Color(1, 1, 1, 1)
}

Class.MESSAGE = {
    attempt_broadcast = "8ec22389-f6a9-466e-b4fd-ae2455876150"
}