void() getRidOfTempGoal =
{
	self.enemy = self.oldenemy;
	self.goalentity = self.enemy;
	self.movetarget = self.enemy;
	
	//dprint("Removing temporary goal\n");
	
	remove(self.tempgoal);
	self.tempgoal = world;
}

void() delayedTargetChange =
{
	self.owner.tempgoal = world;
	self.owner.enemy = self.owner.oldenemy;
	self.owner.goalentity = self.owner.enemy;
	self.owner.movetarget = self.owner.enemy;
	
	//dprint("Removing temporary goal\n");
	
	remove(self);
}
void() unsuckFromWaterSurface =
{
	local	entity	tmpgoal;
	local	vector	tmppos;
	
	///	Do things every animation frame
	//dprint("pointcontents: ");
	//dprint(ftos(pointcontents(self.origin + '0 0 8')));
	//dprint("\n");
	
	if( pointcontents(self.origin + '0 0 8') > -3)
	{
		if(!self.tempgoal)
		{
			//dprint("Creating temporary goal\n");
			tmpgoal = spawn();
			tmpgoal.classname = "tmp_goal";
			tmpgoal.health = 1;
			tmpgoal.movetype = MOVETYPE_NONE;
			tmpgoal.solid = SOLID_NOT;
			setorigin (tmpgoal, self.goalentity.origin);
			setsize (tmpgoal, '-4 -4 -4 ', '4 4 4');
			tmpgoal.view_ofs = ' 0 0 16 ';
			tmpgoal.owner = self;
			tmpgoal.think = delayedTargetChange;
			tmpgoal.nextthink = time + 2;
		
			self.tempgoal = tmpgoal;
			self.oldenemy = self.enemy;
			self.enemy = self.tempgoal;
		}
		
		tmppos = self.oldenemy.origin;
		tmppos_z = self.origin_z - self.size_z;
		
		setorigin (self.tempgoal, tmppos);
		self.goalentity = self.tempgoal;
		self.movetarget = self.tempgoal;
	}
}

void(string action, float value) ai_fish_movement=
{
	///////////////////////////////////
	///	Do things every animation frame
	
	unsuckFromWaterSurface();
	
	///////////////////////////////////
	
	if(action == "ai_walk")
	{
		ai_walk(value);
	}
	else if(action == "ai_run")
	{
		ai_run(value);
	}
	else if(action == "ai_pain")
	{
		ai_pain(value);
	}
	else if(action == "ai_charge")
	{
		if(self.enemy.classname != "player")
		{
			getRidOfTempGoal();
		}
		ai_charge(value);
	}
	
}