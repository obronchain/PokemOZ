functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   System
define
   Show = System.show
   Desc = td(button(text:"Browse"
		    action: proc{$}
			       {Show "Ok Browse"}
			    end
		   )
	    )
in
   {{QTk.build Desc} show}
end
