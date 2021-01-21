-- There's a lot of Lua in ./BGAnimations/ScreenGameplay overlay
--    and a LOT of Lua in ./BGAnimations/ScreenGameplay underlay
--
-- I'm using files in overlay for logic that *does* stuff without
-- directly drawing any new actors to the screen.
--
-- I've tried to title each file helpfully and partition the logic
-- found in each accordingly. Inline comments in each should provide
-- insight into the objective of each file.
--
-- Def.Actor will be used for each underlay file because I still
-- need some way to listen for events broadcast by the engine.
--
-- I'm using files in Gameplay's underlay for actors that get drawn
-- to the screen and visible to the player.  You can poke around in
-- those files to learn more.
------------------------------------------------------------

local af = Def.ActorFrame{}

af[#af+1] = LoadActor("./WhoIsCurrentlyWinning.lua")

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do

	local pn = ToEnumShortString(player)
	
	-- Use this opportunity to create an empty table for this player's
	-- gameplay stats for this stage. We'll store all kinds of data in
	-- this table that would normally only exist in ScreenGameplay so
	-- that it can persist into ScreenEvaluation to eventually be processed,
	-- visualized, and complained about. For example, per-column judgments,
	-- judgment offset data, highscore data, and so on.
	--
	-- Sadly, the full details of this Stages.Stats[stage_index] data structure
	-- is not documented anywhere. :(
	SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame+1] = {}

	af[#af+1] = LoadActor("./TrackTimeSpentInGameplay.lua", player)
	af[#af+1] = LoadActor("./JudgmentOffsetTracking.lua", player)

	-- FIXME: refactor PerColumnJudgmentTracking to not be inside this loop
	--        the Lua input callback logic shouldn't be duplicated for each player
	af[#af+1] = LoadActor("./PerColumnJudgmentTracking.lua", player)

	-- Discord thingies
	local largeImageTooltip = GetPlayerOrMachineProfile(PLAYER_1):GetDisplayName() .. ": " .. string.format("%5.2f", (STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetScore()*10000)/100)
	local detail = "Playing: "..GAMESTATE:GetCurrentSong():GetDisplayMainTitle() .. " [" .. GAMESTATE:GetCurrentSong():GetGroupName() .. "]"
	-- truncated to 128 characters(discord hard limit)
	detail = #detail < 128 and detail or string.sub(detail, 1, 124) .. "..."
	local state = GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty() .. 
		" - " .. string.format("%05.2f%%",math.floor(STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetScore()*10000)/100) .. 
		" " .. THEME:GetString("Grade",ToEnumShortString(STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetGrade()))
	GAMESTATE:UpdateDiscordPresence(largeImageTooltip, detail, state, 0)
end

return af