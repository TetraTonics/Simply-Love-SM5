-- SM5 Favorites manager by leadbman & modified for RIO by Rhythm Lunatic
-- Slightly Modified and implemented by Crash Cringle

-- Inhibit Regular Expression magic characters ^$()%.[]*+-?)
local function strPlainText(strText)
	-- Prefix every non-alphanumeric character (%W) with a % escape character, 
	-- where %% is the % escape, and %1 is original character
	return strText:gsub("(%W)","%%%1")
end

addOrRemoveFavorite = function(player)
	local profileName = PROFILEMAN:GetPlayerName(player)
	local path = PROFILEMAN:GetProfileDir(ProfileSlot[PlayerNumber:Reverse()[player]+1]).."FavoriteSongs.txt"
	local sDir = GAMESTATE:GetCurrentSong():GetSongDir()
	local sTitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle();
	local arr = split("/",sDir);
	local favoritesString = lua.ReadFile(path) or "";
	if not PROFILEMAN:IsPersistentProfile(player) then
		favoritesString = "";
	elseif favoritesString then
		--If song found in the player's favorites
		local checksong = string.match(favoritesString, strPlainText(arr[3].."/"..arr[4]))

		--If no favorites exist yet, create a group title first.
		--Well, we would, but we don't need to do this anyway since the generateFavoritesForMusicWheel function handles it...
		--[[if string.len(favoritesString) == 0 then
			favoritesString = "---"..profileName.."'s Favorites".."\r\n";
		end;]]
		
		--Song found
		if checksong then
			favoritesString= string.gsub(favoritesString, strPlainText(arr[3].."/"..arr[4]).."\n", "")
			SCREENMAN:SystemMessage(sTitle.." removed from "..profileName.."'s Favorites.")
			SOUND:PlayOnce(THEME:GetPathS("", "Common invalid.ogg"))
		else
			favoritesString= favoritesString..arr[3].."/"..arr[4].."\n";
			SCREENMAN:SystemMessage(sTitle.." added to "..profileName.."'s Favorites.")
			SOUND:PlayOnce(THEME:GetPathS("", "_unlock.ogg"))
		end
			
	end

	-- write string
	local file= RageFileUtil.CreateRageFile()
	if not file:Open(path, 2) then
		Warn("**Could not open '" .. path .. "' to write current playing info.**")
	else
		file:Write(favoritesString)
		file:Close()
		file:destroy()
	end
end

generateFavoritesForMusicWheel = function()
	local strToWrite = ""
	local listofavorites = {}
	for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
		local profileName = PROFILEMAN:GetPlayerName(pn)
		local path = PROFILEMAN:GetProfileDir(ProfileSlot[PlayerNumber:Reverse()[pn]+1]).."FavoriteSongs.txt"
		if FILEMAN:DoesFileExist(path) then
			local favs = lua.ReadFile(path)
			if string.len(favs) > 2 then
				setenv(pname(pn).."HasAnyFavorites",true)
				-- split the context of the txt file on newline characters
				-- groupsong will be one line from the file
				for line in favs:gmatch("[^\r\n]+") do
					listofavorites[#listofavorites+1] = {line, Basename(line)}
				end
				table.sort(listofavorites, function(a, b) return a[2]:upper() < b[2]:upper() end)
				strToWrite= strToWrite.."---"..profileName.."'s Favorites\r\n";
				
				for fav in ivalues(listofavorites) do 
					strToWrite = strToWrite..fav[1].."\n";
					--Warn(strToWrite)
				end		
			end
		else
			Warn("No favorites found at "..path)
		end
	end
	if strToWrite ~= "" then
		--Warn(strToWrite
		local path = THEME:GetCurrentThemeDirectory().."Other/SongManager FavoriteSongs.txt"
		-- create a generic RageFile that we'll use to read the contents

		local file= RageFileUtil.CreateRageFile()
		if not file:Open(path, 2) then
			Warn("Could not open '" .. path .. "' to write current playing info.")
		else
			file:Write(strToWrite)
			file:Close()
			file:destroy()
		end
	end
end


--[[
This is the only way to use favorites in the stock StepMania songwheel, 
It reads the favorites file and then generates a Preferred Sort formatted file which SM can read.
Call this before ScreenSelectMusic and after addOrRemoveFavorite.
To open the favorties folder, call this from ScreenSelectMusic:
SCREENMAN:GetTopScreen():GetMusicWheel():ChangeSort("SortOrder_Preferred")
SONGMAN:SetPreferredSongs("FavoriteSongs");
SCREENMAN:GetTopScreen():GetMusicWheel():SetOpenSection("P1 Favorites");
]]