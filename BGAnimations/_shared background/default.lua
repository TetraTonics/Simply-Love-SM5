-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	return LoadActor( THEME:GetPathB("", "_shared background/Snow.lua") )
end
local file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualStyle") .. "/SharedBackground.png")

local af = Def.ActorFrame{}

-- use the "VisualStyle" ThemePrefs value to generate a proper filepath to the appropriate
-- SharedBackground texture and pass it to Normal.lua and RainbowMode.lua now as this file
-- is being initialized.

-- if the player chooses a different VisualStyle during runtime, MESSAGEMAN will broadcast
-- "BackgroundImageChanged" which we can use in Normal.lua and RainbowMode.lua to Load() the
-- newly-appropriate texture from disk into each Sprite; see also: ./BGAnimations/ScreenOptionsService overlay.lua
local file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualStyle") .. "/SharedBackground.png")

-- a simple Quad to serve as the backdrop
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black ) end,
	BackgroundImageChangedMessageCommand=function(self)
		THEME:ReloadMetrics() -- is this needed here?  -quietly
		-- Removed it out of curiosity to see what would happen, from my observations it didn't change anything?
		-- I tested specifically with PSU at first since I figured that was the most likely style to break, but
		-- that and others seem to be okay without her. But who knows -- Crash Cringle
		SL.Global.ActiveColorIndex = ThemePrefs.Get("RainbowMode") and 3 or ThemePrefs.Get("SimplyLoveColor")
		self:linear(1):diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
	end
}
af[#af+1] = LoadActor("./Normal.lua", file)
af[#af+1] = LoadActor("./RainbowMode.lua", file)
-- the best way school spirit! We are..?
af[#af+1] = LoadActor( THEME:GetPathB("", "_shared background/spirit.lua") )

return af
