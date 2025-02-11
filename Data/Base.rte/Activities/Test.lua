package.loaded.Constants = nil; require("Constants");

-----------------------------------------------------------------------------------------
-- Start Activity
-----------------------------------------------------------------------------------------

function Test:StartActivity()
	print("START! -- Test:StartActivity()!");
	
	for actor in MovableMan.AddedActors do
		if IsADoor(actor) then
			actor.Team = Activity.NOTEAM;
		end
	end

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			-- Check if we already have a brain assigned
			if not self:GetPlayerBrain(player) then
				local foundBrain = MovableMan:GetUnassignedBrain(self:GetTeamOfPlayer(player));
				-- If we can't find an unassigned brain in the scene to give each player, then force to go into editing mode to place one
				if not foundBrain then
					self.ActivityState = Activity.EDITING;
					-- Open all doors so we can do pathfinding through them with the brain placement
					MovableMan:OpenAllDoors(true, Activity.NOTEAM);
					MusicMan:PlayDynamicSong("Generic Ambient Music");
					self:SetLandingZone(Vector(player*SceneMan.SceneWidth/4, 0), player);
				else
					-- Set the found brain to be the selected actor at start
					self:SetPlayerBrain(foundBrain, player);
					self:SwitchToActor(foundBrain, player, self:GetTeamOfPlayer(player));
					self:SetLandingZone(self:GetPlayerBrain(player).Pos, player);
					-- Set the observation target to the brain, so that if/when it dies, the view flies to it in observation mode
					self:SetObservationTarget(self:GetPlayerBrain(player).Pos, player);
				end
			end
		end
	end

	if self:GetFogOfWarEnabled() then
		local fogResolution = 4;
		SceneMan:MakeAllUnseen(Vector(fogResolution, fogResolution), Activity.TEAM_1);
		SceneMan:MakeAllUnseen(Vector(fogResolution, fogResolution), Activity.TEAM_2);

		for x = 0, SceneMan.SceneWidth - 1, fogResolution do
			local altitude = Vector(0, 0);
			SceneMan:CastTerrainPenetrationRay(Vector(x, 0), Vector(0, SceneMan.Scene.Height), altitude, 50, 0);
			if altitude.Y > 1 then
				SceneMan:RevealUnseenBox(x - 10, 0, fogResolution + 20, altitude.Y + 10, Activity.TEAM_1);
				SceneMan:RevealUnseenBox(x - 10, 0, fogResolution + 20, altitude.Y + 10, Activity.TEAM_2);
			end
		end
	end

	local automoverController = CreateActor("Invisible Automover Controller", "Base.rte");
	automoverController.Pos = Vector();
	automoverController.Team = 1;
	MovableMan:AddActor(automoverController);

	self.doorMessageTimer = Timer();
	self.doorMessageTimer:SetSimTimeLimitMS(5000);
	self.allDoorsOpened = false;
end

function Test:OnSave()
	-- Don't have to do anything, just need this to allow saving/loading.
end

-----------------------------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------------------------

function Test:PauseActivity(pause)
	print("PAUSE! -- Test:PauseActivity()!");
end

-----------------------------------------------------------------------------------------
-- End Activity
-----------------------------------------------------------------------------------------

function Test:EndActivity()
	print("END! -- Test:EndActivity()!");
end

-----------------------------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------------------------

function Test:UpdateActivity()
	if self.doorMessageTimer then
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if self:PlayerActive(player) and self:PlayerHuman(player) then
				FrameMan:SetScreenText("NOTE: You can press ALT + 1 to open or close all doors", self:ScreenOfPlayer(player), 0, -1, false);
			end
		end
		if self.doorMessageTimer:IsPastSimTimeLimit() then
			self.doorMessageTimer = nil;
			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				if self:PlayerActive(player) and self:PlayerHuman(player) then
					FrameMan:ClearScreenText(self:ScreenOfPlayer(player));
				end
			end
		end
	end

	if UInputMan.FlagAltState and UInputMan:KeyPressed(Key.K_1) then
		MovableMan:OpenAllDoors(not self.allDoorsOpened, Activity.NOTEAM);
		self.allDoorsOpened = not self.allDoorsOpened;
	end
end
