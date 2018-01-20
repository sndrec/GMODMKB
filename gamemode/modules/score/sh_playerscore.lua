local PLAYER = FindMetaTable("Player")

function PLAYER:GetMKBScore()
	return self:GetDTInt(8)
end

function PLAYER:SetMKBScore(score)
	self:SetDTInt(8, score)
end

function PLAYER:AddMKBScore(score)
	self:SetMKBScore(self:GetMKBScore() + score)
end

function PLAYER:GetMouseJoy()
	return self:GetDTVector(2)
end

function PLAYER:SetMouseJoy(vec)
	self:SetDTVector(2, vec)
end
