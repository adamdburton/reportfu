class 'ReportFuPlayer' extends 'ArticulateModel' is {
	
	public 'reports' = function(self)
		return self:belongsToMany('ReportFuReport')
	end,
	
	public 'getPlayer' = function(self)
		for _, ply in pairs(player.GetAll()) do
			if ply:SteamID64() == self.steamId64 then
				return ply
			end
		end
		
		return false
	end
	
}