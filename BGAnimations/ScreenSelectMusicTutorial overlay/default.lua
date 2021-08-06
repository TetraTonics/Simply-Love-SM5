---------------------------------------------------------------------------
-- do as much setup work as possible in another file to keep default.lua
-- from becoming overly cluttered

local setup = LoadActor("./Setup.lua")

if setup == nil then
	return LoadActor(THEME:GetPathB("ScreenSelectMusicTutorial", "overlay/NoValidSongs.lua"))
end

local steps_type = setup.steps_type
local Groups = setup.Groups
local group_index = setup.group_index
local group_info = setup.group_info

local OptionRows = setup.OptionRows
local OptionsWheel = setup.OptionsWheel
local GroupWheel = setmetatable({}, sick_wheel_mt)
local SongWheel = setmetatable({}, sick_wheel_mt)

local row = setup.row
local col = setup.col

local TransitionTime = 0.5
local songwheel_y_offset = -13

-- metatables
--local group_mt = LoadActor("./GroupMT.lua", {GroupWheel,SongWheel,TransitionTime,steps_type,row,col,Input,setup.PruneSongsFromGroup})
local song_mt = LoadActor("./SongMT.lua", {SongWheel,TransitionTime,row,col})
local optionrow_mt = LoadActor("./OptionRowMT.lua")
local optionrow_item_mt = LoadActor("./OptionRowItemMT.lua")

---------------------------------------------------------------------------

local t = Def.ActorFrame {
	InitCommand=function(self)
		--GroupWheel:set_info_set(Groups, group_index)
		--self:GetChild("GroupWheel"):SetDrawByZPosition(true)

		self:queuecommand("Capture")
	end,
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then self:queuecommand("Listen") end
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()

		-- if necessary, force the players into Gameplay because the MenuTimer has run out
		if not Input.AllPlayersAreAtLastRow() and seconds <= 0 then

			-- if we we're not currently in the optionrows,
			-- we'll need to initialize them for the current song, first
			if Input.WheelWithFocus ~= OptionsWheel then
				setup.InitOptionRowsForSingleSong()
			end

			for player in ivalues(GAMESTATE:GetHumanPlayers()) do

				for index=1, #OptionRows-1 do
					local choice = OptionsWheel[player][index]:get_info_at_focus_pos()
					local choices= OptionRows[index]:Choices()
					local values = OptionRows[index].Values()

					OptionRows[index]:OnSave(player, choice, choices, values)
				end
			end
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		else
			self:sleep(0.5):queuecommand("Listen")
		end
	end,
	CodeMessageCommand=function(self, params)
		-- I'm using Metrics-based code detection because the engine is already good at handling
		-- simultaneous button presses (CancelSingleSong when ThreeKeyNavigation=1),
		-- as well as long input patterns (Exit from EventMode) and I see no need to
		-- reinvent that functionality for the Lua InputCallback that I'm using otherwise.

		if params.Name == "Exit" then
			if PREFSMAN:GetPreference("EventMode") then
				SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen")
			else
				if SL.Global.Stages.PlayedThisGame == 0 then
					SL.Global.GameMode = "ITG"
					SetGameModePreferences()
					THEME:ReloadMetrics()
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSM"):StartTransitioningScreen("SM_GoToNextScreen")
				end
			end
		end
		if params.Name == "CancelSingleSong" then
			-- if focus is not on OptionsWheel, we don't want to do anything
			if Input.WheelWithFocus ~= OptionsWheel then return end
			-- otherwise, run the function to cancel this single song choice
			Input.CancelSongChoice()
		end
	end,

	-- a hackish solution to prevent users from button-spamming and breaking input :O
	SwitchFocusToSongsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		setup.InitOptionRowsForSingleSong()

		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	EnableInputCommand=function(self)
		Input.Enabled = true
	end,

	--LoadActor("./PlayerOptionsShared.lua", {row, col, Input}),
	--LoadActor("./SongWheelShared.lua", {row, col, songwheel_y_offset}),

	-- included, but unused for now
	LoadActor("./GroupWheelShared.lua", {row, col, group_info}),

	LoadActor("./Header.lua", row),

--	GroupWheel:create_actors( "GroupWheel", row.how_many * col.how_many, group_mt, 0, 0, true),
	LoadActor("./gallery.lua"),

	LoadActor("FooterHelpText.lua"),
}

-- FIXME: This is dumb.  Add the player option StartButton visual last so it
--  draws over everything else and we can hide cursors behind it when needed...
t[#t+1] = LoadActor("./StartButton.lua")

return t