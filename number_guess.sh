#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
secret_number=$((1 + $RANDOM % 1000))
# echo "$secret_number"

num_guesses=0

# Prompt the user to guess the secret number
echo "Enter your username:"
read player
echo "Your name is: $player"

# Check if the username exists in the database
result=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$player';")
IFS='|' read -r games_played best_game <<< $result


if [[ $result ]]; then
    echo -e "\nWelcome back, $player! You have played $games_played games, and your best game took $best_game guesses."

else
    # If the username doesn't exist, insert a new record
    $PSQL "INSERT INTO users (username) VALUES ('$player');" >/dev/null 2>&1
    echo -e "\nWelcome, $player! It looks like this is your first time here."
fi


# Guessing the secret number
while true; do
    # Prompt the user to guess the secret number
    echo "Guess the secret number between 1 and 1000:"
    read user_guess
    echo "Your guess is: $user_guess"



    # Check if the input is a valid integer
    if ! [[ "$user_guess" =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi

    num_guesses=$((num_guesses + 1))


    if [[ "$user_guess" -eq "$secret_number" ]]; then
        

        # Update the games_played count in the database for the user
        $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$player';" >/dev/null 2>&1

        # Update best_game if the current game is the new best
        if [[ "$best_game" -eq 0 ]] || [[ "$num_guesses" -lt "$best_game" ]]; then
            $PSQL "UPDATE users SET best_game = $num_guesses WHERE username='$player';" >/dev/null 2>&1
        fi

        echo -e "\nYou guessed it in $num_guesses tries. The secret number was $secret_number. Nice job!"



        break

    elif [[ "$user_guess" -lt "$secret_number" ]]; then
        echo "It's higher than that, guess again:"
    else
        echo "It's lower than that, guess again:"
    fi

  
done

