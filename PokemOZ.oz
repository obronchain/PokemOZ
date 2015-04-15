declare NewPortObject PokemozBehaviour Fight
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

%La fonction qui gere le Port 
fun{PokemozBehaviour Msg State}
   case Msg of
      %Cette methode est appelee quand on blesse un pokemoz avec un valeur de X
      injure(X) then local NewHp in
			if State.hp - X < 0 then NewHp=0
			else NewHp = State.hp - X end
			pokemon(name:State.name type:State.type
				hp:NewHp lx:State.lx xp:State.xp)
		     end
      %Lie letat du portObject a X
   []getState(X) then X = State State
      %Permet de mettre les valeurs des hp level des pokemoz apres un combat
   []watchEndOfFight(Enemy) then local LevelList = level(
						      n(lx:5 hp:20 xp:0)
						      n(lx:6 hp:22 xp:5)
						      n(lx:7 hp:24 xp:12)
						      n(lx:8 hp:26 xp:20)
						      n(lx:9 hp:28 xp:30)
						      n(lx:10 hp:30 xp:50))
				    fun{NewLevel N XP}
				       if N==0 then
					  local NewXp in
					     if(Enemy.lx > State.lx)then NewXp = State.xp + Enemy.lx - State.lx
					     else NewXp = State.xp + 1 end
					     {NewLevel N+1 NewXp}
					  end
				       elseif N==7 then pokemon(name:State.name type:State.type xp:XP hp:State.hp lx:State.lx)
				       elseif {And (XP >= LevelList.N.xp) (State.lx < LevelList.N.lx)} then
					  pokemon(name:State.name type:State.type xp:XP hp:LevelList.N.hp lx:LevelList.N.lx)
				       %elseif XP >= LevelList.N.xp then
				       %pokemon(name:State.name type:State
				       else
					  {NewLevel N+1 XP}
				       end
				       
				    end
				 in
				    {NewLevel 0 0}
				 end				    
   end
end


fun{Fight PokemozA PokemozD}
   local Grid = grid( grass:grid(grass:2 fire:1 water:3)
		      fire:grid(grass:3 fire:2 water:1)
		      water:grid(grass:1 fire:3 water:2))
      StateA
      StateD
   in
      {Send PokemozA getState(StateA)}
      {Send PokemozD getState(StateD)}
      
      {Browse 'newTurn'}
      {Browse StateA}
      {Browse StateD}
      
      if (StateA.hp == 0) then {Send PokemozD watchEndOfFight(StateA)} PokemozD
      elseif (StateD.hp == 0) then {Send PokemozA watchEndOfFight(StateD)} PokemozA
      elseif (({OS.rand} mod 100) > ((6+StateA.lx-StateD.lx)*9)) then {Fight PokemozD PokemozA}
      else
	 {Send PokemozD injure(Grid.(StateA.type).(StateD.type))}
	 {Fight PokemozD PokemozA}
      end
   end
end

local
   A = {NewPortObject PokemozBehaviour pokemon(name:oli type:grass lx:5 xp:4 hp:20)}
   B = {NewPortObject PokemozBehaviour pokemon(name:cha type:grass lx:5 xp:4 hp:20)}
   C = {NewPortObject PokemozBehaviour pokemon(name:con type:grass lx:5 xp:0 hp:1)}
   Winner1
   StateWinner1
   Winner2
   StateWinner2
in
   Winner1 = {Fight A B}
   {Send Winner1 getState(StateWinner1)}
   {Browse 'winner1'}
   {Browse StateWinner1}
   Winner2 = {Fight Winner1 C}
   {Send Winner2 getState(StateWinner2)}
   {Browse StateWinner2}
end



	 
	 