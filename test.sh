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
    2)
        read -rp "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n) :" answer
        echo

        if [ "$answer" = "y" ]; then
            awk -F'|' '$7=="1" {print $1,$2}' "$MY_ITEM" | head
            echo
        fi
        ;;
    3)
        read -rp "Please enter the 'movie id' (1~1682) :" movie_id
        echo

        awk -F'\t' '$2=='"$movie_id"' {sum+=$3; ++cnt} END {printf "average rating of '"$movie_id"': %.5f", sum/cnt}' "$MY_DATA"
        echo
        ;;
    4)
        read -rp "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n) :" answer
        echo

        if [ "$answer" = "y" ]; then
            sed -E '1,10s/http:\/\/[^\)]*\)//' "$MY_ITEM" | head
            echo
        fi
        ;;
    5)
        read -rp "Do you want to get the data about users from 'u.user'?(y/n) :" answer
        echo

        if [ "$answer" = "y" ]; then
            awk -F'|' '{printf "user %s is %s years old %s %s\n", $1, $2, $3, $4}' "$MY_USER" | head | sed 's/M/male/;s/F/female/'
            echo
        fi
        ;;
    6)
        read -rp "Do you want to Modify the format of 'release data' in 'u.item'?(y/n) :" answer
        echo

        if [ "$answer" = "y" ]; then
            date_before=$(awk -F'|' '{print $3}' "$MY_ITEM" | tail)

            year=$(awk -F'-' '{print $3}' <(echo "$date_before"))
            month_before=$(awk -F'-' '{print $2}' <(echo "$date_before"))
            day=$(awk -F'-' '{print $1}' <(echo "$date_before"))

            month_after=$(echo "$month_before" | sed '  s/Jan/01/g;
                                                        s/Feb/02/g;
                                                        s/Mar/03/g;
                                                        s/Apr/04/g;
                                                        s/May/05/g;
                                                        s/Jun/06/g;
                                                        s/Jul/07/g;
                                                        s/Aug/08/g;
                                                        s/Sep/09/g;
                                                        s/Oct/10/g;
                                                        s/Nov/11/g;
                                                        s/Dec/12/g')

            date_after=$(paste -d'\0' <(echo "$year") <(echo "$month_after") <(echo "$day"))

            item_cur=$(cat <"$MY_ITEM" | tail)

            for i in {1..10}; do
                date_cur=$(awk NR=="$i" <(echo "$date_after"))
                awk 'NR=='"$i"' {print $0}' <(echo "$item_cur") | sed -E 's/[0-9]{2}-[A-Z][a-z]{2}-[0-9]{4}/'"$date_cur"'/'
            done
        fi
        ;;
    7)
        read -rp "Please enter the 'user id' (1~943) :" user_id
        echo

        user_movie_list=$(awk -F'\t' '$1=='"$user_id"' {print $2}' "$MY_DATA" | sort -n)

        awk '{printf "%d|", $1}' <(echo "$user_movie_list") | sed 's/|$/\n/'
        echo

        awk -F'|' 'NR==FNR {a[$1]; next} $1 in a {printf "%d|%s\n", $1, $2}' <(echo "$user_movie_list") "$MY_ITEM" | head
        echo
        ;;
    8)
        read -rp "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n) :" answer
        echo

        if [ "$answer" = "y" ]; then
            user_list=$(awk -F'|' '$2>=20 && $2<=29 && ($4=="occupation" || $4=="programmer") {print $1}' "$MY_USER")
            movie_rating_list=$(awk -F'\t' 'NR==FNR {a[$1]; next} $1 in a {print $2, $3}' <(echo "$user_list") "$MY_DATA")

            awk '{sum[$1] += $2; ++cnt[$1]} END {for (i in sum) printf "%d %.5f\n", i, sum[i]/cnt[i]}' <(echo "$movie_rating_list") | sort -n
        fi
        ;;
    9)
        echo "Bye!"
        break
        ;;
    esac
done
