functor
import
   System
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   Browser
   Pickle
export   
   Player
   Speed 
   PokemonPlayer
   Init
   MapObject
   AutoFightHandler
   HandelMove
   Height
   Width
define
   HandelFightNoAuto
   ImageWidth=60
   HandelFight
   AutoFight
   HandelFightAuto
   ChooseAutoFight
   ShowPokemon
   AutoFightHandler
   Probability
   ShowMap
   MovingButton
   HandelMove
   C
   MoveBuffer
   MapObject
   MapBehaviour
   Speed
   IsFreePositionFor
   NewPortObject
   PokemozBehaviour
   Fight
   TrainerBehaviour
   Trainers
   Player
   PokemonPlayer
   ChoosePokemon
   Init
   GenerateRandomPokemon
   MoveTrainersMap
   ChooseSpeed
   ChooseProbability
   ShowImage
   UpdateLevel
   CreateEnemy
   CreatePlayer
   MoveBufferBehaviour
   CreateGrassGood
   CreateGrassBad
   Browse = Browser.browse
  % Map = {Pickle.load Map.txt}
   Map = column(line(1 1 0 0 1 1 0)
		line(1 1 0 0 0 0 0)
		line(0 0 0 0 1 1 1)
		line(0 0 0 1 1 1 1)
		line(1 0 0 1 1 0 0)
		line(1 0 0 1 1 0 0)
		line(0 0 0 0 0 0 0)
	       )
   
   Height={Record.width Map $}
   Width={Record.width Map.1 $}
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
   
   GrassGood = {QTk.newImage photo(url:'Images/grassgood.gif' height:0 width:0)}
   GrassBad = {QTk.newImage photo(url:'Images/grassbad.gif' height:0 width:0)}
   
   SachaLeft = {QTk.newImage photo(url:'Images/sachaleft.gif' height:0 width:0)}
   SachaDown = {QTk.newImage photo(url:'Images/sachadown.gif' height:0 width:0)}
   SachaRight = {QTk.newImage photo(url:'Images/sacharight.gif' height:0 width:0)}
   SachaUp = {QTk.newImage photo(url:'Images/sachaup.gif' height:0 width:0)}
   
   EnemyLeft = {QTk.newImage photo(url:'Images/enemyleft.gif' height:0 width:0)}
   EnemyDown = {QTk.newImage photo(url:'Images/enemydown.gif' height:0 width:0)}
   EnemyRight = {QTk.newImage photo(url:'Images/enemyright.gif' height:0 width:0)}
   EnemyUp = {QTk.newImage photo(url:'Images/enemyup.gif' height:0 width:0)}
   
   Bulbasoz = {QTk.newImage photo(url:'Images/Bulbasoz.gif' height:0 width:0)}
   Charmandoz = {QTk.newImage photo(url:'Images/Charmandoz.gif' height:0 width:0)}
   Oztirtle = {QTk.newImage photo(url:'Images/Oztirtle.gif' height:0 width:0)}
   
   Soin = {QTk.newImage photo(url:'Images/Soin.gif' height:0 width:0)}
in
   %------------------
   %Gestion de la map
   %------------------
   
     % cree l'image avec de herbes basses
   proc{CreateGrassGood X Y}
      {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:GrassGood)}
   end
   
   % herbes hautes
   proc{CreateGrassBad X Y}
      {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:GrassBad)}
   end
   
   %permet de placer un perso a une position X Y pour qu'il regarde dans la direction Dir
   proc{CreatePlayer Dir X Y Tag}
      {Tag delete}
      case Dir of
	 'up' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:SachaUp tag:Tag)}
      []'down' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:SachaDown tag:Tag)}
      [] 'right' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:SachaRight tag:Tag)}
      [] 'left' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:SachaLeft tag:Tag)}
      end
   end
   
   proc{CreateEnemy Dir X Y Tag}
      {Tag delete}
      case Dir of
	 'up' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:EnemyUp tag:Tag)}
      []'down' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:EnemyDown tag:Tag)}
      [] 'right' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:EnemyRight tag:Tag)}
      [] 'left' then {C create(image (X)*ImageWidth (Y)*ImageWidth anchor:nw image:EnemyLeft tag:Tag)}
      end
   end
   
   % les Behaviour du buffer pour que les entraineurs changent leurs position 1 par 1
   fun{MoveBufferBehaviour Msg State}
      case Msg of moveBuffer(trainer: Trainer moveCommand:Move)
      then {Send Trainer Move} {Wait Move.boolean} State
      end
   end

 % L'objet qui permet de gerer la carte, de la refresh
   fun{MapBehaviour Msg State}
      % mapObject( map:Map canvas:Canvas)
      case Msg of
	 refresh(trainer:Trainer dir:Dir oldX:OldX oldY:OldY fini:F) then
	 local StateTrainer in {Send Trainer getState(StateTrainer)}
	    if StateTrainer.name==sacha then  {CreatePlayer Dir StateTrainer.positionX StateTrainer.positionY StateTrainer.tag}
	    else {CreateEnemy Dir StateTrainer.positionX StateTrainer.positionY StateTrainer.tag}
	    end
	    F = unit
	 end
      end
      State
   end

   % regarde si la position PosiX PosiY est libre pour Trainer en prenant la liste de tous les entrainers L
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


   %Pour voir ce qui se passe quand on bouge
   proc{HandelMove Dir}
      local
	 Move=move(dir:Dir enemy:_ boolean:_ trainer:Player) State
      in
	 {Send MoveBuffer moveBuffer(trainer:Player moveCommand:Move)} %on envoie au buffer qu'on veut bouger
	 if Move.boolean then
	    thread {HandelFight Player Move} end %si il y a un combat a faire
	 else
	    skip
	 end
      end
   end
   
   %permet de gerer les input sur les bouttons en gerer les actions du jeu (HandelMove) mais aussi en
   %mettant a jour l'interface graphique (resfresh(...))
   proc{MovingButton Dir}
      local StateTrainer Fini in
	 {Send Player getState(StateTrainer)}
	 {HandelMove Dir}
	 {Send MapObject refresh(trainer:Player dir:Dir oldX:StateTrainer.positionX oldY:StateTrainer.positionY fini:Fini)}
	 {Wait Fini}
      end
   end

   %Crée la map
   proc{ShowMap} 
      local
	 Desc=canvas(handle:C width:Width*ImageWidth height:Height*ImageWidth)
	 Ca
	 Window
	 proc{CreateCanvas X Y}
	    if X==Width then {CreateCanvas 0 Y+1}
	    else if Y==Height then skip
		 else if Map.(Y+1).(X+1)==0 then {CreateGrassGood X Y} {CreateCanvas X+1 Y}
		      else {CreateGrassBad X Y}  {CreateCanvas X+1 Y}
		      end
		 end
	    end
	 end
      in
	 Window = {QTk.build td(Desc td(button(text:"Show your pokemon" action:proc{$} {ShowPokemon PokemonPlayer "Your pokemon"} end bg:white)
					bg:white )
				bg:white)
		  }
	 if AutoFight==false then
	    {Window bind(event:"<Up>" action:proc{$} {MovingButton 'up'} end)}
	    {Window bind(event:"<Down>" action:proc{$} {MovingButton 'down'} end)}
	    {Window bind(event:"<Left>" action:proc{$} {MovingButton 'left'} end)}
	    {Window bind(event:"<Right>" action:proc{$} {MovingButton 'right'} end)}
	 else skip end
	   
	 {Window show}
	 {CreateCanvas 0 0}	 
	 {C create(image (0)*ImageWidth (6)*ImageWidth anchor:nw image:Soin)}
      end
   end

%permet d'envoyer des moveTrainer(ObjectTrainer) à la carte
   proc{MoveTrainersMap Trainer}
      local
	 NewList     
	 proc{Loop}
	    {Delay (10-Speed)*200}
	    local Move = move(dir:_ boolean:_ enemy:_ trainer:Trainer ) Random State F in
	       Random  = ({OS.rand} mod 100 )
	       {Send Trainer getState(State)}
	       if Random < 25 then Move.dir = 'up'
	       elseif Random <50 then Move.dir = 'right'
	       elseif Random <75 then Move.dir = 'down'
	       else Move.dir = 'left'
	       end
	       {Send MoveBuffer moveBuffer(trainer:Trainer moveCommand:Move)}
	       {Send MapObject refresh(trainer:Trainer dir:Move.dir oldX:State.positionX oldY:State.positionY fini:F)}
	       {Wait F}
	       if Move.boolean then {HandelFight Move.enemy  move(dir:Move.dir boolean:Move.boolean enemy:Trainer trainer:Move.enemy)}
	       else skip end
	       {Loop}
	    end
	 end
      in
	 {Loop}     
      end
   end



   %-----------------------
   %Gestion des paramètres
   %-----------------------

fun{ChoosePokemon}
      local
	 Pokemon
	 Charm
	 Ozt
	 Bulb
	 Window
	 Desc = td(label(text:"Click on the pokemon you want!" bg:white)
		   lr(canvas(handle:Charm height:120 width:120 bg:white)
		      canvas(handle:Ozt height:120 width:120 bg:white)
		      canvas(handle:Bulb height:120 width:120 bg:white)
		     )
		   bg:white
		  )
      in
	 Window= {QTk.build Desc}
	 {Window show}
	 {Charm create(image 10 0 anchor:nw image:Charmandoz)}
	 {Ozt create(image 10 0 anchor:nw image:Oztirtle)}
	 {Bulb create(image 10 0 anchor:nw image:Bulbasoz)}
	 {Charm create(text 0 100 anchor:nw text:"Charmandoz(Fire)")}
	 {Ozt create(text 0 100 anchor:nw text:"Oztirtle(Water)")}
	 {Bulb create(text 0 100 anchor:nw text:"Bulbasoz(Grass)")}
	 {Charm bind(event:"<1>" action:proc{$} Pokemon=1 {Window close} end)}
	 {Ozt bind(event:"<1>" action:proc{$} Pokemon=2 {Window close} end)}
	 {Bulb bind(event:"<1>" action:proc{$} Pokemon=3 {Window close} end)}
	 
	 if Pokemon==1 then {NewPortObject PokemozBehaviour pokemon(name:"Salamèche" type:fire hp:20 lx:5 xp:0)}
	 elseif Pokemon==2 then {NewPortObject PokemozBehaviour pokemon(name:"Carapuce" type:water hp:20 lx:5 xp:0)}
	 else {NewPortObject PokemozBehaviour pokemon(name:"Bulbizarre" type:grass hp:20 lx:5 xp:0)}
	 end
      end
   end


   
   proc{ChooseAutoFight}
      local
	 WaitVal
	 Window
	 Desc = td(td(label(text:"Choose Autofight Options. In Autofight mode, the main trainer tries" bg:white)
		      label(text:"to go to the top right corner of the map." bg:white)		      
		      lr(button( action:proc{$} AutoFight= true {Window close} end text:'AutoFight' bg:white)			 
			 button( action:proc{$} AutoFight= false {Window close} end text:'No AutoFight' bg:white))
		      bg:white))
      in
	 Window= {QTk.build Desc}
	 {Window show}
      end
   end

   proc{ChooseSpeed}
      local
	 Window
	 Desc = td( td(label(text:"Choose the speed of the trainers." bg:white)
		       lr(button( action:proc{$} Speed=0 {Window close} end text:'0' bg:white)
			  button( action:proc{$} Speed=1 {Window close} end text:'1' bg:white)
			  button( action:proc{$} Speed=2  {Window close} end text:'2' bg:white)
			  button( action:proc{$} Speed=3 {Window close}  end text:'3' bg:white)
			  button( action:proc{$} Speed=4 {Window close}  end text:'4' bg:white)
			  button( action:proc{$} Speed=5 {Window close} end text:'5' bg:white)
			  button( action:proc{$} Speed=6 {Window close} end text:'6' bg:white)
			  button( action:proc{$} Speed=7  {Window close} end text:'7' bg:white)
			  button( action:proc{$} Speed=8  {Window close} end text:'8' bg:white)
			  button( action:proc{$} Speed=9 {Window close} end text:'9' bg:white)			    
			  button( action:proc{$} Speed=10 {Window close} end text:'10' bg:white)
			  bg:white)
		       bg:white))
      in
	 Window= {QTk.build Desc}
	 {Window show}
      end
   end

   proc{ChooseProbability}
      local
	 Window
	 Desc = td( td(label(text:"Choose the probability to find a PokemOZ in the bushes." bg:white)
		       lr(button( action:proc{$} Probability= 0 {Window close} end text:'0%' bg:white)
			  button( action:proc{$} Probability= 10 {Window close} end text:'10%' bg:white)
			  button( action:proc{$} Probability= 20 {Window close} end text:'20%' bg:white)
			  button( action:proc{$} Probability= 30 {Window close} end text:'30%' bg:white)
			  button( action:proc{$} Probability= 40 {Window close}  end text:'40%' bg:white)
			  button( action:proc{$} Probability= 50 {Window close} end text:'50%' bg:white)
			  button( action:proc{$} Probability= 60 {Window close} end text:'60%' bg:white)
			  button( action:proc{$} Probability= 70 {Window close} end text:'70%' bg:white)
			  button( action:proc{$} Probability= 80 {Window close} end text:'80%' bg:white)
			  button( action:proc{$} Probability= 90 {Window close} end text:'90%' bg:white)
			  button( action:proc{$} Probability= 100 {Window close} end text:'100%' bg:white)
			  bg:white)
		       bg:white
		      )
		    bg:white
		  )
      in
	 Window= {QTk.build Desc}
	 {Window show}
      end
   end




   

   %-------------------
   %Gestion des combats
   %-------------------

   proc{UpdateLevel X Y Pokemon Canva}
      local PokemonState Lx in {Send Pokemon getState(PokemonState)}
	 Lx = (PokemonState.lx)-4
	 {Canva create(rectangle X Y (X+(LevelList.Lx.hp)*3) (Y+8)  fill:white)}
	 if (LevelList.Lx.hp) < (PokemonState.hp)*2 then {Canva create(rectangle X Y X+(PokemonState.hp*3) Y+8 fill:green)}	    
	 else if (LevelList.Lx.hp) < (PokemonState.hp)*5 then {Canva create(rectangle X Y X+(PokemonState.hp*3) Y+8 fill:yellow)}
	      else {Canva create(rectangle X Y X+(PokemonState.hp*3) Y+8 fill:red)}
	      end
	 end
      end	  
   end

   %Simule les combats entre les pokemons. Renvoie true si D est battu
   fun{Fight PokemozA PokemozD}
      local Grid = grid( grass:grid(grass:2 fire:1 water:3)
			 fire:grid(grass:3 fire:2 water:1)
			 water:grid(grass:1 fire:3 water:2))
	 StateA
	 StateD
      in
	 {Send PokemozA getState(StateA)}
	 {Send PokemozD getState(StateD)}
	 if (({OS.rand} mod 100) > ((6+StateA.lx-StateD.lx)*9)) then false
	 else
	    {Send PokemozD injure(Grid.(StateA.type).(StateD.type))}
	    if (StateD.hp)-(Grid.(StateA.type).(StateD.type))>0 then false
	    else true
	    end 
	 end
      end
   end

    % Permet de gerer l'interface graphique pour les combats, que ce soit avec un autre entraineur ou un autre pokemon, en mode "non-autofight"
   proc{HandelFightNoAuto StartingTrainer Move}
      local EnemyObject Enemy WaitVal ImageWidth ImageHeight CanvaHeight CanvaWidth Ca StatePokemonPlayer PokemonPlayer TrainerState Player
      in
	 Player = StartingTrainer
	 {Send Player getState(TrainerState)}
	 PokemonPlayer = TrainerState.pokemon
	 EnemyObject = Move.enemy
	 {Send EnemyObject getState(Enemy)}
	 {Send PokemonPlayer getState(StatePokemonPlayer)}
	 ImageWidth = 60
	 ImageHeight = 60
	 CanvaWidth = 5
	 CanvaHeight = 5

	 case Enemy of
	    pokemon(name:Name type:Type lx:Lx hp:Hp xp:Xp) then
	    local
	       Desc
	       Window
	       Canvas
	    in 
	       
	       Desc=td(canvas(handle:Canvas width:250 height:250 bg:white)
		       button(text:"Fight" action:proc{$} 
						     if {Fight PokemonPlayer EnemyObject}==true then {Window close}
							{Send PokemonPlayer watchEndOfFight(EnemyObject)} WaitVal=unit
						     elseif {Fight EnemyObject PokemonPlayer}==true then {Window close}
							{Send EnemyObject watchEndOfFight(PokemonPlayer)} WaitVal=unit
						     else skip
						     end
						     {UpdateLevel 30 200 PokemonPlayer Canvas}
						     {UpdateLevel 150 70 EnemyObject Canvas}
						  end
			      bg:white)
		       button(text:"Run" action:proc{$} {Window close} WaitVal=unit end bg:white)
		       bg:white
		      )
	       Window= {QTk.build Desc}
	       {Window show}
	       {Canvas create(text 130 10 text:"Name :"  anchor:nw)}
	       {Canvas create(text 130 25 text:"Level :" anchor:nw )}
	       {Canvas create(text 130 40 text:"Hp :" anchor:nw  )}
	       {Canvas create(text 180 10 text:Enemy.name  anchor:nw)}
	       {Canvas create(text 180 25 text:Enemy.lx anchor:nw )}
	       {Canvas create(text 180 40 text:Enemy.hp anchor:nw )}
	       
	       {Canvas create(text 10 140 text:"Name :"  anchor:nw)}
	       {Canvas create(text 10 155 text:"Level :" anchor:nw )}
	       {Canvas create(text 10 170 text:"Hp :" anchor:nw  )}
	       {Canvas create(text 60 140 text:StatePokemonPlayer.name  anchor:nw)}
	       {Canvas create(text 60 155 text:StatePokemonPlayer.lx anchor:nw )}
	       {Canvas create(text 60 170 text:StatePokemonPlayer.hp anchor:nw )}
	       
	       {Canvas create(image 10 10 anchor:nw image:{ShowImage Enemy.type})}
	       {Canvas create(image 140 140 anchor:nw image:{ShowImage StatePokemonPlayer.type})}
	       {UpdateLevel 30 200 PokemonPlayer Canvas}
	       {UpdateLevel 150 70 EnemyObject Canvas}
	       {Wait WaitVal}
	       {Send Player setBusy(false)}
	    end
	 []trainer(name:Name pokemon:Pokemon positionX:PosX positionY:PosY busy:Busy tag:Tag) then
	    local
	       Window
	       EnemyPokemon
	       Ca
	       Desc = td( label(text:"A fight with another trainer just started!"  bg:white)
			  canvas(handle:Ca height:250 width:250 bg:white)
			  button(text:"ShowEnemyPokemon" action:proc{$} {ShowPokemon Pokemon "Enemy's pokemon"} end  bg:white)
			  button(text:"Fight" action:proc{$}
							if {Fight PokemonPlayer Pokemon} then  {Window close}
							   {Send PokemonPlayer watchEndOfFight(Pokemon)} WaitVal=unit
							elseif {Fight Pokemon PokemonPlayer} then {Window close}
							   {Send Pokemon watchEndOfFight(PokemonPlayer)} WaitVal=unit
							else skip
							end
							{UpdateLevel 30 200 PokemonPlayer Ca}
							{UpdateLevel 150 70 Pokemon Ca}
						     end
				 bg:white
				)
			  bg:white
			)
	    in	       
	       Window={QTk.build Desc}
	       {Window show}
	       {Send Pokemon getState(EnemyPokemon)}
	       {Ca create(text 130 10 text:"Name :"  anchor:nw)}
	       {Ca create(text 130 25 text:"Level :" anchor:nw )}
	       {Ca create(text 130 40 text:"Hp :" anchor:nw  )}
	       {Ca create(text 180 10 text:EnemyPokemon.name  anchor:nw)}
	       {Ca create(text 180 25 text:EnemyPokemon.lx anchor:nw )}
	       {Ca create(text 180 40 text:EnemyPokemon.hp anchor:nw )}
	       
	       {Ca create(text 10 140 text:"Name :"  anchor:nw)}
	       {Ca create(text 10 155 text:"Level :" anchor:nw )}
	       {Ca create(text 10 170 text:"Hp :" anchor:nw  )}
	       {Ca create(text 60 140 text:StatePokemonPlayer.name  anchor:nw)}
	       {Ca create(text 60 155 text:StatePokemonPlayer.lx anchor:nw )}
	       {Ca create(text 60 170 text:StatePokemonPlayer.hp anchor:nw )}
	       {UpdateLevel 30 200 PokemonPlayer Ca}
	       {UpdateLevel 150 70 Pokemon Ca}
	       {Ca create(image 10 10 anchor:nw image:{ShowImage EnemyPokemon.type})}
	       {Ca create(image 140 140 anchor:nw image:{ShowImage StatePokemonPlayer.type})}
	    end
	    {Wait WaitVal}
	    {Send Move.enemy setBusy(false)}
	    {Send Player setBusy(false)}
	 end
      end
   end



   %Grstion des combats en mode AutoFight
   proc{HandelFightAuto StartingTrainer Move}
      local EnemyObject Enemy WaitVal ImageWidth ImageHeight CanvaHeight CanvaWidth Ca StatePokemonPlayer PokemonPlayer TrainerState Player
      in
	 Player = StartingTrainer
	 {Send Player getState(TrainerState)}
	 PokemonPlayer = TrainerState.pokemon
	 EnemyObject = Move.enemy
	 {Send EnemyObject getState(Enemy)}
	 {Send PokemonPlayer getState(StatePokemonPlayer)}
	 ImageWidth = 60
	 ImageHeight = 60
	 CanvaWidth = 5
	 CanvaHeight = 5

	 case Enemy of
	    pokemon(name:Name type:Type lx:Lx hp:Hp xp:Xp) then
	    local
	       Desc
	       Window
	       Canvas
	       ActionFight
	       ActionRun
	       Loop
	    in
	       proc{Loop}
		  {Delay (10-Speed)*200}
		  {UpdateLevel 30 200 PokemonPlayer Canvas}
		  {UpdateLevel 150 70 EnemyObject Canvas}
		  if {ActionFight} then skip
		  else {Loop} end
	       end
	       
	       ActionFight = fun{$}
				if {Fight PokemonPlayer EnemyObject}==true then  {Window close}
				   {Send PokemonPlayer watchEndOfFight(EnemyObject)} WaitVal=unit true
				elseif {Fight EnemyObject PokemonPlayer}==true then  {Window close}
				   {Send EnemyObject watchEndOfFight(PokemonPlayer)} WaitVal=unit true
				else false
				end
			     end
	       ActionRun = proc{$} {Window close} WaitVal=unit end
	       Desc=td(canvas(handle:Canvas width:250 height:250 bg:white)
		       bg:white
		      )
	       Window= {QTk.build Desc}
	       {Window show}
	       {Canvas create(text 130 10 text:"Name :"  anchor:nw)}
	       {Canvas create(text 130 25 text:"Level :" anchor:nw )}
	       {Canvas create(text 130 40 text:"Hp :" anchor:nw  )}
	       {Canvas create(text 180 10 text:Enemy.name  anchor:nw)}
	       {Canvas create(text 180 25 text:Enemy.lx anchor:nw )}
	       {Canvas create(text 180 40 text:Enemy.hp anchor:nw )}
	       
	       {Canvas create(text 10 140 text:"Name :"  anchor:nw)}
	       {Canvas create(text 10 155 text:"Level :" anchor:nw )}
	       {Canvas create(text 10 170 text:"Hp :" anchor:nw  )}
	       {Canvas create(text 60 140 text:StatePokemonPlayer.name  anchor:nw)}
	       {Canvas create(text 60 155 text:StatePokemonPlayer.lx anchor:nw )}
	       {Canvas create(text 60 170 text:StatePokemonPlayer.hp anchor:nw )}
	       
	       {Canvas create(image 10 10 anchor:nw image:{ShowImage Enemy.type})}
	       {Canvas create(image 140 140 anchor:nw image:{ShowImage StatePokemonPlayer.type})}
	       {UpdateLevel 30 200 PokemonPlayer Canvas}
	       {UpdateLevel 150 70 EnemyObject Canvas}

	       {Loop}
	       {Wait WaitVal}
	       {Send Player setBusy(false)}
	    end
	 []trainer(name:Name pokemon:Pokemon positionX:PosX positionY:PosY busy:Busy tag:Tag) then
	    local
	       Window
	       EnemyPokemon
	       Ca
	       proc{Loop}
		  {Delay (10-Speed)*200}
		  {UpdateLevel 30 200 PokemonPlayer Ca}
		  {UpdateLevel 150 70 Pokemon Ca}
		  if {ActionFight} then skip
		  else {Loop} end
	       end
	       ActionFight = fun{$}
				if {Fight PokemonPlayer Pokemon} then  {Window close}
				   {Send PokemonPlayer watchEndOfFight(Pokemon)} WaitVal=unit true
				elseif {Fight Pokemon PokemonPlayer} then {Window close}
				   {Send Pokemon watchEndOfFight(PokemonPlayer)} WaitVal=unit true
				else false
				end
			     end
	       Desc = td( label(text:"A fight with another trainer just started!"  bg:white)
			  canvas(handle:Ca height:250 width:250 bg:white)
			)
	    in	       
	       Window={QTk.build Desc}
	       {Window show}
	       {Send Pokemon getState(EnemyPokemon)}
	       {Ca create(text 130 10 text:"Name :"  anchor:nw)}
	       {Ca create(text 130 25 text:"Level :" anchor:nw )}
	       {Ca create(text 130 40 text:"Hp :" anchor:nw  )}
	       {Ca create(text 180 10 text:EnemyPokemon.name  anchor:nw)}
	       {Ca create(text 180 25 text:EnemyPokemon.lx anchor:nw )}
	       {Ca create(text 180 40 text:EnemyPokemon.hp anchor:nw )}
	       
	       {Ca create(text 10 140 text:"Name :"  anchor:nw)}
	       {Ca create(text 10 155 text:"Level :" anchor:nw )}
	       {Ca create(text 10 170 text:"Hp :" anchor:nw  )}
	       {Ca create(text 60 140 text:StatePokemonPlayer.name  anchor:nw)}
	       {Ca create(text 60 155 text:StatePokemonPlayer.lx anchor:nw )}
	       {Ca create(text 60 170 text:StatePokemonPlayer.hp anchor:nw )}
	       
	       {Ca create(image 10 10 anchor:nw image:{ShowImage EnemyPokemon.type})}
	       {Ca create(image 140 140 anchor:nw image:{ShowImage StatePokemonPlayer.type})}
	       {UpdateLevel 30 200 PokemonPlayer Ca}
	       {UpdateLevel 150 70 Pokemon Ca}
	       {Loop}
	    end
	    {Wait WaitVal}
	    {Send Move.enemy setBusy(false)}
	    {Send Player setBusy(false)}
	 end
      end
   end







   %----------------------
   %Gestion des portObject
   %-----------------------

	 
	 
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



   %--------------------
   %Gestion des pokemon
   %---------------------
   

   %Pour savoir quel image afficher
   fun{ShowImage Type}
      case Type of 'grass' then Bulbasoz
      [] 'fire' then Charmandoz
      [] 'water' then Oztirtle
      end
   end

   %Genere un pokemon random
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


   %Procédure pour l'affichage d'un pokemon et de son état
   proc{ShowPokemon Pokemon Label}
      local
	 Desc
	 State
	 Canvas
      in
	 {Send Pokemon getState(State)}
	 Desc = td(label(text:Label bg:white) bg:white
		   canvas(handle:Canvas height:120 width:120 bg:white)
		   lr(label(text:"Name:" bg:white) bg:white label(text:State.name bg:white))
		   lr(label(text:"Type:" bg:white) bg:white label(text:State.type bg:white))
		   lr(label(text:"Level:" bg:white) bg:white label(text:State.lx bg:white))
		   lr(label(text:"Hp:" bg:white)	bg:white label(text:State.hp bg:white))
		   lr(label(text:"Xp:" bg:white) bg:white label(text:State.xp bg:white))
		   lr(button(text:"Close" action:toplevel#close bg:white)  bg:white)
		  )
	 {{QTk.build Desc} show}
	 {Canvas create(image 10 10 anchor:nw image:{ShowImage State.type})}
      end
   end
  

%La fonction qui gere le Port pour les pokemon
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
      []fight(EnemyObject) then
	 local Enemy in
	    {Send EnemyObject getState(Enemy)}
	    case Enemy of trainer(name:Name pokemon:PokemonEnemy positionX:X positionY:Y busy:Busy tag:Tag) then local Winner in Winner = {Fight State.pokemon PokemonEnemy} end  State
	    [] pokemon(name:Name type:Type lx:Lx xp:Xp hp:Hp) then	  
	       local Winner = {Fight State.pokemon EnemyObject} in  State end      
	    end
	 end
      []getState(X) then X = State State
	 % soigne le pokemon
      []cure(X) then local
			NewHp
			proc{Loop N}
			   if LevelList.N.lx==State.lx then NewHp = LevelList.N.hp
			   else {Loop N+1}  end 
			end
		     in
			{Loop 1}
			pokemon(name:State.name type:State.type xp:State.xp hp:NewHp lx:State.lx)
		     end
      %Permet de mettre les valeurs des hp level des pokemoz apres un combat
      []watchEndOfFight(EnemyObject) then local
					     Enemy				    
					     fun{NewLevel N XP}
						if N==0 then %trouve la nouvelle valeur des xp
						   local NewXp in
						      NewXp = State.xp + Enemy.lx
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
					     {Send EnemyObject getState(Enemy)}
					     {NewLevel 0 0}
					  end				    
      end
   end


   %--------------------
   %Gestion des trainers
   %---------------------


% la fonction pour le port object du trainer
   fun{TrainerBehaviour Msg State}
      case Msg of
	 getState(X) then X = State State
	 %permet de dire qu'il est occupe (qu'il est occupe de combattre , le thread du trainer le fait plus bouger)
      []setBusy(S) then  trainer(name:State.name pokemon:State.pokemon positionX:State.positionX positionY:State.positionY busy:S tag:State.tag)
	 % permet de bouger le traineur. boolean dit est liee a true si il y a un combat. Enemy est alors lie a l'enemy a combattre, false sinon pour boolean 
      []move(dir:Dir boolean:Boolean enemy:Enemy trainer:ThisTrainer ) then %Enemy est soit un portObject trainer soit un tuple pokemon
	 if State.busy then Boolean=false State
	 else  local NewX NewY in
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
		  if {Or {And State.positionY==NewY State.positionX==NewX} {Bool.'not' {IsFreePositionFor ThisTrainer Trainers NewX NewY}}} then Boolean=false State
		  elseif {And NewX==0 NewY==(Height-1)} then {Send State.pokemon cure(_)} Boolean = false trainer(name:State.name pokemon:State.pokemon positionX:NewX positionY:NewY busy:false tag:State.tag)	
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
			      local State PokemonState in
				 if H==ThisTrainer then {FindIfTrainer PP T}
				 else 
				    {Send H getState(State)}
				    {Send State.pokemon getState(PokemonState)}
				    if {And {FindIfIn State.positionX State.positionY PP} {And {Not State.busy} {Not PokemonState.hp==0}}} then if {Or ThisTrainer==Player H==Player} then is(boolean:true trainer:H)
																		else {FindIfTrainer PP T}end
				    else {FindIfTrainer PP T} end
				 end
			      end
			   end
			end
			local ThisPokemonState in {Send State.pokemon getState(ThisPokemonState)}
			   if ThisPokemonState.hp==0 then Boolean=false trainer(name:State.name positionX:NewX positionY:NewY pokemon:State.pokemon busy:false tag:State.tag)
			   else
			      Result={FindIfTrainer ['#'(x:NewX+1 y:NewY) '#'(x:NewX-1 y:NewY) '#'(x:NewX y:NewY+1) '#'(x:NewX y:NewY-1)] Trainers} 
			
			      if(Result.boolean) then Boolean = true
				 {Send Result.trainer setBusy(true)} Enemy=Result.trainer trainer(name:State.name positionX:NewX
												  positionY:NewY pokemon:State.pokemon busy:true tag:State.tag) % il y a un trainer a cote
			      elseif{And (({OS.rand} mod 100) < Probability) {And Map.(NewY+1).(NewX+1)==1 ThisTrainer==Player}} then  Boolean = true Enemy = {GenerateRandomPokemon}
				 trainer(name:State.name positionX:NewX
					 positionY:NewY pokemon:State.pokemon busy:true tag:State.tag)
			      else Boolean = false  trainer(name:State.name positionX:NewX
							    positionY:NewY pokemon:State.pokemon busy:false tag:State.tag)end %rien du tout 
			   end
			end
		     end
		  end
	       end
	 end
      []fight(EnemyObject) then
	 local Enemy in
	    {Send EnemyObject getState(Enemy)}
	    case Enemy of trainer(name:Name pokemon:PokemonEnemy positionX:X positionY:Y busy:Busy tag:Tag) then local Winner in Winner = {Fight State.pokemon PokemonEnemy} end  State
	    [] pokemon(name:Name type:Type lx:Lx xp:Xp hp:Hp) then	  
	       local Winner = {Fight State.pokemon EnemyObject} in  State end      
	    end
	 end
      end   
   end
     


   %----------------
   %Lancement du jeu
   %-----------------
         
   %Prend les parapètres, Affiche la carte et lance le jeu
   proc{Init}
      local PlayerTag TrainerTag1 TrainerTag2  EnemyPokemon Loop Loop2 in
	       
	 {ChooseAutoFight}	       
	 {Wait AutoFight}
	 {ChooseSpeed}
	 {Wait Speed}
	 {ChooseProbability} 
	 {Wait Probability}
	 PokemonPlayer = {ChoosePokemon}
	 {Wait PokemonPlayer}
	       
	 {ShowMap}
	 {Wait C}
	       
	 PlayerTag = {C newTag($)}
	 TrainerTag1= {C newTag($)}
	 TrainerTag2= {C newTag($)}
	       
	 Player = {NewPortObject TrainerBehaviour trainer(name:sacha pokemon:PokemonPlayer positionX:(Height-1) positionY:(Width-1) busy:false tag:PlayerTag)}
	 Trainers = [Player {NewPortObject TrainerBehaviour trainer(name:enemy pokemon:{GenerateRandomPokemon} positionX:5 positionY:5 busy:false tag:TrainerTag1)}
		     {NewPortObject TrainerBehaviour trainer(name:enemy pokemon:{GenerateRandomPokemon} positionX:3 positionY:3 busy:false tag:TrainerTag2)}
		    ]
	       
	 proc{Loop L}
	    case L of nil then skip
	    []H|T then if (H==Player) then local State in
					      {Send H getState(State)}
					      {CreatePlayer 'down' State.positionX State.positionY  State.tag}
					   end
			  {Loop T}
		       else local StateEnemy in
			       {Send H getState(StateEnemy)}
			       {CreateEnemy 'down' StateEnemy.positionX StateEnemy.positionY StateEnemy.tag}
			       thread {MoveTrainersMap H}  end {Loop T}
			    end
		       end
	    end
	 end
	 if AutoFight then thread {AutoFightHandler ({OS.rand} mod 7) ({OS.rand} mod 7)} end HandelFight = HandelFightAuto
	 else HandelFight = HandelFightNoAuto end
	 {Loop Trainers}
	 MapObject = {NewPortObject MapBehaviour map(trainers:Trainers)}
	 MoveBuffer = {NewPortObject MoveBufferBehaviour move(_)}
      end
   end
   
end
