local Knit = require(game.ReplicatedStorage.Packages.Knit)
local BridgeNet2 = require(game.ReplicatedStorage.Packages.BridgeNet2)

local ClientBridge

Knit.Start():await()
local TankServer = Knit.GetService("TankServer")

--
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
--
local CurrentTank
local CurrentRot = 90
local CurrentTankRot = 0
local LastUpdatedRot = 0

local FL = 0
local BL = 0
local old_FL = 0
local Mouse = game.Players.LocalPlayer:GetMouse()
local Cam = workspace.CurrentCamera

local Remote = BridgeNet2.ReferenceBridge("KillFeed")
local UpdateUIRemote = BridgeNet2.ReferenceBridge("UpdateUI")
local UpdateTimer = BridgeNet2.ReferenceBridge("UpdateTimer")


local shootCooldown = true

function FireTank(Tank, Shapeposition)
	local Body = Tank:FindFirstChild("Body")
	local ShootPart = Tank:FindFirstChild("ShootPart")

	--local Unit = (ShootPart.Position - Shapecast.Position).unit
	if Body and ShootPart then
		Body:ApplyImpulse(-ShootPart.CFrame.LookVector*200000)
	end

	local SCOREUI = game.Players.LocalPlayer.PlayerGui.Score

	--TankServer:UpdateScores():andThen(function(DataTable)
		--for i,v in pairs(DataTable) do
		--	if SCOREUI:FindFirstChild(v[1].Name) then
		--		SCOREUI:FindFirstChild(v[1].Name).Text = v.Name.." - "..tostring(v[4])
		--	end
		--end
	--end)
end

local KillFeeds = 0

UpdateUIRemote:Connect(function(gamemode)
	--if gamemode == "KDA" then
	--	local SCOREUI = game.Players.LocalPlayer.PlayerGui.Score
	--	SCOREUI.Blue.Visible = false
	--	SCOREUI.Red.Visible = false
	--	SCOREUI.Leaderboard.Visible = true
--
	--	TankServer:UpdateScores():andThen(function(DataTable)
		--	for i,v in pairs(DataTable) do
		--		local pLabel = SCOREUI.Leaderboard[i]
		--		pLabel.Name = v[1].Name
		--		pLabel.Text = v[1].Name.." - " tostring(v[4])
		--	end
		--end)
	--else 
		--local SCOREUI = game.Players.LocalPlayer.PlayerGui.Score
		--SCOREUI.Blue.Visible = false
		--SCOREUI.Red.Visible = false
		--SCOREUI.Leaderboard.Visible = true
	--end
end)


UpdateTimer:Connect(function(timertime)
	local SCOREUI = game.Players.LocalPlayer.PlayerGui.Score
	SCOREUI.message_frame.Time.Text = timertime
end)



function newKillFeedEntry(Text)
	local Template = game.Players.LocalPlayer.PlayerGui.KillFeed.Template
	local Score = game.Players.LocalPlayer.PlayerGui.Score
	Score.Blue.Score.Text = tostring(tonumber(Score.Blue.Score.Text)+1)
	local newTemplate = Template:Clone() ; newTemplate.Parent = game.Players.LocalPlayer.PlayerGui.KillFeed.Frame
	KillFeeds+=1
	newTemplate.Name = tostring(KillFeeds)
	newTemplate.Text = Text

	for i,v in pairs(game.Players.LocalPlayer.PlayerGui.KillFeed.Frame:GetChildren()) do
		if v:IsA("TextLabel") then
			if v.Name == "5" then
				v:Destroy()
				KillFeeds = 0
			else 
				v.Name = tostring(tonumber(v.Name)+1)
			end
		end
	end

	newTemplate.Visible = true
end


Remote:Connect(function(str)
	newKillFeedEntry(str)
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
	local UI = game.Players.LocalPlayer.PlayerGui:WaitForChild("RecordUI").RecordFrame.OptionsF

	UI.StartKDA.MouseButton1Click:Connect(function()
		TankServer:NewRound("KDA")
	end)
	TankServer:NewTank():andThen(function(Tank)
		if Tank then
			CurrentTank = Tank
			CurrentTank.Top.AlignOrientation.CFrame = CFrame.Angles(0,math.rad(CurrentRot), math.rad(90))
			Cam.CameraType = Enum.CameraType.Scriptable
			Cam.CFrame = CFrame.new(CurrentTank.Body.Position + Vector3.new(0,250,0), CurrentTank.Body.Position)

			local Highlight = Instance.new("Highlight")
			Highlight.Parent = CurrentTank
			Highlight.Adornee = CurrentTank
			Highlight.FillColor = Color3.new(255,255,255)
			Highlight.FillTransparency = 0.6
			local CharacterDeathConnection
			CharacterDeathConnection = game.Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
				TankServer:DestroyTank(CurrentTank:FindFirstChild("ShootPart"))
				game.Players.LocalPlayer.Character.Humanoid:TakeDamage(100)
					CharacterDeathConnection:Disconnect()
					CurrentTank = nil
			end)
		else 
		end
	end)
end)


ClientBridge = BridgeNet2.ReferenceBridge("TankBridge")

RunService:BindToRenderStep("TankMovement", 100, function() 
	if CurrentTank then
		if CurrentTank:FindFirstChild("Body") then
			--Cam.CFrame = CFrame.new(CurrentTank.Body.Position + Vector3.new(-150,250,0), CurrentTank.Body.Position)
			Cam.CFrame = CFrame.new(CurrentTank.Top.Position + Vector3.new(100,400,0), CurrentTank.Top.Position)
			--ClientBridge:Fire({CFrame.Angles(0, math.rad(CurrentRot), math.rad(90)),FL,0,0,0, CFrame.Angles(0,math.rad(CurrentTankRot),0)})
			local Model = CurrentTank
			if Model then 

				if CurrentTankRot ~= LastUpdatedRot then 
					Model.Body.AlignOrientation.CFrame = CFrame.Angles(0,math.rad(CurrentTankRot),0)
					--Model.Top.AlignOrientation.CFrame = Align
				end

				if FL ~= 0 then
					if FL == 1 then
						FL = 0
					end
					local BackLeft = Model.Body:FindFirstChild("BackL")
					local BackRight = Model.Body:FindFirstChild("BackR")

					if BackLeft and BackRight then
						BackLeft.AngularVelocity = -FL ; BackRight.AngularVelocity = -FL
					end
				end
			end
		end
		LastUpdatedRot = CurrentRot
		old_FL = FL
	end
end)

UIS.InputBegan:Connect(function(inp, pr)
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		if inp.KeyCode == Enum.KeyCode.A then
			spawn(function()
				while UIS:IsKeyDown(Enum.KeyCode.A) do
					RunService.RenderStepped:Wait()
					CurrentTankRot = CurrentTankRot+2
					CurrentRot = math.clamp(CurrentRot+2, -90, 90)
				end
			end)
		else if inp.KeyCode == Enum.KeyCode.D then 
				spawn(function()
					while UIS:IsKeyDown(Enum.KeyCode.D) do
						RunService.RenderStepped:Wait()
						CurrentTankRot = CurrentTankRot-2
						CurrentRot = math.clamp(CurrentRot-2, -90, 90)
					end
				end)
			else if inp.KeyCode == Enum.KeyCode.W then
					FL = 1000
				else if inp.KeyCode == Enum.KeyCode.S then
						if CurrentTank then
							TweenService:Create(CurrentTank.TailLights, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 0, 4)}):Play()
						end
						FL = -1000
					else if inp.KeyCode == Enum.KeyCode.Space then
							if CurrentTank then
							if shootCooldown == true then
								shootCooldown = false
									if CurrentTank:FindFirstChild("ShootPart") then
										FireTank(CurrentTank)
										local tankShootPart = CurrentTank:FindFirstChild("ShootPart")
										local ShapecastParams = RaycastParams.new()
										ShapecastParams.FilterType = Enum.RaycastFilterType.Exclude
										ShapecastParams.FilterDescendantsInstances = CurrentTank:GetChildren()

										local ShapecastResult = workspace:Spherecast(CurrentTank:FindFirstChild("ShootPart").Position,
											2, tankShootPart.CFrame.LookVector * 1000, ShapecastParams)

										if ShapecastResult then
											TankServer:Shoot({ShapecastResult.Instance,tankShootPart.Position,ShapecastResult.Position, ShapecastResult.Normal,tankShootPart.CFrame.LookVector}):andThen(function(result)
												if result then
												end
											end)
										end

										spawn(function()
											task.wait(2)
											shootCooldown = true
										end)

									end
								end
							end
						end
					end
				end
			end
		end
	end
end)

Mouse.Move:Connect(function()
	if CurrentTank then
		if CurrentTank:FindFirstChild("Top") then
			local newCF = CFrame.lookAt(CurrentTank.Top.Attachment1.WorldPosition, Mouse.Hit.Position)
			local newerCF = newCF * CFrame.Angles(math.rad(90),math.rad(90),math.rad(-newCF.Rotation.Z))
			local X,Y,Z = newCF:ToOrientation()
			TweenService:Create(CurrentTank:FindFirstChild("Top").AlignOrientation, 
				TweenInfo.new(0.3, Enum.EasingStyle.Linear), 
				{CFrame = CFrame.fromOrientation(0,Y-15.7,math.rad(90))}):Play()
		end
	end
end)

UIS.InputEnded:Connect(function(inp, pr)
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		if inp.KeyCode == Enum.KeyCode.W then
			FL = 1
		else if inp.KeyCode == Enum.KeyCode.S then 
				FL = 1
				if CurrentTank then
					TweenService:Create(CurrentTank.TailLights, TweenInfo.new(0.2), {Color = Color3.fromRGB(17, 17, 17)}):Play()
				end
			end
		end
	end
end)
