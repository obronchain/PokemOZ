declare NewPortObject PokemozBehaviour
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
   []watchEndOfFight(Enemy) then local LevelList = level( n(level:5 hp:20 xp:0)
						      n(level:6 hp:22 xp:5)
						      n(level:7 hp:24 xp:12)
						      n(level:8 hp:26 xp:20)
						      n(level:9 hp:28 xp:30)
						      n(level:10 hp:30 xp:50))
				    Max = 6
				    fun{NewLevel N}
				       if N==7 then
					  local NewXp in
					     if(Enemy.lx > State.lx)then NewXp = State.xp + Enemy.lx - State.lx
					     else NewXp = State.xp + 1 end
					  pokemon(name:State.name type:State.type hp:State.hp
						  lx:State.lx xp:NewXp )
					  end
				       elseif(State.xp >= LevelList.N.xp) then pokemon(name:State.name type:State.type hp:LevelList.N.hp
										       lx:LevelList.N.level xp:State.xp)
				       else
					  {NewLevel N+1}
				       end	  
				    end
				 in
				    {NewLevel 1}
				 end				    
   end
end

