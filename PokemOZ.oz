functor import System OS define  NewPortObject PokemozBehaviour Map Fight TrainerBehaviour Trainers Browse=System.browse  in

%pokemon(name type lx hp xp)
%trainer(name positionX positionY pokemon)
%Map contient la carte
%Fight fonction qui simule un combat entre 2 pokemon
%Trainers La liste des entraineurs enemis sur le terrain (Des Ports object et pas des tuples)

%PokemozBehaviour (getState(X) watchEndOfFight(Enemy) injure(X))
%TrainerBehaviour (move(dir:Dir boolean:Boolean enemy:Enemy) getState(X) fight(Enemy)) Dir = 'up' ou 'down' ou 'left ou 'right' Boolean indique si enemy
%       fight peut se faire battre un trainer avec un autre trainer ou un autre pokemon

%Le classe PortObject
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
				       if N==0 then %trouve la nouvelle valeur des xp
					  local NewXp in
					     if(Enemy.lx > State.lx)then NewXp = State.xp + Enemy.lx - State.lx
					     else NewXp = State.xp + 1 end
					     {NewLevel N+1 NewXp}
					  end
				       elseif N==7 then pokemon(name:State.name type:State.type xp:XP hp:State.hp lx:State.lx) %dans le cas ou aucun increment de niveau est necessaire
				       elseif {And (XP >= LevelList.N.xp) (State.lx < LevelList.N.lx)} then %dans le cas ou il faut changer de niveau
					  pokemon(name:State.name type:State.type xp:XP hp:LevelList.N.hp lx:LevelList.N.lx)
				       else
					  {NewLevel N+1 XP}
				       end
				       
				    end
				 in
				    {NewLevel 0 0}
				 end				    
   end
end

%simule les combats entre les pokemons. Renvoie le pokemon vainceur et modifie les niveaux si besoin
fun{Fight PokemozA PokemozD}
   local Grid = grid( grass:grid(grass:2 fire:1 water:3)
		      fire:grid(grass:3 fire:2 water:1)
		      water:grid(grass:1 fire:3 water:2))
      StateA
      StateD
   in
      {Send PokemozA getState(StateA)}
      {Send PokemozD getState(StateD)}
      if (StateA.hp == 0) then {Send PokemozD watchEndOfFight(StateA)} PokemozD
      elseif (StateD.hp == 0) then {Send PokemozA watchEndOfFight(StateD)} PokemozA
      elseif (({OS.rand} mod 100) > ((6+StateA.lx-StateD.lx)*9)) then {Fight PokemozD PokemozA}
      else
	 {Send PokemozD injure(Grid.(StateA.type).(StateD.type))}
	 {Fight PokemozD PokemozA}
      end
   end
end

fun{TrainerBehaviour Msg State}
   case Msg of
      getState(X) then X = State State
   []move(dir:Dir boolean:Boolean enemy:Enemy) then %Enemy est soit un portObject trainer soit un tuple pokemon 
      local NewX NewY in
	 %trouver la nouvelle position
	 case Dir of
	    'up' then if(State.positionY-1 < 0) then NewY = State.positionY NewX = State.positionX
		      else NewY = State.positionY-1 NewX = State.positonX end
	 []'down' then if(State.positionY+1 > 6) then NewY = State.positionY NewX = State.positionX
		       else NewY = State.positionY+1 NewX = State.positionX end
	 []'left' then if(State.positionX-1<0) then NewX = State.positionX NewY = State.positionY
		       else NewX = State.positionX-1 NewY = State.positionY end
	 []'right' then if(State.positionX+1 >6) then NewX = State.positionX NewY = State.positionY
			else NewX = State.positionX+1 NewY = State.positionY end
	 end

	 %voir si il y a eut changement de position
	 if {And State.positionY==NewY State.positionX==NewX} then Boolean = false State
	 else
	    %definition d'une fonction pour trouver si il y un trainer (retourne un tuple is(boolean trainer))
	    local FindIfTrainer FindIfIn Result in
	       
	       fun{FindIfIn PositionX PositionY L}
		  case L of nil then false
		  []H|T then if{And PositionX==H.x PositionY==H.y} then true
			     else {FindIfIn PositionX PositionY T} end
		  end		
	       end
	       
	       fun{FindIfTrainer PP List} %PP liste des positions possibles et List la liste des trainers
		  case List of nil then is(boolean:false trainer:_)
		  []H|T then if{FindIfIn H.positionX H.positionY PP} then is(boolean:true trainer:H)
			     else {FindIfTrainer PP T} end
		  end
	       end
	       
	       Result={FindIfTrainer ['#'(x:NewX+1 y:NewY) '#'(x:NewX-1 y:NewY) '#'(x:NewX y:NewY+1) '#'(x:NewX y:NewY-1)] Trainers}
	       if(Result.boolean) then Boolean = true Enemy=Result.trainer trainer(name:State.name positionX:NewX
					    positionY:NewY pokemon:State.pokemon) % il y a un trainer a cote
	       elseif(({OS.rand} mod 100) < 30) then  Boolean = true Enemy = pokemon(name:wild type:grass lx:5 xp:5 hp:5)
		  trainer(name:State.name positionX:NewX
					    positionY:NewY pokemon:State.pokemon)

	       else Boolean = false  trainer(name:State.name positionX:NewX
					    positionY:NewY pokemon:State.pokemon)end %rien du tout 
 	    end
	 end
      end
   []fight(Enemy) then
      {Browse 'in fight'}
      case Enemy of trainer(name:Name pokemon:PokemonEnemy positionX:X positionY:Y) then local Winner in Winner = {Fight State.pokemon PokemonEnemy} end  State
      [] pokemon(name:Name type:Type lx:Lx xp:Xp hp:Hp) then
	 local PokemonEnemy={NewPortObject PokemozBehaviour Enemy} Winner in
	    Winner = {Fight State.pokemon PokemonEnemy} State
	 end
      end
   end
end

%preuve du bon fonctionnement 
local
   PokemonA = {NewPortObject PokemozBehaviour pokemon(name:olipokemon type:grass lx:5 xp:0 hp:20)}
   PokemonB = {NewPortObject PokemozBehaviour pokemon(name:enemypokemon type:grass lx:5 xp:0 hp:20)}
   TrainerA = {NewPortObject TrainerBehaviour trainer(positionX:0 positionY:0 name:oli pokemon:PokemonA)}
   ResultMove1 = move(dir:'left' boolean:_ enemy:_)
   ResultMove2 = move(dir:'left' boolean:_ enemy:_)
   State1
   State2
   State3
in
   Trainers = [trainer(positionX:2 positionY:1 name:enemy pokemon:PokemonB)]
   {Send TrainerA ResultMove1}
   {Send TrainerA getState(State1)}
   {Browse ResultMove1}
   {Browse State1}
   {Browse ResultMove2}
   {Send TrainerA ResultMove2}
   {Send TrainerA getState(State2)}
   {Browse State2}

end

end