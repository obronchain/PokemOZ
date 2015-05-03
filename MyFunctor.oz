functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   PokemOZ at 'PokemOZ.ozf'
   OS
   System
   Atom

define
   Player = PokemOZ.player
   Speed = PokemOZ.speed
   PokemonPlayer = PokemOZ.pokemonPlayer
   Init = PokemOZ.init
   MapObject = PokemOZ.mapObject
   AutoFightHandler = PokemOZ.autoFightHandler
   HandelMove = PokemOZ.handelMove
   Height=PokemOZ.height
   Width=PokemOZ.width

in
   proc{AutoFightHandler X Y}
      local State StatePokemon NewX NewY F in
	 {Send Player getState(State)}
	 {Send PokemonPlayer getState(StatePokemon)}

	 %Si pokemon mort, Il va vers le soin, sinon il va dans le coin supérieur droit
	 if StatePokemon.hp==0 then NewX=0 NewY=(Height-1)
	 elseif {And State.positionX==X State.positionY==Y} then NewX= (Width-1) NewY=0
	 else NewX=X NewY=Y  end
	 {Delay (10-Speed)*200}

	 
	 if State.positionX < NewX then {HandelMove 'right'} {Send MapObject refresh(trainer:Player dir:'right' oldX:State.positionX oldY:State.positionY fini:F)}
	 elseif State.positionX > NewX then {HandelMove 'left'} {Send MapObject refresh(trainer:Player dir:'left' oldX:State.positionX oldY:State.positionY fini:F)} 
	 elseif State.positionY < NewY then {HandelMove 'down'} {Send MapObject refresh(trainer:Player dir:'down' oldX:State.positionX oldY:State.positionY fini:F)}
	 else {HandelMove 'up'} {Send MapObject refresh(trainer:Player dir:'up' oldX:State.positionX oldY:State.positionY fini:F)} end
	 {Wait F}
	 {AutoFightHandler NewX NewY}
      end
   end
   {Init} %Lance le jeu
end
