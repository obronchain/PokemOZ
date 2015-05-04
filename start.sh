#! 
fileWarning=x"warning"

if [ -e $fileWarning ]
then
	rm $fileWarning
fi

echo "please wait. Compiling the PokemOZ project"
ozc -c PokemOZ.oz &> $fileWarning
echo "first file compiled. PokemOZ.ozf created"
ozc -c MyFunctor.oz &> $fileWarning
echo "second file compiled. MyFunctor.ozf created"
ozengine MyFunctor.ozf
echo "to restart the game, excecute: ozengine MyFunctor.ozf"
