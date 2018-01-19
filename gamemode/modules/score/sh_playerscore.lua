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