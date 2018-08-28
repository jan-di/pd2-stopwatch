local Class = _G.StopwatchMod.Settings
local Mod = _G.StopwatchMod.Mod

Class.SETTINGS_FILE = SavePath .. "StopwatchSettings.json"

Class.data = {}

function Class:get(key)
    if self.data[key] then
        return self.data[key]
    end
    return nil
end

function Class:set(key, value)
    self.data[key] = value
end

function Class:load()
    local file = io.open(self.SETTINGS_FILE, "r")
    if file then
        self.data = json.decode(file:read("*all"))
        file:close()
    end
    local default_settings = self:get_default_settings()
    for setting, value in pairs(default_settings) do
        if not self.data[setting] then
            self.data[setting] = default_settings[setting]
        end
    end
end

function Class:store()
    local file = io.open(self.SETTINGS_FILE, "w+")
    if file then
        file:write(json.encode(self.data))
        file:close()
    end
end

function Class:get_default_settings()
    return {
        is_active = true,
        disable_chat = false,
        init_record_color = Mod.COLOR_YELLOW,
        new_record_color = Mod.COLOR_GREEN,
        old_record_color = Mod.COLOR_ORANGE,
        equal_record_color = Mod.COLOR_PINK
    }
end