#!/bin/bash

readonly MY_ITEM=$1 MY_DATA=$2 MY_USER=$3

echo "-----------------------------"

echo "User Name: $(whoami)"
echo "Student Number: 12191650"

echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the everage 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release data' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"

echo "-----------------------------"

while true; do
    read -rp "Enter your choice [1-9] " choice
    echo

    case $choice in
    1)
        read -rp "Please enter 'movie id' (1~1682):" movie_id
        echo

        awk 'NR=='"$movie_id"' {print $0}' "$MY_ITEM"
        echo
        ;;
    2) ;;
    3) ;;
    4) ;;
    5) ;;
    6) ;;
    7) ;;
    8) ;;
    9)
        echo "Bye!"
        break
        ;;
    esac
done
