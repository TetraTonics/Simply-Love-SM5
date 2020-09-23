return LoadActor( THEME:GetPathB("ScreenTitleMenu", "underlay/SimplySomething.lua"))..{
	InitCommand=function(self) self:Center() end
		if (image == "PSU") then
			self:xy(_screen.cx+2, _screen.cy-47):diffusealpha(0):zoom(0.7)
				:shadowlength(1)
		else
			self:xy(_screen.cx+2, _screen.cy-16):diffusealpha(0):zoom(0.7)
				:shadowlength(1)
		end
}