#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
INPUT_ARGUMENT=$1

#Function for querying the database and displaying info
QUERY_AND_DISPLAY() {
  local QUERY=$1
  local DATA=$($PSQL "$QUERY")
  #If the query returns values
  if [[ -n $DATA ]]; 
  then
    echo "$DATA" | while IFS=" | " read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT; 
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  else
    echo "I could not find that element in the database."
  fi
}

#Function for checking script input
VALIDATE_INPUT() {
  #If the script has no argument
  if [[ -z $INPUT_ARGUMENT ]]; 
  then
    echo "Please provide an element as an argument."
  elif [[ $INPUT_ARGUMENT =~ ^[0-9]+$ ]]; 
  then
    QUERY_AND_DISPLAY "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING (atomic_number) FULL JOIN types USING (type_id) WHERE elements.atomic_number='$INPUT_ARGUMENT'"
  elif [[ ${#INPUT_ARGUMENT} -gt 2 ]]; 
  then
    QUERY_AND_DISPLAY "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING (atomic_number) FULL JOIN types USING (type_id) WHERE name='$INPUT_ARGUMENT'"
  else
    QUERY_AND_DISPLAY "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING (atomic_number) FULL JOIN types USING (type_id) WHERE symbol='$INPUT_ARGUMENT'"
  fi
}

#Main program function
MAIN() {
  VALIDATE_INPUT
}

MAIN