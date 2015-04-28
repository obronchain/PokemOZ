functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   System
   Atom
define
   GrassGood = PokemOZ.grassGood
   Player = PokemOZ.player
   Browse = PokemOZ.browse
   Trainers = PokemOZ.trainers
   MoveBuffer = PokemOZ.moveBuffer
   PokemonPlayer = PokemOZ.pokemonPlayer
   Fight = PokemOZ.fight
   Init = PokemOZ.init
   Map = PokemOZ.map
   PokemozBehaviour = PokemOZ.pokemozBehaviour
   NewPortObject = PokemOZ.newPortObject
   MapObject = PokemOZ.mapObject
   CreateGrassGood = PokemOZ.createGrassGood
   CreateGrassBad = PokemOZ.createGrassBad
   ImageWidth = PokemOZ.imageWidth
   GrassBad=PokemOZ.grassBad
   C = PokemOZ.c
   Ca = PokemOZ.ca

   %permet d'afficher la map et de liver les touches aux bouttons aux actions (MovingButton)
   proc{ShowMap} 
      local
	 Height={Record.width Map $}
	 Width={Record.width Map.1 $} 
	 Desc=canvas(handle:C width:Width*ImageWidth height:Height*ImageWidth)
	 Ca
	 proc{CreateCanvas X Y}
	    if X==Width then {CreateCanvas 0 Y+1}
	    else if Y==Height then skip
		 else if Map.(Y+1).(X+1)==0 then {CreateGrassGood X Y} {CreateCanvas X+1 Y}
		      else {CreateGrassBad X Y}  {CreateCanvas X+1 Y}
		      end
		 end
	    end
	 end
	 Window
	 %Statepok
	 %{Send PokemonPlayer getState(Statepok)}
      in
	 Window = {QTk.build td(Desc td(button(text:"Show your pokemon" action:proc{$} {ShowPokemon PokemonPlayer "Your pokemon"} end)
				%	canvas(handle:Ca width:2*ImageWidth height:(Height-3)*ImageWidth)
				%	lr(label(text:"Name :" bg:white) label(text:Statepok.name bg:white)  bg:white)
				%	lr(label(text:"Type : "  bg:white) label(text:Statepok.type  bg:white)  bg:white)
				%	lr(label(text:"Level : "  bg:white) label(text:Statepok.lx  bg:white)  bg:white)
				%	lr(label(text:"Hp : "  bg:white) label(text:Statepok.hp  bg:white)  bg:white)
				%	lr(label(text:"Xp : "  bg:white) label(text:Statepok.xp  bg:white)  bg:white)
				%	bg:white
				       )
			       )
		   }
	 {Window bind(event:"<Up>" action:proc{$} {MovingButton 'up'} end)}
	 {Window bind(event:"<Down>" action:proc{$} {MovingButton 'down'} end)}
	 {Window bind(event:"<Left>" action:proc{$} {MovingButton 'left'} end)}
	 {Window bind(event:"<Right>" action:proc{$} {MovingButton 'right'} end)}
	 {Window show}
	 {CreateCanvas 0 0}	 
	 %{Ca create(image 30 30 anchor:nw image:GrassBad)} %Mettre l'image du pokemon

	 %{Ca create(text 5 90 anchor:nw text:"Name : ")}
	 %{Ca create(text 60 90 anchor:nw text:Statepok.name)}
	 %{Ca create(text 5 105 anchor:nw text:"Type : ")}
	 %{Ca create(text 60 105 anchor:nw text:Statepok.type)}
	 %{Ca create(text 5 120 anchor:nw text:"Level : ")}
	 %{Ca create(text 60 120 anchor:nw text:Statepok.lx)}
	 %{Ca create(text 5 135 anchor:nw text:"Xp : ")}
	 %{Ca create(text 60 135 anchor:nw text:Statepok.xp)}
	 %{Ca create(text 5 150 anchor:nw text:"Hp : ")}
	 %{Ca create(text 60 150 anchor:nw text:Statepok.hp)}
	 %{Ca delete}
	 
	% {Ca create(image 30 90 anchor:nw image:GrassBad)}
      end
   end

   
   proc{ShowPokemon Pokemon Label}
      local
	 Desc
	 State
      in
	 {Send Pokemon getState(State)}
	 Desc = td(label(text:Label bg:white) bg:white
		   lr(label(text:"Name:" bg:white) bg:white label(text:State.name bg:white))
		   lr(label(text:"Type:" bg:white) bg:white label(text:State.type bg:white))
		   lr(label(text:"Level:" bg:white) bg:white label(text:State.lx bg:white))
		   lr(label(text:"Hp:" bg:white)	bg:white label(text:State.hp bg:white))
		   lr(label(text:"Xp:" bg:white) bg:white label(text:State.xp bg:white))
		   lr(button(text:"Close" action:toplevel#close bg:white)  bg:white)
		  )
	 {{QTk.build Desc} show}
      end
   end

   
   % Permet de gerer l'interface graphique pour les combats. Que ce soit avec un autre entraineur ou un autre pokemon
   proc{HandelFight Move}
      local EnemyObject Enemy WaitVal ImageWidth ImageHeight CanvaHeight CanvaWidth Ca StatePokemonPlayer
      in
	 EnemyObject = Move.enemy
	 {Send EnemyObject getState(Enemy)}
	 {Send PokemonPlayer getState(StatePokemonPlayer)}
	 ImageWidth = 60
	 ImageHeight = 60
	 CanvaWidth = 5
	 CanvaHeight = 5
	 {Browse [PokemonPlayer EnemyObject]}
	 case Enemy of
	    pokemon(name:Name type:Type lx:Lx hp:Hp xp:Xp) then
	    local
	       Desc
	       Window
	    in 
	      % Desc = td( label(text:"you find a wild pokemon")
	      % button(text:"show enemy's pokemon" action:proc{$}{ShowPokemon EnemyObject "wild Pokemon"} end)
	      %		  button(text:"Fight" action:proc{$} {Send Player fight(EnemyObject)} WaitVal=unit end)
	      %	  button(text:"Run" action:proc{$} WaitVal=unit end)
	      %		)
	       
	       Desc=td(canvas(handle:Ca width:CanvaWidth*ImageWidth height:CanvaHeight*ImageWidth)
		       button(text:"show enemy's pokemon" action:proc{$}{ShowPokemon EnemyObject "wild Pokemon"} end)
		       button(text:"Fight" action:proc{$} {Browse [PokemonPlayer EnemyObject]}
						          if {Fight PokemonPlayer EnemyObject}==true then {Window close} WaitVal=unit
							  elseif {Fight EnemyObject PokemonPlayer}==true then {Window close} WaitVal=unit
							  else skip
							  end
						  end)
		       button(text:"Run" action:proc{$} {Window close} WaitVal=unit end)
		       )
	       Window= {QTk.build Desc}
	       {Window show}
	       {Ca create(text text:Name  anchor:nw font:white 1 1)}
	       {Ca create(text text:Lx anchor:nw font:white 1 20)}
	       {Ca create(text text:Hp anchor:nw font:white 1 40)}
	       {Ca create(text text:StatePokemonPlayer.name  anchor:nw font:white (4)*ImageWidth (4)*ImageHeight)}
	       {Ca create(text text:StatePokemonPlayer.lx anchor:nw font:white (4)*ImageWidth (4*ImageHeight+20))}
	       {Ca create(text text:StatePokemonPlayer.hp anchor:nw font:white (4)*ImageWidth ((4*ImageHeight)+40))}
	       {Ca create(image  (4)*ImageWidth (0)*ImageHeight anchor:nw image:GrassGood)}
	       {Ca create(image  (0)*ImageWidth (4)*ImageHeight anchor:nw image:GrassGood)}

	       {Wait WaitVal}
	       {Send Player setBusy(false)}
	    end
	 []trainer(name:Name pokemon:Pokemon positionX:PosX positionY:PosY busy:Busy) then
	    local
	       Window
	       Desc = td( label(text:"you find another trainer")
			  button(text:"ShowEnemyPokemon" action:proc{$} {ShowPokemon Pokemon "enemy s pokemon"} end)
			  button(text:"Fight" action:proc{$}
							     if {Fight PokemonPlayer Pokemon} then  {Window close} WaitVal=unit
							     elseif {Fight Pokemon PokemonPlayer} then {Window close} WaitVal=unit
							     else skip
							     end
							  end)
			)
	    in
	       Window={QTk.build Desc}
	       {Window show}
	    end
	    {Wait WaitVal}
	    {Send Move.enemy setBusy(false)}
	    {Send Player setBusy(false)}
	 end
	 {Browse 'EndOfHandelFight'}
      end
   end

   % gerer les mouvements des perso dans le programme.
   % il y a un buffer qui permet que une seule personne a la fois change sa position
   proc{HandelMove Dir}
      local
	 Move=move(dir:Dir enemy:_ boolean:_ trainer:Player) State
      in
	 {Send MoveBuffer moveBuffer(trainer:Player moveCommand:Move)} %on envoie au buffer qu'on veut bouger
	 {Browse Move.boolean}
	 if Move.boolean then
	    thread {HandelFight Move} end %si il y a un combat a faire
	 else
	    skip
	 end
	 {Send Player getState(State)}
	 {Browse State}
      end
   end

   %permet de gerer les input sur les bouttons en gerer les actions du jeu (HandelMove) mais aussi en
   %mettant a jour l'interface graphique (resfresh(...))
   proc{MovingButton Dir}
      local StateTrainer in
	 {Send Player getState(StateTrainer)}
	 {HandelMove Dir}
	 {Send MapObject refresh(trainer:Player dir:Dir oldX:StateTrainer.positionX oldY:StateTrainer.positionY)}
      end
   end
in
   {Init} %initie toutes les valeurs
   {ShowMap} %montre la carte
end
