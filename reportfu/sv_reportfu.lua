ReportFu.sessionPlayers = {}

-- Utils and functions

function ReportFu:LoadReport(data)
	local REPORT = {}
	REPORT.__index = REPORT
	
	REPORT.Data = data or {}
	
	function REPORT:GetReporter()
		return self.Data.ReporterSteamID64
	end
	
	function REPORT:GetReporterAsPlayer()
		for _, ply in pairs(player.GetAll()) do
			if ply:SteamID64() == self.Data.ReporterSteamID64 then
				return ply
			end
		end
	end
	
	function REPORT:GetReported()
		return self.Data.ReportedSteamID64
	end
	
	function REPORT:GetReportedAsPlayer()
		for _, ply in pairs(player.GetAll()) do
			if ply:SteamID64() == self.Data.ReportedSteamID64 then
				return ply
			end
		end
	end
	
	function REPORT:Save()
		file.Write('report.txt', util.TableToJSON(self.Data))
	end
	
	function REPORT:IsAcceptingWitnesses()
		return self.Data.PotentialWitnesses and #self.Data.PotentialWitnesses > 0
	end
	
	function REPORT:IsValidWitness(ply)
		return (self.Data.PotentialWitnesses and self.Data.PotentialWitnesses[ply:SteamID64()]) and true or false
	end
	
	function REPORT:AddWitness(ply, accepted, statement)
		self.Data.PotentialWitnesses[ply:SteamID64()] = nil
		
		self.Data.Witnesses[ply:SteamID64()] = {
			Accepted = accepted,
			Statement = statement,
			Given = os.time()
		}
	end
	
	return REPORT
end

function ReportFu:GetReportByID(id)
	local json = file.Read('report.txt')
	
	if not json then return end
	
	local data = util.JSONToTable(json)
	
	if not data then return end
	
	return self:LoadReport(data)
end

function ReportFu:IsValidReporter(ply, reportedPlayerSteamID64)
	if not ReportFu.sessionPlayers[ply:SteamID64()] then return false end
	if not ReportFu.sessionPlayers[reportedPlayerSteamID64] then return false end
	
	if not IsValid(ReportFu.sessionPlayers[reportedPlayerSteamID64].Player) then
		ReportFu.sessionPlayers[reportedPlayerSteamID64].Leave = os.time()
	end
	
	local reporterOnline = ReportFu.sessionPlayers[ply:SteamID64()].Join
	local reporterOffline = ReportFu.sessionPlayers[ply:SteamID64()].Leave
	
	local reportedOnline = ReportFu.sessionPlayers[reportedPlayerSteamID64].Join
	local reportedOffline = ReportFu.sessionPlayers[reportedPlayerSteamID64].Leave
	
	if reporterOnline > reportedOnline or (reportedOffline and reporterOnline > reportedOffline) then return false end
	
	return true
end

-- Net hooks

net.Receive('rf_report', function(len, ply)
	local reportedPlayerSteamID64 = net.ReadString() or ''
	local reportReason = net.ReadString() or ''
	local reportWitnesses = net.ReadTable() or {}
	
	-- Sanity checks
	
	if not ReportFu:IsValidReporter(ply, reportedPlayerSteamID64) then return end
	
	-- Generate a new report
	
	local potentialWitnesses = {}
	
	for k, witness in pairs(reportWitnesses) do
		if ReportFu:IsValidReporter(witness, reportedPlayerSteamID64) then
			potentialWitnesses[witness:SteamID64()] = witness:SteamID64()
		end
	end
	
	local REPORT = ReportFu:GenerateReport({
		Created = os.time(),
		Reporter = ply:SteamID64(),
		Reported = reportedPlayerSteamID64,
		Reason = reportReason,
		PotentialWitnesses = potentialWitnesses,
		Witnesses = {}
	})
	
	-- Send witness requests to witnesses
	
	for k, witness in pairs(reportWitnesses) do
		if ReportFu:IsValidReporter(witness, reportedPlayerSteamID64) then
			net.Start('rf_witness_request')
				net.WriteString(ply:Nick())
				net.WriteString(ReportFu.sessionPlayers[reportedPlayerSteamID64].Nick)
			net.Send(witness)
		end
	end
	
	net.Start('rf_reported')
		net.WriteString(ReportFu.sessionPlayers[reportedPlayerSteamID64].Nick)
		net.WriteTable(witnesses)
	net.Send(ply)
end)

net.Receive('rf_witness', function(len, ply)
	local REPORT = ReportFu:GetReportByID(net.ReadInt(32) or 0)
	local accepted = net.ReadBit() and true or false
	local statement = net.ReadString() or ''
	
	-- Do a little sanity checking
	
	if not REPORT then return end
	if not REPORT:IsAcceptingWitnesses() then return end
	if not REPORT:IsValidWitness(ply) then return end
	
	REPORT:AddWitness(ply, accepted, statement)
end)

net.Receive('rf_request_report', function(len, ply)
	
end)

-- Gamemode hooks

hook.Add('Initialize', 'ReportFu_InitPostEntity', function()
	ReportFu.Initialize()
end)

hook.Add('PlayerInitialSpawn', 'ReportFu_PlayerInitialSpawn', function(ply)
	ReportFu.sessionPlayers[ply:SteamID64()] = {
		Nick = ply:Nick(),
		Join = os.time(),
		Player = ply
	}
end)

hook.Add('PlayerDisconnected', 'ReportFu_PlayerDisconnected', function(ply)
	ReportFu.sessionPlayers[ply:SteamID64()].Leave = os.time()
end)