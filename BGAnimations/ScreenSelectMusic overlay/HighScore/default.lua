-- Pane3 displays a list of HighScores for the stepchart that was played.

local player = ...

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self)
		self:visible(false)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

-- row_height of a HighScore line
local rh
local args = { Player=player, RoundsAgo=1, RowHeight=rh}

	-- more breathing room between HighScore rows
	rh = 22
	args.RowHeight = rh

	-- top 10 machine HighScores
	args.NumHighScores = 10
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)

return pane