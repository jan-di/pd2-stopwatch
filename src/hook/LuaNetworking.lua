local Mod = _G.StopwatchMod.Mod
local Settings = _G.StopwatchMod.Settings
local Records = _G.StopwatchMod.Records
local Util = _G.StopwatchMod.Util

Hooks:Add("NetworkReceivedData", "Stopwatch_NetworkReceivedData", function(sender, id, data)
    if string.len(id) == Mod.MESSAGE_ID_LENGTH and Util.startsWith(id, Mod.MESSAGE_ID_PREFIX) then
        if string.len(data) >= Mod.MAX_MESSAGE_LENGTH then
            Util.log("Received message is to long and will be ignored")
            return
        end

        if id == Mod.MESSAGE.SHARE_ATTEMPT and Settings:get("is_active") and not Network:is_server() then
            local attempt = Records.expandAttempt(json.decode(data))
            Records:check_attempt(attempt)
        end
    end
end)