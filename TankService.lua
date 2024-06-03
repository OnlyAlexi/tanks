local Knit = require(game.ReplicatedStorage.Packages.Knit)

local BridgeNet2 = require(game.ReplicatedStorage.Packages.BridgeNet2)

local ServerBridge = BridgeNet2.ReferenceBridge("TankBridge")
local Tank = require(script.Tank)

local TweenService = game:GetService("TweenService")
--
math.randomseed(tick())
local TankModel = game.ServerStorage.Tank
local Spawns = workspace.Spawns
local Players = {}

local TankService = Knit.CreateService { 
	Name = "TankServer",
}

local KillFeedRemote = BridgeNet2.ReferenceBridge("KillFeed")
local UpdateUIRemote = BridgeNet2.ReferenceBridge("UpdateUI")
local UpdateTimerRemote = BridgeNet2.ReferenceBridge("UpdateTimer")

local RoundInProgress = false
local GameMode = false
--
local selfDeath_Messages = { 
	'<font color="#FF0000"> blew themselves up</font>',
	'<font color="#FF0000"> died</font>',
	'<font color="#FF0000"> made a mistake</font>',
	'<font color="#FF0000"> ALT F4d</font>', 
}

local pvpDeath_Messages = {
	'<font color="#FF0000"> blasted </font>',
	'<font color="#FF0000"> DESTROYED </font>',
	'<font color="#FF0000"> rekt </font>',
	'<font color="#FF0000"> dunked on </font>'
}


--

coroutine.resume(coroutine.create(function() 
	while wait(1) do
		if #Players > 0 then 
			for _,Player in pairs(Players) do
				if Player[3] > 0 then 
					Player[3]-=1
				end
			end
		end
	end
end))

--

function TankService.Client:UpdateScores()
	local pTable = {}
	for i,v in pairs(Players) do
		table.insert(pTable, v)
	end
	return pTable
end


function TankService.Client:NewRound(player, gamemode)
	if gamemode == "KDA" then
		RoundInProgress = true
		UpdateUIRemote:Fire(BridgeNet2.AllPlayers(), "KDA")
	end
	
	for q,x in pairs(game.Players:GetChildren()) do 
		spawn(function()
			if x.Character.Parent ~= game.Lighting then
				x:LoadCharacter()
			end
		end)
	end
	
	spawn(function()
		for i = 999999,0,-1 do
			UpdateTimerRemote:Fire(BridgeNet2.AllPlayers(), i)
			wait(1)
		end
		RoundInProgress = false
		for p,Player in pairs (Players) do
			if Player[2].Model then
				Player[2].Model:Destroy()
				Player[1]:LoadCharacter()
			end
		end
	end)
end

function TankService:FindPlayerObject(player)
	if #Players > 0 then
		for _,Player in pairs(Players) do
			if Player[1] == player then 
				return Player
			else 
				print(Player)
			end
		end
	end
	return 0
end

function cleanupTankDebris(PTank)
	for i,v in pairs(PTank:GetDescendants()) do
		if v:IsA("MeshPart") then
			TweenService:Create(v, TweenInfo.new(5, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
			v.CanCollide = false
		else if v:IsA("ParticleEmitter") then 
				v.Enabled = false
			end
		end
	end
end

function TankService:NewTank(playerRequesting) 
	if #Players > 0 then
		for i,v in pairs(Players) do 
			if v[1] == playerRequesting then
				if v[4] then
					if v[4] > 0 then
						v[4]-=1
						local newTankModel =  game.ServerStorage.Tank:Clone() ; newTankModel.Name = playerRequesting.Name.. "Tank"
						newTankModel:SetAttribute("Name", playerRequesting.Name)
						newTankModel.Parent = workspace ; newTankModel:PivotTo(Spawns:GetChildren()[math.random(1,#workspace.Spawns:GetChildren())].CFrame)
						for _,tankPart in pairs(newTankModel:GetChildren()) do
							if tankPart:IsA("BasePart") then 
								tankPart:SetNetworkOwner(playerRequesting)
							end
						end

						for q,x in pairs(game.Players:GetChildren()) do 
							local newIcon = game.ReplicatedStorage.Icon:Clone()
							newIcon.Parent = x.PlayerGui
							newIcon.Adornee = newTankModel.Top
							newIcon.ImageLabel.Image = game.Players:GetUserThumbnailAsync(playerRequesting.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
						end
						
						local newTankObject = Tank.new(10000, newTankModel)
						
						v[2] = newTankObject
						return newTankObject
					else 
						return
					end
					
				else 
					local newTankModel =  game.ServerStorage.Tank:Clone() ; newTankModel.Name = playerRequesting.Name.. "Tank"
						newTankModel:SetAttribute("Name", playerRequesting.Name)
						newTankModel.Parent = workspace ; newTankModel:PivotTo(Spawns:GetChildren()[math.random(1,#workspace.Spawns:GetChildren())].CFrame)
						for _,tankPart in pairs(newTankModel:GetChildren()) do
							if tankPart:IsA("BasePart") then 
								tankPart:SetNetworkOwner(playerRequesting)
							end
						end

						for q,x in pairs(game.Players:GetChildren()) do 
							local newIcon = game.ReplicatedStorage.Icon:Clone()
							newIcon.Parent = x.PlayerGui
							newIcon.Adornee = newTankModel.Top
							newIcon.ImageLabel.Image = game.Players:GetUserThumbnailAsync(playerRequesting.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
						end
						
						local newTankObject = Tank.new(10000, newTankModel)
						
						table.insert(Players, {playerRequesting, newTankObject, 0, 2})
						return newTankObject
					
					end
				end
			end
		end
	
	local newTankModel =  game.ServerStorage.Tank:Clone() ; newTankModel.Name = playerRequesting.Name.. "Tank"
	newTankModel:SetAttribute("Name", playerRequesting.Name)
	newTankModel.Parent = workspace ; newTankModel:PivotTo(Spawns:GetChildren()[math.random(1,#workspace.Spawns:GetChildren())].CFrame)
	for _,tankPart in pairs(newTankModel:GetChildren()) do
		if tankPart:IsA("BasePart") then 
			tankPart:SetNetworkOwner(playerRequesting)
		end
	end

	for q,x in pairs(game.Players:GetChildren()) do 
		local newIcon = game.ReplicatedStorage.Icon:Clone()
		newIcon.Parent = x.PlayerGui
		newIcon.Adornee = newTankModel.Top
		newIcon.ImageLabel.Image = game.Players:GetUserThumbnailAsync(playerRequesting.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end

	local newTankObject = Tank.new(10000, newTankModel)

	table.insert(Players, {playerRequesting, newTankObject, 0, 2})
	return newTankObject
end


function TankService.Client:NewTank(Player)
	if RoundInProgress == true then
		local PlayerNewTank = TankService:NewTank(Player)
		if PlayerNewTank then
	if not PlayerNewTank.Model then 
		for i = 1,5 do 
			if (i >= 5) then 
				Player:Kick("Kicked due to unexpected behaivour.") 
			end
			if PlayerNewTank.Model then 
				break
			end
		end
	end
		return PlayerNewTank.Model
		end
	end
end


function TankService.Client:DestroyTank(player, partHit, pvp)
	local Rand = Random.new(tick())
	if partHit then
	partHit.Parent:BreakJoints() ; for i,TankPart in pairs(partHit.Parent:GetChildren()) do
		if TankPart:IsA("BasePart") then
			TankPart:SetNetworkOwner() 
			TankPart:ApplyImpulse(Vector3.new(Rand:NextInteger(-200,200)*TankPart:GetMass(),200*TankPart:GetMass(),Rand:NextInteger(-200,200)*TankPart:GetMass()))
				TankPart.CanCollide = true
				
				task.delay(3, function()
					TweenService:Create(TankPart, TweenInfo.new(1), {Transparency = 1}):Play()
					task.wait(1)
					TankPart:Destroy()
				end)
		end
	end
	
	if not pvp then
		KillFeedRemote:Fire(BridgeNet2.AllPlayers(), player.Name..selfDeath_Messages[math.random(1,#selfDeath_Messages)])
	end
end
end


function GetObject(obj, pname)
	local fullname = obj:GetFullName()
	local segments = fullname:split(".")
	local current = game
	
	for _,location in pairs(segments) do
		current = current[location]
		if current.Name:match("Tank") then
			print(current:GetAttribute("Name"))
			return current
		end
	end

end

math.randomseed(tick())
local Rand = Random.new(tick())

function TankService.Client:Shoot(player, ShootData)
	local Shooter = player
	local StartPosition = ShootData[2]
	local EndPosition = Vector3.new(ShootData[3].X, StartPosition.Y, ShootData[3].Z)
	local partHit = ShootData[1]
	local surfacenormal = ShootData[4]
	local startNormal = ShootData[5]
	local hitPlayer
	if partHit.Parent:GetAttribute("Name") then
		hitPlayer = game:GetService("Players"):FindFirstChild(partHit.Parent:GetAttribute("Name"))
	end
	
	print(player.Name)
	if #ShootData == 5 then
		game.SoundService.TankShoot:Play()
		if partHit.Name == "Breakable" then
			TweenService:Create(partHit, TweenInfo.new(0.5), {Transparency = 1}):Play()
			partHit.CanCollide = false 
		end
		
		local Rocket = game.ReplicatedStorage.Rocket:Clone()
		Rocket.Parent = workspace ; Rocket.CFrame = CFrame.new(StartPosition, EndPosition)
		TweenService:Create(Rocket, TweenInfo.new((StartPosition-EndPosition).magnitude/350, Enum.EasingStyle.Linear), {Position = EndPosition}):Play()
		
		local theHit = false
		
		if partHit.Parent:GetAttribute("Name") then
			if hitPlayer then
				theHit = true
				task.delay((StartPosition-EndPosition).magnitude/350, function()
					game.SoundService.TankExplode:Play()
					local Explosion = Instance.new("Explosion")
					Explosion.DestroyJointRadiusPercent = 0
					Explosion.Position = EndPosition ; Explosion.Parent = workspace
					Explosion.Visible = false
					Rocket:Destroy()
				KillFeedRemote:Fire(BridgeNet2.AllPlayers(), player.Name..pvpDeath_Messages[math.random(1,#selfDeath_Messages)]..hitPlayer.Name)
				partHit.Parent:BreakJoints() ; for i,TankPart in pairs(partHit.Parent:GetChildren()) do
					if TankPart:IsA("BasePart") then
						TankPart:SetNetworkOwner() 
						TankPart:ApplyImpulse(Vector3.new(Rand:NextInteger(-3000,3000),6000,Rand:NextInteger(-3000,3000)))
						TankPart.CanCollide = true
						if TankPart.Name == "ShootPart" then
							TankPart.Beam:Destroy()
						end
						task.delay(3, function()
								TweenService:Create(TankPart, TweenInfo.new(1), {Transparency = 1}):Play()
								wait(1)
								TankPart:Destroy()
						end)
					end
				end
				
					task.delay(3, function()
						hitPlayer:LoadCharacter()
					end)
				
				end)
			end
		end
		
		if theHit == false then
		task.delay(((StartPosition-EndPosition).magnitude/350)-0.01, function()
			local reflectedNormalEarly = (startNormal - (2 * startNormal:Dot(surfacenormal) * surfacenormal))
			local ShapecastResult = workspace:Spherecast(EndPosition,
				2,  reflectedNormalEarly * 1000)
			
			if ShapecastResult then
				Rocket.CFrame = CFrame.new(EndPosition, ShapecastResult.Position)
				TweenService:Create(Rocket, TweenInfo.new((EndPosition-ShapecastResult.Position).magnitude/350, Enum.EasingStyle.Linear), {Position = ShapecastResult.Position}):Play()
				
				task.delay((EndPosition-ShapecastResult.Position).magnitude/350, function() 
					game.SoundService.TankExplode:Play()
					local Explosion = Instance.new("Explosion")
					Explosion.DestroyJointRadiusPercent = 0
					Explosion.Position = ShapecastResult.Position ; Explosion.Parent = workspace
					Explosion.Visible = false
					Rocket:Destroy()
					
					if ShapecastResult.Instance.Parent:GetAttribute("Name") then
						hitPlayer = game:GetService("Players"):FindFirstChild(ShapecastResult.Instance.Parent:GetAttribute("Name"))
						KillFeedRemote:Fire(BridgeNet2.AllPlayers(), player.Name..pvpDeath_Messages[math.random(1,#selfDeath_Messages)]..hitPlayer.Name)
						ShapecastResult.Instance.Parent:BreakJoints() ; for i,TankPart in pairs(ShapecastResult.Instance.Parent:GetChildren()) do
							if TankPart:IsA("BasePart") then
								TankPart:SetNetworkOwner() 
								TankPart:ApplyImpulse(Vector3.new(Rand:NextInteger(-3000,3000),6000,Rand:NextInteger(-3000,3000)))
								TankPart.CanCollide = true
								if TankPart.Name == "ShootPart" then
									TankPart.Beam:Destroy()
								end
								task.delay(3, function()
										TweenService:Create(TankPart, TweenInfo.new(1), {Transparency = 1}):Play()
										wait(1)
										TankPart:Destroy()
								end)
							end
						end
						
						task.delay(3, function()
							hitPlayer:LoadCharacter()
						end)
					end
					
				end)
				
			else
				game.SoundService.TankExplode:Play()
				local Explosion = Instance.new("Explosion")
				Explosion.DestroyJointRadiusPercent = 0
				Explosion.Position = EndPosition ; Explosion.Parent = workspace
				Explosion.Visible = false
				Rocket:Destroy()
			end
			
			
		end)
		end
		
		return (StartPosition-EndPosition).magnitude/500
	end
	
	return false
end



Knit.Start()
