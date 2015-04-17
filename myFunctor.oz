functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   System
define
   Player = PokemOZ.player
   Browse = PokemOZ.browse
   Init = PokemOZ.init
   Desc = td(button(text:"down"
		    action: proc{$}
			       local State1 Move=move(dir:'down' enemy:_ boolean:_) in
				  {Send Player Move}
				  {Send Player getState(State1)}
				  {Browse State1}
				  {Browse Move}
				  skip
			       end
			    end
		   )
	    )
in
   {Init}
   {{QTk.build Desc} show}
end
