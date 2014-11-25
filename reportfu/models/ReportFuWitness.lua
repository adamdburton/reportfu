class 'ReportFuWitness' extends 'ArticulateModel' is {
	
	public 'report' = function(self)
		return self:belongsTo('ReportFuReport')
	end,
		
	public 'scopePotential' = function(self, query)
		query:where('confirmed', 0)
	end,
		
	public 'scopeConfirmed' = function(self, query)
		query:where('confirmed', 1)
	end
	
}