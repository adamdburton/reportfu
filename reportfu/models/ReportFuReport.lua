class 'ReportFuReport' extends 'ArticulateModel' is {
	
	public 'reporter' = function(self)
		return self:belongsTo('ReportFuUser', 'reporter_id')
	end,
		
	public 'reported' = function(self)
		return self:belongsTo('ReportFuUser', 'reported_id')
	end,
	
	public 'witnesses' = function(self)
		return self:hasMany('ReportFuWitness')
	end,
	
	public 'IsAcceptingWitnesses' = function(self)
		return self:witnesses():potential():count() > 0
	end,
	
	public 'IsValidWitness' = function(self, witness)
		return self:witnesses():potential():where('steamid64', witness:SteamID64()):count() > 0
	end,
	
	public 'AddWitnessStatement' = function(self, witness, accepted, statement)
		local witness = self:witnesses():where('steamid64', witness:SteamID64()):first()
		
		if not witness then return end
		
		return witness:update({
			accepted = accepted,
			statement = statement
		})
	end
	
}