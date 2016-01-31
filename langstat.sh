#!/bin/bash

#Tester la présence du premier paramètre
if [ -z $1 ]
then
	echo "Merci de spécifier un fichier dictionnaire en premier paramètre"
#Tester l'existence du fichier dictionnaire
elif [ ! -e $1 ]
then
	echo "Le fichier dictionnaire que vous avez spécifié n'existe pas"
else
	#Si le premier paramètre est le seul spécifié, alors afficher les statistiques sur les lettres les plus utilisées
	if [ -z $2 ]
	then
		#Pour chaque caratère de l'alphabet
		for char in {A..Z}
		do
			#Compter le nombre de mot contenant la lettre visée
			charStat=`grep -ic "$char" $1`
			#Stocker le résultat dans un fichier temporaire 
        		echo "$charStat - $char"
		done | sort -nr
	#Si un deuxième argument est spécifié, alors rechercher les anagrammes de ce mot.
	else
		#Compter le nombre de caractère
		charCount=`echo ${#2}`
		#Calculer des variables utiles pour les 
		let "charMin = $charCount+1"
		let "charMax = $charMin+1"
		#Formater le paramètre 2 afin de le comparer plus facilement (Suppression des caratères spéciaux, Mise en minuscule, Tri des lettres)
		sorted1=`echo $2 | iconv -f utf8 -t ascii//TRANSLIT | grep -o . | sort | tr -d "\n \r" | tr "[:upper:]" "[:lower:]"`
		#Exclure les mots qui ne contiennent pas les lettres du paramètre 2
		grep -e '.\{'$charMin'\}' $1 | grep -ve '.\{'$charMax'\}' -e [[:punct:]] > dico.temp
		#Pour chaque lettre composant le paramètre 2
		for outChar in `echo $sorted1 | fold -w 1`
		do
			#Filtrer la recherche sur les mots contenant la lettre visée
			grep -ie "$outChar" dico.temp > dico.buffer
			cp dico.buffer dico.temp
			rm dico.buffer
		done
		#Pour chaque mot du dictionnaire qui comporte le même noombre de lettres (hors tirets)
		while read word
		do
			#Formater les mots de même longueur que le second paramètre
			sorted2=`echo $word | iconv -f utf8 -t ascii//TRANSLIT | grep -o . | sort | tr -d "\n \r" | tr "[:upper:]" "[:lower:]"`
			#S'il y a exactement les mêmes lettres, alors c'est un anagramme de notre paramètre 2.
			if [ $sorted1 == $sorted2 ]
			then
				#Stockage de l'anagramme dans un fichier temporaire
				echo " - $word" >> anag.temp
			fi
		done < dico.temp
		if [ -e anag.temp ]
		then
			#Compter le nombre d'anagrammes trouvés
			anagCount=`wc -l anag.temp | tr -dc "[:digit:]"`
			#Afficher le nombre et la liste des mots possibles avec les lettres du paramètre 2
			if [ $anagCount == 1 ]
			then
				echo "Avec les lettres de $2, il est possible de former 1 mot (d'après le dictionnaire spécifié) :"
			else
				echo "Avec les lettres de $2, il est possible de former $anagCount mots (d'après le dictionnaire spécifié) :"
			fi
			while read anag
			do
				echo $anag
			done < anag.temp
			#Puis effacer les fichiers temporaires
			rm -f anag.temp dico.temp
		else
			echo "Le mot que vous avez entré ne fait pas partie du fichier dictionnaire spécifié"
		fi
	fi
fi
