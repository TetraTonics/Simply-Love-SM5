-- use the current game (dance, pump, etc.) to load the apporopriate logo

local game = GAMESTATE:GetCurrentGame():GetName()
local path = ("/%s/Graphics/_logos/%s"):format( THEME:GetCurrentThemeDirectory(), game)

-- Fall back on using the dance logo asset if one isn't found for the current game.
-- We can't use FILEMAN:DoesFileExist() here because it needs an already-resolved path,
-- but "path" (above) might resolve to either a png or a directory.
--
-- So, use ActorUtil.ResolvePath() to attempt to resolve the path.
-- If it doesn't resolve to a valid StepMania path, it will return nil,
-- and we can use that mean that neither a png nor a directory was found for this game.
local resolved_path = ActorUtil.ResolvePath(path, 1, true)
if resolved_path == nil then
	game = "dance"
	resolved_path = ("/%s/Graphics/_logos/dance.png"):format( THEME:GetCurrentThemeDirectory() )
end

-- -----------------------------------------------------------------------
local af = Def.ActorFrame{}

-- SIMPLY [something]
af[#af+1] = Def.Sprite{
	Name="Simply Text",
	InitCommand=function(self)
		self:playcommand("LoadImage")
	end,
	OffCommand=function(self) self:linear(0.5):shadowlength(0) end,
	VisualStyleSelectedMessageCommand=function(self)
		self:playcommand("LoadImage")
	end,
	LoadImageCommand=function(self)
		if (style == "PSU") then
			self:x(2):zoom(0.8):shadowlength(0.75)
			self:y(-47)
		else
			local style = ThemePrefs.Get("VisualStyle")
			local image = THEME:GetPathG("", "_VisualStyles/"..style.."/TitleMenu (doubleres).png")
			local imageAlt = "/Themes/"..THEME:GetCurThemeName().."/Graphics/_VisualStyles/"..style.."/TitleMenuAlt (doubleres).png"
			if FILEMAN:DoesFileExist(imageAlt) and math.random(1,100) <= 10 then
				self:Load(imageAlt)
			else
				self:Load(image)
			end
			self:zoom(0.7):vertalign(top)
			self:y(-102):shadowlength(0.75)
		end
	end,
}

-- decorative arrows
af[#af+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
	InitCommand=function(self)
		self:y(-16)
		self:visible(ThemePrefs.Get("VisualStyle") ~= "SRPG5")

		-- get a reference to the SIMPLY [something] graphic
		-- it's rasterized text in the Wendy font like "SIMPLY LOVE" or "SIMPLY THONK" or etc.
		local simply = self:GetParent():GetChild("Simply Text")

		-- zoom the logo's width to match the width of the text graphic
		-- zoomtowidth() performs a "horizontal" zoom (on the x-axis) to meet a provided pixel quantity
		--    and leaves the y-axis zoom as-is, potentially skewing/squishing the appearance of the asset
		self:zoomtowidth( simply:GetZoomedWidth() )

		-- so, get the horizontal zoom factor of these decorative arrows
		-- and apply it to the y-axis as well to maintain proportions
		self:zoomy( self:GetZoomX() )
	end,
	VisualStyleSelectedMessageCommand=function(self)
		self:visible(ThemePrefs.Get("VisualStyle") ~= "SRPG5")
	end,
}

return af
