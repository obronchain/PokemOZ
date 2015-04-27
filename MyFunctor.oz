functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   System
define
   GrassGood = PokemOZ.grassGood
   Player = PokemOZ.player
   Browse = PokemOZ.browse
   Trainers = PokemOZ.trainers
   MoveBuffer = PokemOZ.moveBuffer
   PokemonPlayer = PokemOZ.pokemonPlayer
   Init = PokemOZ.init
   Map = PokemOZ.map
   PokemozBehaviour = PokemOZ.pokemozBehaviour
   NewPortObject = PokemOZ.newPortObject
   MapObject = PokemOZ.mapObject
   CreateGrassGood = PokemOZ.createGrassGood
   CreateGrassBad = PokemOZ.createGrassBad
   ImageWidth = PokemOZ.imageWidth
   C = PokemOZ.c

   %permet d'afficher la map et de liver les touches aux bouttons aux actions (MovingButton)
   proc{ShowMap} 
      local
	 Height={Record.width Map $}
	 Width={Record.width Map.1 $} 
	 Desc=canvas(handle:C width:Width*ImageWidth height:Height*ImageWidth)
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
      in
	 Window = {QTk.build td(Desc)}
	 {Window bind(event:"<Up>" action:proc{$} {MovingButton 'up'} end)}
	 {Window bind(event:"<Down>" action:proc{$} {MovingButton 'down'} end)}
	 {Window bind(event:"<Left>" action:proc{$} {MovingButton 'left'} end)}
	 {Window bind(event:"<Right>" action:proc{$} {MovingButton 'right'} end)}
	 {Window show}
	 {CreateCanvas 0 0}
      end
   end
   
   proc{ShowPokemon Pokemon Label}
      local
	 Desc
	 State
      in
	 {Send Pokemon getState(State)}
	 Desc = td(label(text:Label)
		   label(text:"name:")
		   label(text:State.name)
		   label(text:"type:")
		   label(text:State.type)
		   label(text:"level:")
		   label(text:State.lx)
		   label(text:"Hp:")
		   label(text:State.hp)
		   label(text:"Xp:")
		   label(text:State.xp)
		   button(text:"Close" action:toplevel#close)
		  )
	 {{QTk.build Desc} show}
      end
   end

   
   % Permet de gerer l'interface graphique pour les combats. Que ce soit avec un autre entraineur ou un autre pokemon
   proc{HandelFight Move}
      local EnemyObject Enemy WaitVal ImageWidth ImageHeight CanvaHeight CanvaWidth Ca
      in
	 EnemyObject = Move.enemy
	 {Send EnemyObject getState(Enemy)}
	 ImageWidth = 30
	 ImageHeight = 30
	 CanvaWidth = 5
	 CanvaHeight = 5
	 case Enemy of
	    pokemon(name:Name type:Type lx:Lx hp:Hp xp:Xp) then
	    local
	       Desc
	    in 
	      % Desc = td( label(text:"you find a wild pokemon")
	      % button(text:"show enemy's pokemon" action:proc{$}{ShowPokemon EnemyObject "wild Pokemon"} end)
	      %		  button(text:"Fight" action:proc{$} {Send Player fight(EnemyObject)} WaitVal=unit end)
	      %	  button(text:"Run" action:proc{$} WaitVal=unit end)
	      %		)
	       
	       Desc=td(canvas(handle:Ca width:CanvaWidth*ImageWidth height:CanvaHeight*ImageWidth)
		       button(text:"show enemy's pokemon" action:proc{$}{ShowPokemon EnemyObject "wild Pokemon"} end)
		       button(text:"Fight" action:proc{$} {Send Player fight(EnemyObject)} WaitVal=unit end)
		       button(text:"Run" action:proc{$} WaitVal=unit end)
		       )
	       {{QTk.build Desc} show}	 
	       {Ca create(image  (3)*ImageWidth (1)*ImageHeight anchor:nw image:GrassGood)}
	       {Ca create(image  (1)*ImageWidth (3)*ImageHeight anchor:nw image:GrassGood)}

	       {Wait WaitVal}
	       {Send Player setBusy(false)}
	    end
	 []trainer(name:Name pokemon:Pokemon positionX:PosX positionY:PosY busy:Busy) then
	    local
	       Desc = td( label(text:"you find another trainer")
			  button(text:"ShowEnemyPokemon" action:proc{$} {ShowPokemon Pokemon "enemy s pokemon"} end)
			  button(text:"BeginFight" action:proc{$} {Send Player fight(EnemyObject)} WaitVal=unit  end)
			  button(text:"Close" action:toplevel#close)
			)
	    in
	       {{QTk.build Desc} show}  
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
   {ShowMap} %montre la carrte
end
