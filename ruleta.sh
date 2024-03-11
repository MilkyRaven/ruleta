#!/bin/bash

#COLORES
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cian=$(tput setaf 6)
reset=$(tput sgr0)

#FUNCIONES
#panel de ayuda
function helpPanel(){
	echo -e "Uso de la ruleta"
	echo -e "m) Dinero con el que se desea jugar"
	echo -e "t) Ténica a utilizar (martingala/inverseLabrouchere)"
	exit 1
}
#jugada de la martingala
function martingala (){
echo -e "${yellow}[◇]${reset}Dinero en tu bolsillo: ${blue}$initial_money${reset}€"
echo -ne "${yellow}[◇]${reset}¿Cuánto dinero quieres apostar? ► " && read initial_bet
echo -ne "${yellow}[◇]${reset}¿A qué deseas apostar? ${yellow}(par/impar)${reset} ► " && read par_impar
echo -e "${yellow}[◇]${reset}Vamos a jugar con una cantidad inicial de ${blue}$initial_bet${reset} a ${blue}$par_impar${reset}." 
echo -e "${yellow}[◔]${reset}${blue}Jugando...${reset}${blue}(˵ •̀ ᴗ - ˵ ) ✧${reset}"

#inicializamos el current money con el initial money, y otras variables necesarias
current_money=$initial_money
current_bet=$initial_bet
highest_money=$initial_money
highest_game=0
total_games=0
bad_games=0

#lógica de las jugadas
while [ $current_money -gt 0 ]; do
	current_money=$((current_money - current_bet))
	#echo "Vas a apostar $current_bet, te queda en el bolsillo $current_money"
	#devuelve el número que ha salido en la actual jugada
	random_number="$(($RANDOM % 37))"
	#echo -e "\n Ha salido el número $random_number"
	#con % podemos saber si el número es par o impar
	num_result=$(($random_number % 2))
	if [ $num_result -eq 0  ]; then
		result="par"
	else
		result="impar"
	fi

	#lógica de win o lose
	if [ "$random_number" = "0" ]; then
		#echo "Ha salido el 0, perdemos. La casa se queda $current_bet. Tu saldo es de $current_money."
		current_bet=$((current_bet * 2))
		#echo "Doblamos la apuesta, ahora la apuesta es de $current_bet"
		#incrementamos mala racha
		let "bad_games+=1"
	elif [ "$result" = "$par_impar" ]; then
		#echo "Ha salido $result, ¡ganas!. Tu apuesta había sido $current_bet, recibes el doble ahora."
		reward=$((current_bet * 2))
		current_money=$((current_money + reward))
		current_bet=$initial_bet
		#echo "Recibes $reward. Tu saldo ahora es de $current_money. Reseteamos la apuesta a la apuesta inicial: $current_bet"
		#reseteamos mala racha
		bad_games=0
		if [ $current_money -gt $highest_money ]; then
			highest_money=$current_money
			highest_game=$total_games
		fi
	else
		#echo "Ha salido $result, has perdido. La casa se queda $current_bet. Tu saldo es de $current_money."
		current_bet=$((current_bet * 2))
		#echo "Doblamos la apuesta, ahora la apuesta es de $current_bet"
		#incrementamos contador de mala racha
		let "bad_games+=1"
	fi
	if [ $current_money -lt $current_bet ]; then
		#echo "No tienes suficiente dinero para continuar apostando. Para seguir con la técnica de la martingala, necesitas apostar $current_bet pero tu saldo es de $current_money."
		break
	fi
	#sleep 1
	let "total_games+=1"
done
echo -e "${blue}¡Listo!${reset} Se acabó la partida. Estos son tus resultados:"
echo -e "Tu saldo final es de ${blue}$current_money${reset}€.\nDe ${blue}$total_games${reset} jugadas, has tenido una mala racha final de ${blue}$bad_games${reset} jugadas."
echo "LLegaste a tener un máximo de ${green}$highest_money${reset}€ en la jugada número ${blue}$highest_game.${reset}"
}

function inverseLabrouchere(){
#declaramos variables generales -> creo que podrían estar fuera de la función, revisar
current_money=$initial_money
declare -a sequence=(1 2 3 4)
length=${#sequence[@]}
last_index=$((length - 1))
echo -e "Dinero inicial: $initial_money"
echo -ne "¿A qué deseas apostar?" && read par_impar
echo -e "Comenzamos con la secuencia [${sequence[@]}]"
initial_bet=$((${sequence[0]} + ${sequence[$last_index]}))
current_bet=$initial_bet
echo -e "Apostamos $initial_bet y nuestra secuencia se queda en [${sequence[@]}]."

tput civis
while [ $current_money -gt 0 ]; do
	length=${#sequence[@]}
	last_index=$((length - 1))
	current_money=$((current_money - current_bet))
	echo "Nuestro dinero para esta ronda, tras la apuesta de $current_bet, es de $current_money"
	random_number=$((RANDOM % 37))
	echo -e "Ha salido el número ${blue}$random_number${reset}"
  	num_result=$(($random_number % 2))
	if [ $num_result -eq 0  ]; then
		result="par"
	else
		result="impar"
	fi

  	if [ $random_number -eq 0 ]; then
echo "Has perdido tu apuesta de $current_bet. Te quedan $current_money."
	if [ ${#sequence[@]} -le 2 ]; then
		echo "Como has perdido, queda 0 elementos en la secuencia, por lo cual reseteamos"
		sequence=(1 2 3 4)
		else
		unset sequence[0]
		#length=${#sequence[@]}
		#last_index=$((length - 1))
		unset sequence[last_index]
	fi
	sequence=(${sequence[@]})
    #current bet debe actualizarse con los extremos del array
    length=${#sequence[@]}
	last_index=$((length - 1))
	current_bet=$((${sequence[0]} + ${sequence[$last_index]}))
    echo "Tras esta ronda, tienes $current_money. La secuencia actual es [${sequence[@]}]"
  elif [ "$result" = "$par_impar" ]; then
    echo "Has ganado"
    reward=$((current_bet * 2))
    sequence+=($current_bet)
    sequence=(${sequence[@]})
    current_money=$((current_money + reward))
    #current bet debe actualizarse con los extremos del array
    length=${#sequence[@]}
	last_index=$((length - 1))
	current_bet=$((${sequence[0]} + ${sequence[$last_index]}))
    echo "Tras esta ronda, tienes $current_money. La secuencia actual es [${sequence[@]}]"
  else
	echo "Has perdido tu apuesta de $current_bet. Te quedan $current_money."
	if [ ${#sequence[@]} -le 2 ]; then
		echo "Solo queda uno o dos elementos en la secuencia, por lo cual reseteamos"
		sequence=(1 2 3 4)
		else
		unset sequence[0]
		#length=${#sequence[@]}
		#last_index=$((length - 1))
		unset sequence[last_index]
	fi
	sequence=(${sequence[@]})
    #current bet debe actualizarse con los extremos del array
    length=${#sequence[@]}
	last_index=$((length - 1))
	current_bet=$((${sequence[0]} + ${sequence[$last_index]}))
    echo "Tras esta ronda, tienes $current_money. La secuencia actual es [${sequence[@]}]"
  fi  
if [ ${#sequence[@]} -eq 1 ]; then
current_bet=${sequence[0]}
fi
if [ $current_bet -gt $current_money  ]; then
echo "No puedes seguir apostando, tu apuesta de $current_bet supera tu cash de $current_money"
break
fi
done
echo "Se acabó el juego"
tput cnorm
}

#definimos los argumentos que acepta nuestro script
while getopts "m:t:h" arg; do
	case $arg in
		m) initial_money=$OPTARG;;
		t) technique=$OPTARG;;
		h) helpPanel;;
	esac
done
#dependiendo de los argumentos pasados, se ejecuta una función u otra
if [ -n "$initial_money" ] && [ -n "$technique" ]; then
	if [ "$technique" == "martingala" ]; then
		martingala
  elif [ "$technique" == "inverseLabrouchere" ]; then
    inverseLabrouchere
  else
		echo -e "La técnica introducida no existe"
		helpPanel
	fi
else
	helpPanel
fi

#UTILITIES
#ctrl+C
function ctrl_c(){
echo -e "\n\n[!] Saliendo...\n"
exit 1
}
#captura cuando pulsamos ctrl+c
trap ctrl_c INT
