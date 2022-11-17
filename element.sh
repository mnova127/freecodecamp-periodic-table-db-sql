#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ ! $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  # if arg1 is numeric, look up by atomic_number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number='$1'")
  fi

  # look up by symbol
  if [[ -z $ATOMIC_NUMBER_RESULT ]]
  then
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
  fi
  
  # look up by name
  if [[ -z $ATOMIC_NUMBER_RESULT ]]
  then
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
  fi

  # if atomic number variable is not empty, continue
  if [[ -z $ATOMIC_NUMBER_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    INFO=$($PSQL "SELECT atomic_number,symbol,name,melting_point_celsius,boiling_point_celsius,atomic_mass FROM elements INNER JOIN properties USING(atomic_number) WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    IFS="|"
    echo "$INFO" | while read ATOMIC_NUMBER SYMBOL NAME MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS ATOMIC_MASS
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
    done
  fi
fi
