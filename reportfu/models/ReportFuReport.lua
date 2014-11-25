class 'ReportFuReport' extends 'ArticulateModel' is {
	
	public 'reporter' = function(self)
		return self:hasOne('ReportFuUser', 'reporter_id')
	end,
		
	public 'reported' = function(self)
		return self:hasOne('ReportFuUser', 'reported_id')
	end,
	
	public 'witnesses' = function(self)
		return self:hasMany('ReportFuWitness')
	end,
	
	public 'getAcceptingWitnessesAttribute' = function(self)
		return self:witnesses():potential():count() > 0
	end
	
}