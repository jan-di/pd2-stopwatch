local Records = _G.StopwatchMod.Records
local Util = _G.StopwatchMod.Util

Hooks:PostHook(GameStateMachine, "change_state", "Stopwatch_GameStateMachine_Post_change_state", function(ply, state)
    if state._name == "victoryscreen" and Network:is_server() then
        Records:complete_level()
	elseif state._name == "gameoverscreen" or state._name == "menu_main" or state._name == "ingame_lobby_menu" then
        Records:clear_pending()
    end
end)