local ReportFu = {}
ReportFu.__index = ReportFu

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('reportfu/cl_reportfu.lua')
	
	include('reportfu/sv_reportfu.lua')
end

if CLIENT then
	include('reportfu/cl_reportfu.lua')
end