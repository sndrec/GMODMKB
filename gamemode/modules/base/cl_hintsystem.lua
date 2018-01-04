MINIGAMES.Notices = MINIGAMES.Notices or {}

function Notify(text, length)
	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end

	local Panel = vgui.Create( "NoticePanel", parent )
	Panel.TimeCur = CurTime()+length
	Panel.StartTime = SysTime()
	Panel.Length = length
	Panel.VelX = -5
	Panel.VelY = 0
	Panel.fx = ScrW() + 100
	Panel.fy = ScrH()
	Panel:SetAlpha( 255 )
	Panel:SetText( text )
	Panel:SetPos( Panel.fx, Panel.fy )

	table.insert( MINIGAMES.Notices, Panel )
end


function NotifySelect(text, length, func1, func2)
	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end

	local Panel = vgui.Create( "NoticePanel", parent )
	Panel.TimeCur = CurTime()+length
	Panel.StartTime = SysTime()
	Panel.Length = length
	Panel.VelX = -5
	Panel.VelY = 0
	Panel.fx = ScrW() + 100
	Panel.fy = ScrH()
	Panel:SetAlpha( 255 )
	Panel:SetText( text )
	Panel:AddSelectOpt(func1,func2)
	Panel:SetPos( Panel.fx, Panel.fy )

	table.insert( MINIGAMES.Notices, Panel )
end

function notification.AddLegacy(txt,type,time) 
	Notify(txt,time)
end

-- This is ugly because it's ripped straight from the old notice system
local function UpdateNotice( pnl, total_h )

	local x = pnl.fx
	local y = pnl.fy

	local w = pnl:GetWide() + 16
	local h = pnl:GetTall() + 4

	local ideal_y = ScrH() - 150 - h - total_h
	local ideal_x = ScrW() - w - 20

	local timeleft = pnl.StartTime - ( SysTime() - pnl.Length )

	-- Cartoon style about to go thing
	if ( timeleft < 0.7 ) then
		ideal_x = ideal_x - 50
	end

	-- Gone!
	if ( timeleft < 0.2 ) then
		ideal_x = ideal_x + w * 2
	end

	local spd = RealFrameTime() * 15

	y = y + pnl.VelY * spd
	x = x + pnl.VelX * spd

	local dist = ideal_y - y
	pnl.VelY = pnl.VelY + dist * spd * 1
	if ( math.abs( dist ) < 2 && math.abs( pnl.VelY ) < 0.1 ) then pnl.VelY = 0 end
	dist = ideal_x - x
	pnl.VelX = pnl.VelX + dist * spd * 1
	if ( math.abs( dist ) < 2 && math.abs( pnl.VelX ) < 0.1 ) then pnl.VelX = 0 end

	-- Friction.. kind of FPS independant.
	pnl.VelX = pnl.VelX * ( 0.95 - RealFrameTime() * 8 )
	pnl.VelY = pnl.VelY * ( 0.95 - RealFrameTime() * 8 )

	pnl.fx = x
	pnl.fy = y
	pnl:SetPos( pnl.fx, pnl.fy )
	local t = pnl.TimeCur-CurTime()
	pnl.Stat:SetWidth((pnl:GetWide()) * t / pnl.Length)

	return total_h + h

end

local function Update()

	if (!MINIGAMES.Notices) then return end

	local h = 0
	for key, pnl in pairs(MINIGAMES.Notices) do
		h = UpdateNotice(pnl, h)
	end

	for k, Panel in pairs(MINIGAMES.Notices) do
		if (!IsValid(Panel) || Panel:KillSelf()) then MINIGAMES.Notices[k] = nil end
	end

end

hook.Add( "Think", "NotificationThink", Update )

local PANEL = {}

function PANEL:Init()

	self:DockPadding( 3, 3, 3, 3 )

	self.Label = vgui.Create( "DLabel", self )
	self.Label:Dock( FILL )
	self.Label:SetFont("Trebuchet18")
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	self.Label:SetContentAlignment( 5 )

	self.Stat = vgui.Create( "DPanel", self )
	self.Stat:SetPos( 0, self:GetTall() )
	self.Stat:SetSize( self:GetWide()*2, 3 )
	function self.Stat:Paint(w,h)
		draw.RoundedBox(2,0,0,w,h,Color(148,188,141))
	end

	self:SetBackgroundColor(Color(22,61,94))

end

function PANEL:SetText( txt )
	self.Label:SetText( txt )
	self:SizeToContents()
end

function PANEL:SizeToContents()

	self.Label:SizeToContents()
	self.Stat:SizeToContents()

	local width, tall = self.Label:GetSize()

	tall = math.max( tall, 32 ) - 5
	width = width + 10

	if ( IsValid( self.option1 ) ) then
		local i = (self.option2:GetWide()*2)+5
		width = (width + i)
		self.Label:Dock( RIGHT )
	end

	if ( self.Progress ) then
		tall = tall + 10
		self.Label:DockMargin( 0, 0, 0, 10 )
	end

	self:SetSize( width, tall )

	self:InvalidateLayout()

end

function PANEL:AddSelectOpt(func1,func2)
	local func1,func2 = func1 or function() end, func2 or function() end

	self.option1 = vgui.Create("DImageButton", self)
	self.option1:SetImage("icon16/accept.png")
	self.option1:SetSize(16,16)
	self.option1:SetPos(2.5,4)
	self.option1.DoClick = function()
		self.Length = 2.5
		self:SetBackgroundColor(Color(127,238,89))
		func1()
	end

	self.option2 = vgui.Create("DImageButton", self)
	self.option2:SetImage("icon16/delete.png")
	self.option2:SetSize(16,16)
	self.option2:SetPos(23.5,4)
	self.option2.DoClick = function()
		print(self.Length)
		self.Length = 2.5
		self:SetBackgroundColor(Color(250,88,88))
		func2()
	end

	self:SizeToContents()
end

function PANEL:SetLegacyType()

end

function PANEL:Paint( w, h )

	self.BaseClass.Paint( self, w, h )
	if ( !self.Progress ) then return end
	surface.SetDrawColor(self:GetColor())
	surface.DrawRect( 4, self:GetTall() - 10, self:GetWide() - 8, 5 )

	surface.SetDrawColor( 0, 50, 0, 255 )
	surface.DrawRect( 5, self:GetTall() - 9, self:GetWide() - 10, 3 )

	local w = self:GetWide() * 0.25
	local x = math.fmod( SysTime() * 200, self:GetWide() + w ) - w

	if ( x + w > self:GetWide() - 11 ) then w = ( self:GetWide() - 11 ) - x end
	if ( x < 0 ) then w = w + x; x = 0 end

	surface.SetDrawColor( 0, 255, 0, 255 )
	surface.DrawRect( 5 + x, self:GetTall() - 9, w, 3 )
end

function PANEL:SetProgress()
	self.Progress = true
	self:SizeToContents()
end

function PANEL:KillSelf()
	if ( self.StartTime + self.Length < SysTime() ) then
		self:Remove()
		return true
	end
	return false
end

vgui.Register( "NoticePanel", PANEL, "DPanel" )