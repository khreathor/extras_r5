void() getRidOfTempGoal =
{
    if(!self.tempgoal)
        return;

	self.enemy = self.oldenemy;
	self.goalentity = self.enemy;
	self.movetarget = self.enemy;

	remove(self.tempgoal);
	self.tempgoal = world;
}

void() delayedTargetChange =
{
	self.owner.tempgoal = world;
	self.owner.enemy = self.owner.oldenemy;
	self.owner.goalentity = self.owner.enemy;
	self.owner.movetarget = self.owner.enemy;

	remove(self);
}

void() unsuckFromWaterSurface =
{
	local	entity	tmpgoal;
	local	vector	tmppos;
	
	if(range(self.oldenemy) == RANGE_MELEE)
		return;

	if(self.flags & FL_SWIM)
	{
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
				tmpgoal.view_ofs = ' 0 0 4 ';
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
}

void() handleFuncWaterSwimming =
{
    //  Unstuck fishes
    if(!walkmove(0,0) && self.infuncwater)
    {
        dprint("STUCK!!! ");
        self.flags = self.flags - (self.flags & FL_FLY);
        self.flags = self.flags - (self.flags & FL_SWIM);
    }

    //  Reset fly every animation frame
    if(self.flags & FL_FLY)
	{
		self.flags = self.flags - (self.flags & FL_FLY);
		self.flags = self.flags | FL_SWIM;
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
		if(!(self.enemy.flags & FL_CLIENT))
		{
			getRidOfTempGoal();
		}
		ai_charge(value);
	}
}
