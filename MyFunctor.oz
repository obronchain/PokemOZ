functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   System
define
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

   fun{WantToFight}
      local
	 Ret
	 Desc
      in
	 Desc = td(button(text:"WantToFight" action:proc{$} Ret = true end)
		   button(text:"DoNotFight" action:proc{$} Ret = false end)
		   button(text:"Close" action:toplevel#close)
		  )
	 {{QTk.build Desc} show}
	 Ret
      end
   end
   
   proc{HandelFight Move}
      local EnemyObject Enemy WaitVal
      in
	 EnemyObject = Move.enemy
	 {Send EnemyObject getState(Enemy)}
	 case Enemy of
	    pokemon(name:Name type:Type lx:Lx hp:Hp xp:Xp) then
	    local
	       Desc
	    in 
	       Desc = td( label(text:"you find a wild pokemon")
			  button(text:"show enemy's pokemon" action:proc{$}{ShowPokemon EnemyObject "wild Pokemon"} end)
			  button(text:"Fight" action:proc{$} {Send Player fight(EnemyObject)} WaitVal=unit end)
			  button(text:"Run" action:proc{$} WaitVal=unit end)
			)
	       {{QTk.build Desc} show}
	       {Wait WaitVal}
	       {Send Player setBusy(false)}
	    end
	 []trainer(name:Name pokemon:Pokemon positionX:PosX positionY:PosY busy:Busy) then
	    local
	       Desc = td( label(text:"you find another trainer")
			  button(text:"ShowEnemyPokemon" action:proc{$} {ShowPokemon Pokemon "enemy s pokemon"} end)
			  button(text:"BeginFight" action:proc{$} {Send Player fight(EnemyObject)} WaitVal=unit end)
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
      
   proc{HandelMove Dir}
      local
	 Move=move(dir:Dir enemy:_ boolean:_ trainer:Player) State
      in
	 {Send MoveBuffer moveBuffer(trainer:Player moveCommand:Move)}
	 {Browse Move.boolean}
	 if Move.boolean then
	    thread {HandelFight Move} end
	 else
	    skip
	 end
	 {Send Player getState(State)}
	 {Browse State}
      end
   end
   
   proc{MovingButton Dir}
      local StateTrainer in
	 {Send Player getState(StateTrainer)}
	 {HandelMove Dir}
	 {Send MapObject refresh(trainer:Player dir:Dir oldX:StateTrainer.positionX oldY:StateTrainer.positionY)}
      end
   end
in
   {Init}
   {ShowMap}
end
