#! 
fileWarning="warning"

if [ -e $fileWarning ]
then
	rm $fileWarning
fi
echo "Please wait. Compiling the PokemOZ project"
ozc -c MapCreator.oz &> $fileWarning 
ozc -c PokemOZ.oz &> $fileWarning
echo "First file compiled. PokemOZ.ozf created"
ozc -c MyFunctor.oz &>> $fileWarning
echo "Second file compiled. MyFunctor.ozf created"
ozengine MyFunctor.ozf
echo "To restart the game, excecute: ozengine MyFunctor.ozf"
