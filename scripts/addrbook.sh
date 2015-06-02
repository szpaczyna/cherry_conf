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
		echo "addrbook.sh n - tworzy nowy wpis. 
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
				ls -1 $DIR | grep $2
		else
				ls -1 $DIR
		fi
		exit 0
		;;

## usuwanie wpisu		
		"d")
		print "Czy na pewno chcesz usunac wpis $2? (T/n) "
	   	read baz
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
		print "Chcesz utworzyc wpis dla firmy czy osoby prywatnej (domylnie osoba)? (firma/osoba) "
	   	read bar
		## firma
		if [[ $bar = firma ]]; then
			print "Nazwa firmy: "
		    read fir
			print "Osoba kontaktowa: "
			read kont
			print "E-mail: "
			read email
			print "Telefon: "
			read tel
			print "Telefon komorkowy: "
			read cell
			print "Fax: "
			read fax
			print "Ulica i numer: "
			read ul
			print "Miasto: "
			read mst
			print "Kod pocztowy: "
			read kp
			print "Kraj: "
			read kr
			print "Dodatkowe informacje: "
			read note

				if [[ $2 ]]; then
					foo=$2
				else
						foo=$(echo $fir | sed -e 's/\(.*\)/\L\1/' | sed 's/\ //g')
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
			print "Czy zmienic? (T/n) "
		    read ed
				if [[ $ed = T ]]; then
						vi $DIR/$foo &&	echo "Wpis $foo zostal utworzony."
					else
						echo "Wpis $foo zostal utworzony."
				fi

		## osoba prywatna domyslnie
		else		
			print "Imie: "
		   	read imie
			print "Nazwisko: "
			read nazw
			print "Pseudonim: "
		    read nick
			print "Firma: "
			read praca
			print "E-mail: "
		    read email
			print "Telefon: "
			read cell
			print "Ulica i nr domu/mieszkania: "
			read ul
			print "Miasto: "
			read mst
			print "Kod pocztowy: "
		    read kp
			print "Kraj: "
			read kr
			print "Urodziny: "
			read ur
			print "Dodatkowe informacje: "
			read notes
	
				if [[ $2 ]]; then
					bar=$2
				else
						bar=$(echo $imie$nazw | sed -e 's/\(.*\)/\L\1/' | sed 's/\ //g')
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
			print "Czy zmienic? (T/n) "
			read ed
				if [[ $ed = T ]]; then
						vi $DIR/$bar && echo "Plik $DIR/$bar zostal utworzony."
					else
						echo "Plik $DIR/$bar zostal utworzony."
				fi
			fi
				exit 0
				;;
esac
