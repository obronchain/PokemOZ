functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   OS
   System
   Atom

define
   GrassGood = PokemOZ.grassGood
   HandelFight = PokemOZ.handelFight
   Player = PokemOZ.player
   Speed = PokemOZ.speed
   Browse = PokemOZ.browse
   Trainers = PokemOZ.trainers
   MoveBuffer = PokemOZ.moveBuffer
   PokemonPlayer = PokemOZ.pokemonPlayer
   Fight = PokemOZ.fight
   ShowPokemon = PokemOZ.showPokemon
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
   ShowImage = PokemOZ.showImage
   AutoFightHandler = PokemOZ.autoFightHandler
   AutoFight = PokemOZ.autoFight

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
	 if AutoFight==false then
	    {Window bind(event:"<Up>" action:proc{$} {MovingButton 'up'} end)}
	    {Window bind(event:"<Down>" action:proc{$} {MovingButton 'down'} end)}
	    {Window bind(event:"<Left>" action:proc{$} {MovingButton 'left'} end)}
	    {Window bind(event:"<Right>" action:proc{$} {MovingButton 'right'} end)}
	 else skip end
	 
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


   % gerer les mouvements des perso dans le programme.
   % il y a un buffer qui permet que une seule personne a la fois change sa position
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
      local StateTrainer in
	 {Send Player getState(StateTrainer)}
	 {HandelMove Dir}
	 {Send MapObject refresh(trainer:Player dir:Dir oldX:StateTrainer.positionX oldY:StateTrainer.positionY)}
      end
   end
in
   proc{AutoFightHandler X Y}
      local State StatePokemon NewX NewY in
	 {Send Player getState(State)}
	 {Send PokemonPlayer getState(StatePokemon)}
	 
	 if StatePokemon.hp==0 then NewX=0 NewY=0 
	 elseif {And State.positionX==X State.positionY==Y} then NewX= ({OS.rand} mod 7) NewY=({OS.rand} mod 7)
	 else NewX=X NewY=Y  end
	 {Delay (10-Speed)*200}
	 {Browse X}
	 {Browse Y}

	 
	 if State.positionX < NewX then {HandelMove 'right'} {Send MapObject refresh(trainer:Player dir:'right' oldX:State.positionX oldY:State.positionY)}
	 elseif State.positionX > NewX then {HandelMove 'left'} {Send MapObject refresh(trainer:Player dir:'left' oldX:State.positionX oldY:State.positionY)} 
	 elseif State.positionY < NewY then {HandelMove 'down'} {Send MapObject refresh(trainer:Player dir:'down' oldX:State.positionX oldY:State.positionY)}
	 else {HandelMove 'up'} {Send MapObject refresh(trainer:Player dir:'up' oldX:State.positionX oldY:State.positionY)} end
	 {AutoFightHandler NewX NewY}
      end
   end
   {Init} %initie toutes les valeurs
   {ShowMap} %montre la carte
end
