local Class = _G.StopwatchMod.Util
local Settings = _G.StopwatchMod.Settings

function Class.log(text, ignore_debug)
    ignore_debug = ignore_debug or false

    if ignore_debug or _G.StopwatchMod.Debug then
        log("[STOPWATCH] " .. text)
    end
end

function Class.format_time(seconds)
    if seconds < 3600 then
        return string.format("%.2d:%.2d", seconds/60%60, seconds%60)
    else
        return string.format("%.2d:%.2d:%.2d", seconds/(60*60), seconds/60%60, seconds%60)
    end
end

function Class.localize(localize_text)
	return managers.localization:text(localize_text)
end

function Class.local_chat_message(prefix, message, color)
    if managers.chat then
        managers.chat:_receive_message(ChatManager.GAME, prefix, message, color) 
    end
end

function Class.shorten(string, max_length)
    if string.len(string) > max_length then 
        return string.sub(string, 1, max_length - 2) .. ".." 
    end
    return string
end