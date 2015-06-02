#!/bin/ksh
# Prosta ksiazka adresowa
# by ...
# 2014-01-22

DIR="$HOME/.addressbook"
DATE=$(date -I)

if [[ ! -d $DIR ]]; then
		mkdir -p $DIR
fi

case $1 in
## pomoc
		"")
		echo "
addrbook.sh n - tworzy nowy wpis. 
addrbook.sh v nazwa - pokazuje istniejacy wpis.
addrbook.sh d nazwa - usuwa wpis.
addrbook.sh l - listuje wszystkie wpisy.
addrbook.sh l foo - wylistuje wszytkie wpisy zawierajace \"foo\".
addrbook.sh s bar - wyszukuje \"bar\" we wszystkich wpisach.
"
		exit 0
		;;

## listowanie 
		"l")
		if [[ $2 ]]; then
				ls -1 $DIR| grep $2
		else
				ls -1 $DIR
		fi
		exit 0
		;;

## usuwanie wpisu		
		"d")
		read -p "Czy na pewno chcesz usunac wpis $2? (T/n) " baz
		if [[ $baz = T ]]; then
				rm -f $DIR/$2
		else
				exit
		fi
		exit 0
		;;

## wyswietlenie wpisu
		"v")
		if [[ ! $2 ]]; then
				echo "Podaj wpis, ktory chcesz wyswietlic."
			else
				cat $DIR/$2
		fi
		exit 0
		;;

## search
		"s")
		grep -iw $2 $DIR/*
		exit 0
		;;

## nowy wpis
		"n")
		read -p "Chcesz utworzyc wpis dla firmy czy osoby prywatnej (domylnie osoba)? (firma/osoba) " bar
		## firma
		if [[ $bar = firma ]]; then

			echo "Nazwa firmy: " | read -ps fir
			echo  "Osoba kontaktowa: " | read -ps kont
			echo  "E-mail: " | read email
			echo  "Telefon: " | read tel 
			echo  "Telefon komorkowy: " |read cell
			echo  "Fax: " | read fax
			echo  "Ulica i numer: " | read ul
			echo  "Miasto: " | read mst
			echo  "Kod pocztowy: " | read kp
			echo  "Kraj: " | read kr
			echo  "Dodatkowe informacje: " | read note

				if [[ $2 ]]; then
					foo=$2
				else
					foo=`echo $fir | sed -e 's/\(.*\)/\L\1/' | sed 's/\ //g'`
				fi

				if [[ -f $DIR/$foo ]]; then 
					echo "Plik $DIR/$foo istnieje.
			   		Zmieniam nazwe na $foo.bak i tworze nowy plik"	
					mv $DIR/$foo $DIR/$foo.bak
				fi

			cat << TXT >> $DIR/$foo
-------------------Kontakt--------------------------------
Data dodania: $DATE
----------------------------------------------------------
Nazwa firmy: $fir
Osoba kontaktowa: $kont
E-mail: $email
Telefon: $tel
Telefon komorkowy: $cell
Fax: $fax
Adres: $ul, $kp $mst, $kr
----------------------------------------------------------
Dodatkowe informacje: $notes
----------------------------------------------------------
TXT

## potwierdzenie przed zapisaniem/edycja
			cat $DIR/$foo
			read -p "Czy zmienic? (T/n) " ed
				if [[ $ed = T ]]; then
						vi $DIR/$foo &&	echo "Wpis $foo zostal utworzony."
					else
						echo "Wpis $foo zostal utworzony."
				fi

		## osoba prywatna domyslnie
		else		
			read -p "Imie: " imie
			read -p "Nazwisko: " nazw
			read -p "Pseudonim: " nick
			read -p "Firma: " praca
			read -p "E-mail: " email
			read -p "Telefon: " cell
			read -p "Ulica i nr domu/mieszkania: " ul
			read -p "Miasto: " mst
			read -p "Kod pocztowy: " kp
			read -p "Kraj: " kr
			read -p "Urodziny: " ur
			read -p "Dodatkowe informacje: " notes
	
				if [[ $2 ]]; then
					bar=$2
				else
					bar=`echo $imie$nazwisko | sed -e 's/\(.*\)/\L\1/'`
				fi

				if [[ -f $bar ]]; then 

					echo "Plik $bar istnieje. 
			   		Zmieniam nazwe na $bar.bak i tworze nowy plik"	
					mv $DIR/$bar $DIR/$bar.bak
				fi

			cat << TXT >> $DIR/$bar
-------------------Kontakt--------------------------------
Data dodania: $DATE
----------------------------------------------------------
Imie i Nazwisko: $imie $nazw
Pseudonim: $nick
Firma: $praca
E-mail: $email
Telefon: $cell
Adres: $ul, $kp $mst, $kr
----------------------------------------------------------
Urodziny: $ur
----------------------------------------------------------
Dodatkowe informacje: $notes
----------------------------------------------------------
TXT

## potwierdzenie przed zapisaniem/edycja
			cat $DIR/$bar
			read -p "Czy zmienic? (T/n) " ed
				if [[ $ed = T ]]; then
						vi $DIR/$bar && echo "Plik $DIR/$bar zostal utworzony."
					else
						echo "Plik $DIR/$bar zostal utworzony."
				fi
			fi
				exit 0
				;;
esac
