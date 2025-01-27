#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

LOGIN_AND_UPDATE() {
  echo "Enter your username:"
  read USERNAME

  # Check if username exists
  USER_DATA=$($PSQL "SELECT user_id, name, games_count, least_guesses_count FROM users FULL JOIN user_more_info USING (user_id) WHERE name='$USERNAME'")
  
  if [[ -z $USER_DATA ]]
  then
    # New user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
    INSERT_ID=$($PSQL "INSERT INTO user_more_info(user_id) VALUES($USER_ID)")
    NUMBER_GENERATOR_GAME "$USER_ID"
  else
    # Existing user
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
    echo "$USER_DATA" | while IFS='|' read -r USER_ID NAME GAMES_COUNT LEAST_GUESSES
    do
      echo "Welcome back, $NAME! You have played $GAMES_COUNT games, and your best game took $LEAST_GUESSES guesses."
    done
    NUMBER_GENERATOR_GAME "$USER_ID"
  fi
}

NUMBER_GENERATOR_GAME() {
  local USER_ID=$1
  local SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  local GUESSES=1

  echo "Guess the secret number between 1 and 1000:"

  while true; do
    read USER_GUESS

    # Validate input
    if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi

    if (( USER_GUESS < SECRET_NUMBER )); then
      echo "It's higher than that, guess again:"
      ((GUESSES++))
    elif (( USER_GUESS > SECRET_NUMBER )); then
      echo "It's lower than that, guess again:"
      ((GUESSES++))
    else
      # Update database with game stats
      EXISTING_DATA=$($PSQL "SELECT games_count, least_guesses_count FROM user_more_info WHERE user_id=$USER_ID")
      IFS='|' read -r GAMES_COUNT LEAST_GUESSES <<< "$EXISTING_DATA"

      ((GAMES_COUNT++))
      if [[ $LEAST_GUESSES == 0 || $GUESSES -lt $LEAST_GUESSES ]]; then
        LEAST_GUESSES=$GUESSES
      fi

      UPDATE_INFO=$($PSQL "UPDATE user_more_info SET games_count=$GAMES_COUNT, least_guesses_count=$LEAST_GUESSES WHERE user_id=$USER_ID")

      # Exit the loop and function once the number is guessed
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      return
    fi
  done
}

MAIN() {
  LOGIN_AND_UPDATE
}

MAIN
