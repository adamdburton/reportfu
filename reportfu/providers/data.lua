function PROVIDER:Initialize()
	if not file.IsDir('reportfu', 'DATA') then
		file.CreateDir('reportfu')
	end
end

function PROVIDER:LoadReport(id, callback)
	callback(util.JSONToTable(file.Read('reportfu/report_' .. id .. '.txt', 'DATA')))
end

function PROVIDER:SaveReport(id, report)
	file.Write('reportfu/report_' .. id .. '.txt', util.TableToJSON(report))
end