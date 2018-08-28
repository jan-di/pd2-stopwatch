local Class = _G.StopwatchMod.Records
local Util = _G.StopwatchMod.Util
local Mod = _G.StopwatchMod.Mod
local Settings = _G.StopwatchMod.Settings
local LuaNetwork = _G.LuaNetworking

Class.RECORDS_FILE = SavePath .. "StopwatchRecords.json"

Class.records = {}
Class.pending_records = {}

function Class:complete_objective(objective)
    local attempt = self:create_attempt(objective)
    self:share_attempt(attempt)
    self:check_attempt(attempt)
end

function Class:complete_level()
    local attempt = self:create_attempt()
    self:share_attempt(attempt)
    self:check_attempt(attempt)
end

function Class:create_attempt(objective)
    local mod_info = ""
    local objective_id = ""
    if _G.SilentAssassin and _G.SilentAssassin.settings["enabled"] then mod_info = mod_info .. "SilentAssassin;" end
    if objective and objective.id then
        objective_id = objective.id
    end

    local attempt = {
        level_id = managers.job:current_level_id(),
        objective_id = objective_id,
        parameter = {
            gamemode = Global.game_settings.gamemode,
            difficulty = managers.job:current_difficulty_stars(),
            one_down = Global.game_settings.one_down,
            team_ai = Global.game_settings.team_ai_option,
            peer_count = LuaNetwork:GetNumberOfPeers(),
            mod_info = mod_info
        },
        info = {
            needed_time = math.floor(managers.game_play_central:get_heist_timer()),
            by_username = managers.network.account:username_id(),
        }
    }

    return attempt
end

function Class:share_attempt(attempt)
    LuaNetwork:SendToPeers(Mod.MESSAGE.attempt_broadcast, json.encode(attempt))
end

function Class:check_attempt(attempt)
    local objective_text, record, prefix, message, color

    if attempt.objective_id ~= "" then
        if managers.objectives and managers.objectives._objectives[attempt.objective_id] and managers.objectives._objectives[attempt.objective_id].text then
            objective_text = Util.shorten(managers.objectives._objectives[attempt.objective_id].text, 42)
        else 
            objective_text = "unknown objective" 
        end
    else
        objective_text = Util.localize("stopwatch_chat_level_done")
    end

    record = self:get_record(attempt)
    alltime_record = self:get_alltime_record(attempt)
    if record then
        if record.info.needed_time < attempt.info.needed_time then
            prefix = "+"
			color = Mod.COLORS[Settings:get("old_record_color")]
        elseif record.info.needed_time > attempt.info.needed_time then
            prefix = "-"
            color = Mod.COLORS[Settings:get("new_record_color")]
            self:add_pending_record(attempt)
        else 
            prefix = "="
			color = Mod.COLORS[Settings:get("equal_record_color")]
        end
		prefix = prefix .. Util.format_time(math.abs(record.info.needed_time - attempt.info.needed_time))
		message = "R=" .. Util.format_time(record.info.needed_time)
    else 
        prefix = "_"
        color = Mod.COLORS[Settings:get("init_record_color")]
		message = "R=" .. Util.format_time(attempt.info.needed_time)
        self:add_pending_record(attempt)
    end
    if alltime_record then
        message = message .. " AT=" .. Util.format_time(alltime_record.info.needed_time)
    end
    message = message .. " " .. objective_text

    if not Settings:get("disable_chat") then
        Util.local_chat_message("[" .. prefix .. "]", message, color)
    end

    if attempt.objective_id == "" then
        self:save_pending()
    end
end

function Class:get_record(attempt)
    local equal_parameters

    if self.records[attempt.level_id] then
        if self.records[attempt.level_id][attempt.objective_id] then
            for i, record in ipairs(self.records[attempt.level_id][attempt.objective_id]) do
                equal_parameters = true
                for key, value in pairs(attempt.parameter) do
                    if record.parameter[key] ~= attempt.parameter[key] then
                        equal_parameters = false
                    end
                end
                if equal_parameters then
                    return record, i
                end
            end
        end
    end
    return nil, nil
end

function Class:get_alltime_record(attempt)
    local best_record = nil

    if self.records[attempt.level_id] then
        if self.records[attempt.level_id][attempt.objective_id] then
            for i, record in ipairs(self.records[attempt.level_id][attempt.objective_id]) do
                if not best_record or record.info.needed_time < best_record.info.needed_time then
                    best_record = record
                end
            end
        end
    end

    return best_record
end

function Class:add_record(attempt)
    local parameter = {}
    local info = {}

    for key, value in pairs(attempt.parameter) do
        parameter[key] = value
    end
    for key, value in pairs(attempt.info) do
        info[key] = value
    end

    if not self.records[attempt.level_id] then
        self.records[attempt.level_id] = {}
    end
    if not self.records[attempt.level_id][attempt.objective_id] then
        self.records[attempt.level_id][attempt.objective_id] = {}
    end

    table.insert(self.records[attempt.level_id][attempt.objective_id], {
        parameter = parameter,
        info = info
    })
end

function Class:remove_record(attempt, index)
    table.remove(self.records[attempt.level_id][attempt.objective_id], index)
end

function Class:add_pending_record(attempt)
    table.insert(self.pending_records, attempt)
end

function Class:save_pending()
    local pending_records_count = table.getn(self.pending_records), record, index

    if pending_records_count > 0 then
        Util.log("Saving pending records (record count: " .. pending_records_count .. ")")

        for i, attempt in ipairs(self.pending_records) do
            record, index = self:get_record(attempt)
            if record then
                self:remove_record(attempt, index)
            end
            self:add_record(attempt)
        end
    else
        Util.log("Saving pending records (nothing to save)")
    end

    self:clear_pending()
    self:store()
end

function Class:clear_pending()
    Util.log("Clearing pending records ")
    self.pending_records = {}
end

function Class:reset()
    Util.log("Resetting all records")
    self.records = {}
end

function Class:load()
    Util.log("Loading records from '" .. self.RECORDS_FILE .. "'")
	local file = io.open(self.RECORDS_FILE, "r")
	if file then
		self.records = json.decode(file:read("*all"))
		file:close()
    end	
    if _G.StopwatchMod.Debug then
        local record_count, objective_count, level_count = 0, 0, 0
        for level_id, level_data in pairs(self.records) do
            level_count = level_count + 1
            for objective_id, objective_data in pairs(level_data) do
                objective_count = objective_count + 1
                record_count = record_count + #objective_data
            end
        end
        Util.log("Loaded " .. record_count .. " records (" .. objective_count .. " objectives; " .. level_count .. " levels)")
    end
end

function Class:store()
    Util.log("Storing records to '" .. self.RECORDS_FILE .. "'")
	local file = io.open(self.RECORDS_FILE, "w+")
	if file then
		file:write(json.encode(self.records))
		file:close()
	end
end