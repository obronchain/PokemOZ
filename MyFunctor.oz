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
   HandelMove = PokemOZ.handelMove
   MovingButton = PokemOZ.movingButton
   Height=PokemOZ.height

   %permet d'afficher la map et de liver les touches aux bouttons aux actions (MovingButton)
   


in
   proc{AutoFightHandler X Y}
      local State StatePokemon NewX NewY F in
	 {Send Player getState(State)}
	 {Send PokemonPlayer getState(StatePokemon)}
	 
	 if StatePokemon.hp==0 then NewX=0 NewY=(Height-1) 
	 elseif {And State.positionX==X State.positionY==Y} then NewX= ({OS.rand} mod 7) NewY=({OS.rand} mod 7)
	 else NewX=X NewY=Y  end
	 {Delay (10-Speed)*200}
	 %{Browse X}
	 %{Browse Y}

	 
	 if State.positionX < NewX then {HandelMove 'right'} {Send MapObject refresh(trainer:Player dir:'right' oldX:State.positionX oldY:State.positionY fini:F)}
	 elseif State.positionX > NewX then {HandelMove 'left'} {Send MapObject refresh(trainer:Player dir:'left' oldX:State.positionX oldY:State.positionY fini:F)} 
	 elseif State.positionY < NewY then {HandelMove 'down'} {Send MapObject refresh(trainer:Player dir:'down' oldX:State.positionX oldY:State.positionY fini:F)}
	 else {HandelMove 'up'} {Send MapObject refresh(trainer:Player dir:'up' oldX:State.positionX oldY:State.positionY fini:F)} end
	 {Wait F}
	 {AutoFightHandler NewX NewY}
      end
   end
   {Init} %initie toutes les valeurs
   %{ShowMap} %montre la carte
end
