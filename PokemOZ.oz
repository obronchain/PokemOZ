functor
import
   System
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   Browser
export
   Init
   Browse
   Player
   PokemonPlayer
   Map
   PokemozBehaviour
   MapObject
   NewPortObject
   Trainers
   CreateGrassGood
   CreateGrassBad
   C
   ImageWidth
define
   ImageWidth=60
   GrassGood = {QTk.newImage photo(url:'Images/grassgood.gif' height:0 width:0)}
   GrassBad = {QTk.newImage photo(url:'Images/grassbad.gif' height:0 width:0)}
   SachaLeft = {QTk.newImage photo(url:'Images/sachaleft.gif' height:0 width:0)}
   C %canvas
   proc{CreateGrassGood X Y}
      {C create(image (X-1)*ImageWidth (Y-1)*ImageWidth anchor:nw image:GrassGood)}
   end
   proc{CreateGrassBad X Y}
      {C create(image (X-1)*ImageWidth (Y-1)*ImageWidth anchor:nw image:GrassBad)}
   end
   
   proc{CreatePerso Dir X Y}
      {Browse 'inCreatePerso'}
      {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:SachaLeft)}
   end
   MapObject
   MapBehaviour
   Speed
   IsFreePositionFor
   NewPortObject
   PokemozBehaviour
   Map
   Fight
   TrainerBehaviour
   Trainers
   Player
   PokemonPlayer
   Browse
   Init
   LevelList
   GenerateRandomPokemon
   PokemonNameList
   MoveTrainersMap
in
   
   fun{MapBehaviour Msg State}
      % mapObject( map:Map canvas:Canvas)
      case Msg of
	 refresh(trainer:Trainer dir:Dir oldX:OldX oldY:OldY) then
	 local StateTrainer in {Send Trainer getState(StateTrainer)}
	    if Map.OldY.OldX==0 then {CreateGrassGood OldX OldY}
	    else {CreateGrassBad OldX OldY} end
	    {CreatePerso Dir StateTrainer.positionX StateTrainer.positionY}
	 end
      end
      State
   end
   Speed = 0
   Browse = Browser.browse
   Map = column(line(1 1 0 0 0 0 0)
		line(1 1 0 0 0 0 0)
		line(0 0 0 0 0 0 0)
		line(0 0 0 0 0 0 0)
		line(0 0 0 0 0 0 0)
		line(0 0 0 0 0 0 0)
		line(0 0 0 0 0 0 0)
	       )
   LevelList = level(
		  n(lx:5 hp:20 xp:0)
		  n(lx:6 hp:22 xp:5)
		  n(lx:7 hp:24 xp:12)
		  n(lx:8 hp:26 xp:20)
		  n(lx:9 hp:28 xp:30)
		  n(lx:10 hp:30 xp:50))
   PokemonNameList = pokemonname(n(name:carapuce type:water)
				 n(name:bulbizare type:grass)
				 n(name:salameche type:fire)
				)
   fun{IsFreePositionFor Trainer L PosiX PosiY}
      case L of nil then true
      [] H|T then local State in
		     if( H==Trainer) then {IsFreePositionFor Trainer T PosiX PosiY}
		     else
			{Send H getState(State)}
			if{And State.positionX==PosiX State.positionY==PosiY} then false
			else {IsFreePositionFor Trainer T PosiX PosiY} end
		     end
		  end
      end
   end

   fun{GenerateRandomPokemon}
      local Pokemon InitialValue = pokemon(name:_ type:_ lx:_ hp:_ xp:_) Level State Loop Random in
	 {Send PokemonPlayer getState(State)}
	 Level = State.lx + ({OS.rand} mod 3) - 1
	 Random = ({OS.rand} mod 3) + 1
	 proc{Loop N}
	    if {Or Level<5 {Or Level==LevelList.N.lx Level>10}} then
	       InitialValue.lx = LevelList.N.lx
	       InitialValue.hp = LevelList.N.hp
	       InitialValue.xp = LevelList.N.xp
	    else
	       {Loop N+1}
	    end
	 end
	 {Loop 1}
	 InitialValue.name = PokemonNameList.Random.name
	 InitialValue.type = PokemonNameList.Random.type
	 {NewPortObject PokemozBehaviour InitialValue}
      end
   end
%pokemon(name type lx hp xp)
%trainer(name positionX positionY pokemon)
%Map contient la carte
%Fight fonction qui simule un combat entre 2 pokemon
%Trainers La liste des entraineurs enemis sur le terrain (Des Ports object et pas des tuples)

%PokemozBehaviour (getState(X) watchEndOfFight(Enemy) injure(X))
%TrainerBehaviour (move(dir:Dir boolean:Boolean enemy:Enemy) getState(X) fight(Enemy)) Dir = 'up' ou 'down' ou 'left ou 'right' Boolean indique si enemy
%       fight peut se faire battre un trainer avec un autre trainer ou un autre pokemon
   
%Le classe PortObject
%On rajoute dans les trainers l'etat busy. cet etat permet de voir si il est occupe et ou si non. busy si est en combat. 
   proc{Init}
      {Browse 'init'}
      local  EnemyPokemon Loop in
	 PokemonPlayer = {NewPortObject PokemozBehaviour pokemon(name:mapute type:grass hp:20 lx:5 xp:0)}
	 Player = {NewPortObject TrainerBehaviour trainer(name:sacha pokemon:PokemonPlayer positionX:0 positionY:0 busy:false)}
	 Trainers = [Player {NewPortObject TrainerBehaviour trainer(name:enemy pokemon:{GenerateRandomPokemon} positionX:3 positionY:3 busy:false)}]
	 proc{Loop L}
	    case L of nil then skip
	    []H|T then if (H==Player) then {Loop T}
		       else thread {MoveTrainersMap H} end {Loop T}
		       end
	    end
	 end
	 {Loop Trainers}
	 MapObject = {NewPortObject MapBehaviour map(trainers:Trainers)}
      end
   end
     
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
      []cure(X) then local
			NewHp
			proc{Loop N}
			   if LevelList.N.lx==State.lx then NewHp = LevelList.N.hp
			   else {Loop+1} end 
			end
		     in
			{Loop 1}
			pokemon(name:State.name type:State.type xp:State.xp hp:NewHp lx:State.lx)
		     end
      %Permet de mettre les valeurs des hp level des pokemoz apres un combat
      []watchEndOfFight(Enemy) then local 
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
	 []setBusy(S) then {Browse  'setBusy'} {Browse S} trainer(name:State.name pokemon:State.pokemon positionX:State.positionX positionY:State.positionY busy:S)
      []move(dir:Dir boolean:Boolean enemy:Enemy trainer:ThisTrainer ) then %Enemy est soit un portObject trainer soit un tuple pokemon
	 if State.busy then Boolean=false State
	 else  local NewX NewY in
		  {Browse 'matchMove'}
	 %trouver la nouvelle position
		  case Dir of
		     'up' then if(State.positionY-1 < 0) then NewY = State.positionY NewX = State.positionX
			       else NewY = State.positionY-1 NewX = State.positionX end
		  []'down' then if(State.positionY+1 > 6) then NewY = State.positionY NewX = State.positionX
				else NewY = State.positionY+1 NewX = State.positionX end
		  []'left' then if(State.positionX-1<0) then NewX = State.positionX NewY = State.positionY
				else NewX = State.positionX-1 NewY = State.positionY end
		  []'right' then if(State.positionX+1 >6) then NewX = State.positionX NewY = State.positionY
				 else NewX = State.positionX+1 NewY = State.positionY end
		  end	    
	 %voir si il y a eut changement de position
		  if {And NewX==0 NewY==0} then {Send State.pokemon cure(_)}  Boolean = false trainer(name:State.name pokemon:State.pokemon positionX:NewX positionY:NewY busy:false )
		  elseif {Or {And State.positionY==NewY State.positionX==NewX} {Bool.'not' {IsFreePositionFor ThisTrainer Trainers NewX NewY}}} then Boolean=false State
		  elseif {Bool.'not' ThisTrainer==Player} then Boolean=false train(name:State.name pokemon:State.pokemon positionX:NewX positionY:NewY busy:false)
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
			   []H|T then
			      local State in
				 if H==ThisTrainer then {FindIfTrainer PP T}
				 else 
				    {Send H getState(State)}
				    if{FindIfIn State.positionX State.positionY PP} then is(boolean:true trainer:H)
				    else {FindIfTrainer PP T} end
				 end
			      end
			   end
			end
			
			Result={FindIfTrainer ['#'(x:NewX+1 y:NewY) '#'(x:NewX-1 y:NewY) '#'(x:NewX y:NewY+1) '#'(x:NewX y:NewY-1)] Trainers}
			if(Result.boolean) then Boolean = true
			   {Send Result.trainer setBusy(true)} Enemy=Result.trainer trainer(name:State.name positionX:NewX
											    positionY:NewY pokemon:State.pokemon busy:true) % il y a un trainer a cote
			elseif{And (({OS.rand} mod 100) < 30) Map.(NewY+1).(NewX+1)==1} then  Boolean = true Enemy = {GenerateRandomPokemon}
			   trainer(name:State.name positionX:NewX
				   positionY:NewY pokemon:State.pokemon busy:true)
			else Boolean = false  trainer(name:State.name positionX:NewX
						      positionY:NewY pokemon:State.pokemon busy:false)end %rien du tout 
		     end
		  end
	       end
	 end
      []fight(EnemyObject) then
	 local Enemy in
	    {Send EnemyObject getState(Enemy)}
	    case Enemy of trainer(name:Name pokemon:PokemonEnemy positionX:X positionY:Y busy:Busy) then local Winner in Winner = {Fight State.pokemon PokemonEnemy} end  State
	    [] pokemon(name:Name type:Type lx:Lx xp:Xp hp:Hp) then	  
	       local Winner = {Fight State.pokemon EnemyObject} in  State end      
	    end
	 end
      end   
   end
   
%permet d'envoyer des moveTrainer(ObjectTrainer) à la carte
   proc{MoveTrainersMap Trainer}
      local
	 NewList     
	 proc{Loop}
	    {Delay (10-Speed)*200}
	    local Move = move(dir:_ boolean:_ enemy:_ trainer:Trainer ) Random State in
	       Random  = ({OS.rand} mod 100 )
	       if Random < 25 then Move.dir = 'up'
	       elseif Random <50 then Move.dir = 'right'
	       elseif Random <75 then Move.dir = 'down'
	       else Move.dir = 'left'
	       end
	       {Send Trainer Move}
	       if Move.boolean then Move.free=false
	       else skip end
	       {Send Trainer getState(State)}
	       {Browse State}
	       {Loop}
	    end
	 end
      in
	 {Loop}     
      end
   end
end
