function PROVIDER:Initialize()
	sql.Query('CREATE TABLE IF NOT EXISTS reportfu_statuses (id INTEGER PRIMARY KEY, name STRING, display_order INTEGER)')
	sql.Query('CREATE TABLE IF NOT EXISTS reportfu_reports (id INTEGER PRIMARY KEY, status_id INTEGER, reporter_steamid STRING, reporter_name STRING, reported_steamid STRING, reported_name STRING, reason STRING, created_at INTEGER, updated_at INTEGER)')
	sql.Query('CREATE TABLE IF NOT EXISTS reportfu_witnesses (id INTEGER PRIMARY KEY, report_id INTEGER, witness_steamid STRING, witness_name STRING, accepted INTEGER, statement STRING, created_at INTEGER, updated_at INTEGER)')
end

function PROVIDER:LoadReport(id, callback)
	local reportData = sql.QueryRow('SELECT * FROM reportfu_reports WHERE id = ' .. id .. ' LIMIT 1')
	
	if #reportData then
		local witnessData = sql.Query('SELECT * FROM reportfu_witnesses WHERE report_id = ' .. id)
		
		reportData.witnesses = witnessData or {}
		
		callback(reportData)
	end
end

function PROVIDER:SaveReport(id, report)
	local reportData = sql.QueryRow('SELECT * FROM reportfu_reports WHERE id = ' .. id .. ' LIMIT 1')
	
	if #reportData then
		sql.Query('UPDATE reportfu_reports SET ')
	else
		
	end
end