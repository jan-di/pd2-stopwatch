local Mod = _G.StopwatchMod.Mod
local Settings = _G.StopwatchMod.Settings
local Records = _G.StopwatchMod.Records

Hooks:Add("NetworkReceivedData", "Stopwatch_NetworkReceivedData", function(sender, id, data)
	if id == Mod.MESSAGE.attempt_broadcast and Settings:get("is_active") and not Network:is_server() then
	    local attempt = json.decode(data)
        Records:check_attempt(attempt)
    end
end)