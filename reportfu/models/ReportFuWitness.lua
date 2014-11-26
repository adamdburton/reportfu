class 'ReportFuWitness' extends 'ArticulateModel' is {
	
	public 'report' = function(self)
		return self:belongsTo('ReportFuReport')
	end,
		
	public 'scopePotential' = function(self, query)
		query:where('accepted', 0)
	end,
		
	public 'scopeConfirmed' = function(self, query)
		query:where('accepted', 1)
	end
	
}