ReportFu.sessionPlayers = {}

-- Utils and functions

function ReportFu:LoadReport(id)
	return new ('ReporFuReport'):find(id)
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

--[[
	Net hooks
]]--

-- Player reported player

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
	
	-- Sne the details of the report back to the user
	
	net.Start('rf_reported')
		net.WriteString(ReportFu.sessionPlayers[reportedPlayerSteamID64].Nick)
		net.WriteTable(witnesses)
	net.Send(ply)
end)

-- Player sent witness report

net.Receive('rf_witness', function(len, ply)
	local report = ReportFu:LoadReport(net.ReadInt(32) or 0)
	local accepted = net.ReadBit() and true or false
	local statement = net.ReadString() or ''
	
	-- Do a little sanity checking
	
	if not report then return end
	if not report:IsAcceptingWitnesses() then return end
	if not report:IsValidWitness(ply) then return end
	
	REPORT:AddWitnessStatement(ply, accepted, statement)
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