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
   Desc = td(button(text:"up"
		    action: proc{$}
			       local State1 State2 Move=move(dir:'up' enemy:_ boolean:_) in
				  {Send Player getState(State2)}
				  {Browse State2}
				  {Send Player Move}
				  if Move.boolean then
				     {Browse 'there is a fight'}
				     {Send Player fight(Move.enemy)}
				     {Browse 'result of fight'}
				     {Send PokemonPlayer getState(State1)}
				     {Browse State1}
				  else
				     {Browse 'no fight'}
				  end
			       end
			    end
		   )
	     button(text:"down"
		    action: proc{$}
			       local State1 State2 Move=move(dir:'down' enemy:_ boolean:_) in
				  {Send Player getState(State2)}
				  {Browse State2}
				  {Send Player Move}
				  if Move.boolean then
				     {Browse 'there is a fight'}
				     {Send Player fight(Move.enemy)}
				     {Browse 'result of fight'}
				     {Send PokemonPlayer getState(State1)}
				     {Browse State1}
				  else
				     {Browse 'no fight'}
				  end
			       end
			    end
		   )
	     button(text:"left"
		    action: proc{$}
			       local State1 State2 Move=move(dir:'left' enemy:_ boolean:_) in
				  {Send Player getState(State2)}
				  {Browse State2}
				  {Send Player Move}
				  if Move.boolean then
				     {Browse 'there is a fight'}
				     {Send Player fight(Move.enemy)}
				     {Browse 'result of fight'}
				     {Send PokemonPlayer getState(State1)}
				     {Browse State1}
				  else
				     {Browse 'no fight'}
				  end
			       end
			    end
		   )button(text:"right"
		    action: proc{$}
			       local State1 State2 Move=move(dir:'right' enemy:_ boolean:_) in
				  {Send Player getState(State2)}
				  {Browse State2}
				  {Send Player Move}
				  if Move.boolean then
				     {Browse 'there is a fight'}
				     {Send Player fight(Move.enemy)}
				     {Browse 'result of fight'}
				     {Send PokemonPlayer getState(State1)}
				     {Browse State1}
				  else
				     {Browse 'no fight'}
				  end
			       end
			    end
		   )
	    )
in
   {Init}
   {{QTk.build Desc} show}
end
