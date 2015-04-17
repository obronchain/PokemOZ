functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   System
define
   Player = PokemOZ.player
   Browse = PokemOZ.browse
   PokemonPlayer = PokemOZ.pokemonPlayer
   Init = PokemOZ.init
   PokemozBehaviour = PokemOZ.pokemozBehaviour
   NewPortObject = PokemOZ.newPortObject
   
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
   
   proc{HandelFight EnemyObject}
      local Enemy
      in
	 {Send EnemyObject getState(Enemy)}
	 case Enemy of
	    pokemon(name:Name type:Type lx:Lx hp:Hp xp:Xp) then
	    local
	       Ret
	       Desc
	    in 
	       Desc = td( label(text:"you find a wild pokemon")
			  button(text:"show enemy's pokemon" action:proc{$}{ShowPokemon EnemyObject "wildPokemon"} end)
			  button(text:"Fight" action:proc{$} Ret = true end)
			  button(text:"Run" action:proc{$} Ret = false end)
			  button(text:"Close" action:toplevel#close)
			)
	       {{QTk.build Desc} show}
	    
	       if Ret then {Send Player fight(EnemyObject)}
	       else
		  skip
	       end
	    end
	 []trainer(name:Name pokemon:Pokemon positionX:PosX positionY:PosY) then
	    local
	       Desc = td( label(text:"you find another trainer")
			  button(text:"ShowEnemyPokemon" action:proc{$} {ShowPokemon Pokemon "enemy s pokemon"} end)
			  button(text:"BeginFight" action:proc{$} {Send Player fight(EnemyObject)}end)
			  button(text:"Close" action:toplevel#close)
			)
	    in
	       {{QTk.build Desc} show}    
	    end
	 end
      end
   end
      
   proc{HandelMove Dir}
      local
	 State1 State2 Move=move(dir:Dir enemy:_ boolean:_)
      in
	 {Send Player getState(State2)}
	 {Browse State2}
	 {Send Player Move}
	 if Move.boolean then
	    {HandelFight Move.enemy}
	 else
	    skip
	 end
      end
   end
	 
   Desc = td(button(text:"up" action:proc{$}{HandelMove 'up'} end )
	     button(text:"down" action:proc{$}{HandelMove 'down'} end)
	     button(text:"left"  action:proc{$}{HandelMove 'left'}end )
	     button(text:"right" action:proc{$}{HandelMove 'right'}end )
	     button(text:"Show My Pokemon" action:proc{$} {ShowPokemon PokemonPlayer "MyPokemon"} end )
	    )
in
   {Init}
   {{QTk.build Desc} show}
end
