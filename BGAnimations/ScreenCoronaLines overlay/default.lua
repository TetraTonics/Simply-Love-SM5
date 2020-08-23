return Def.ActorFrame{
	LoadActor("Guidelines.png")..{
		InitCommand=function(self) self:FullScreen() end,
		OnCommand=function(self) self:FullScreen():diffusealpha(0):decelerate(2):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
	},
}