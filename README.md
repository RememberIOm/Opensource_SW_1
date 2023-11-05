# 오픈소스SW개론 보고서

# 스크립트 사용법

### 메뉴 구현 이전

1. 쉘스크립트 파일과 함께 주어지는 인자 초기화
    
    ```bash
    readonly MY_ITEM=$1 MY_DATA=$2 MY_USER=$3
    ```
    

1. User Name 출력
    
    ```bash
    echo "User Name: $(whoami)"
    ```
    

1. 메뉴를 echo 명령어를 이용해서 출력

### 메뉴 구현

- 각 메뉴 구현에 사용된 공통된 명령어
    - read -r : 백슬래시의 기능을 무효화하고 입력 문자열로 취급
    - read -p : 입력을 받기 전 작성한 문자열을 출력
    - head, tail : 맨 위 10줄, 맨 아래 10줄만 출력하는 명령어
    - y를 받으면 실행하는 if문
    
    ```bash
    if [ "$answer" = "y" ]; then
    # code here
    fi
    ```
    

- 1번 메뉴
    1. movie_id 변수의 입력을 받음
    2. 줄 번호가 movie_id에 해당하는 줄 전체를 출력
    
    ```bash
    awk 'NR=='"$movie_id"' {print $0}' "$MY_ITEM"
    ```
    

- 2번 메뉴
    1. y/n 입력을 받음
    2. ‘|’ 로 구분한 블럭들 중, 액션 장르가 명시되어있는 7번째 블록의 값이 1이라면 $1(영화의 id), $2(영화의 이름)을 넘김
    3. head 명령어로 맨 위 10줄만 출력
    
    ```bash
    awk -F'|' '$7=="1" {print $1,$2}' "$MY_ITEM" | head
    ```
    

- 3번 메뉴
    1. movie_id 변수의 입력을 받음
    2. 탭으로 구분한 블럭 중, 2번째 블럭이 movie_id와 같은 줄의 $3(movie rating)을 sum 변수에 더하고, 동시에 cnt를 1씩 증가
    3. 모든 작업이 완료 되면(END) sum / cnt 값을 소수점 5자리까지 출력
    
    ```bash
    awk -F'\t' '$2=='"$movie_id"' {sum+=$3; ++cnt} END {printf "average rating of '"$movie_id"': %.5f", sum/cnt}' "$MY_DATA"
    ```
    
- 4번 메뉴
    1. y/n 입력을 받음
    2. 1번부터 10번째 줄까지 ‘http://’로 시작하며 ‘)’가 아닌 문자들이 이어지고 ‘)’로 끝나는 문자열(주소를 의미함)을 삭제
    3. head 명령어로 맨 위 10줄만 출력
    
    ```bash
    sed -E '1,10s/http:\/\/[^\)]*\)//' "$MY_ITEM" | head
    ```
    

- 5번 메뉴
    1. y/n 입력을 받음
    2. printf를 사용하여 각각 알맞은 위치에 $1(id), $2(나이), $3(성별), $4(직업) 변수들을 넣은 문자열을 넘김
    3. 맨 위 10줄을 자름
    4. sed로 M을 male로, F를 female로 치환
    
    ```bash
    awk -F'|' '{printf "user %s is %s years old %s %s\n", $1, $2, $3, $4}' "$MY_USER" | head | sed 's/M/male/;s/F/female/'
    ```
    

- 6번 메뉴
    1. y/n 입력을 받음
    2. 바꾸기 전의 날짜 형식 문자열(3번째 블럭)을 date_before 변수에 저장
    
    ```bash
    date_before=$(awk -F'|' '{print $3}' "$MY_ITEM" | tail)
    ```
    
    1. 각각 year, month_before, day 변수에 바뀌기 전의 연, 월, 일을 저장. date_before은 ‘-’로 값이 나눠져 있음.
    
    ```bash
    year=$(awk -F'-' '{print $3}' <(echo "$date_before"))
    month_before=$(awk -F'-' '{print $2}' <(echo "$date_before"))
    day=$(awk -F'-' '{print $1}' <(echo "$date_before"))
    ```
    
    1. sed를 사용하여 월 정보를 숫자로 치환한 정보를 month_after에 저장
    
    ```bash
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
    ```
    
    1. date_after에 미리 저장해뒀던 3개 변수를 공백없이 붙임
    
    ```bash
    date_after=$(paste -d'\0' <(echo "$year") <(echo "$month_after") <(echo "$day"))
    ```
    
    1. 원본의 값을 치환하기 위해 원본도 맨 아래 10줄만 item_tail 변수에 저장
    
    ```bash
    item_tail=$(cat <"$MY_ITEM" | tail)
    ```
    
    1. for문을 사용하여 각 줄을 1개씩 뽑고 sed로 날짜 부분(숫자 2개-대문자 1개, 대문자 2개-숫자 4개)을 미리 만들었던 변경된 날짜 형식으로 치환
    
    ```bash
    for i in {1..10}; do
        date_cur=$(awk NR=="$i" <(echo "$date_after"))
        item_cur=$(awk NR=="$i" <(echo "$item_tail"))
    
        echo "$item_cur" | sed -E 's/[0-9]{2}-[A-Z][a-z]{2}-[0-9]{4}/'"$date_cur"'/'
    done
    ```
    
- 7번 메뉴
    1. user_id 변수에 입력을 받음
    2. 해당 유저가 평가한 영화들의 리스트를 뽑아 숫자 기준(-n 옵션) 오름차순으로 정렬
    
    ```bash
    user_movie_list=$(awk -F'\t' '$1=='"$user_id"' {print $2}' "$MY_DATA" | sort -n)
    ```
    
    1. 첫번째 출력인 ‘|’를 구분자로 유저가 평가한 모든 영화 id를 출력. 이때 마지막 ‘|’는 지워야하므로 $(문장의 끝) 기호를 사용하여 sed로 마지막 ‘|’를 자름.
    
    ```bash
    awk '{printf "%d|", $1}' <(echo "$user_movie_list") | sed 's/|$/\n/'
    ```
    
    1. NR(모든 파일의 레코드 번호)==FNR(현재 파일의 레코드 번호)을 사용하여 첫번째로 입력받은 파일은 a 배열에 저장, 두번째로 입력받은 파일은 a 배열에 있는지 확인하고 있으면 출력. next는 해당 구문이 참이면 다음 행을 받고 awk의 처음으로 돌아가는 함수.
    2. 출력값의 맨 위 10줄을 출력
    
    ```bash
    awk -F'|' 'NR==FNR {a[$1]; next} $1 in a {printf "%d|%s\n", $1, $2}' <(echo "$user_movie_list") "$MY_ITEM" | head
    ```
    
- 8번 메뉴
    1. y/n 입력을 받음
    2. user_list에는 문제의 조건에 맞는 유저의 id를 모아놓은 파일을 저장
    
    ```bash
    user_list=$(awk -F'|' '$2>=20 && $2<=29 && ($4=="occupation" || $4=="programmer") {print $1}' "$MY_USER")
    ```
    
    1. movie_rating_list에는 7번 메뉴에서와 비슷하게 두 개의 파일을 입력받고 첫번째 파일은 a 배열에 저장, 두번째 파일이 a 배열에 있으면 즉, 해당 유저가 평가한 평점 중 $2(영화 id), $3(평점)을 저장
    
    ```bash
    movie_rating_list=$(awk -F'\t' 'NR==FNR {a[$1]; next} $1 in a {print $2, $3}' <(echo "$user_list") "$MY_DATA")
    ```
    
    1. sum 배열에는 영화 id 인덱스에 영화의 평점을 각각 더해 저장하고, cnt 배열에도 영화 id 인덱스에 값을 증가
    2. 위 작업이 끝나면 (END) sum 배열에 있는 인덱스만 가져와 sum/cnt를 출력
    
    ```bash
    awk '{sum[$1] += $2; ++cnt[$1]} END {for (i in sum) printf "%d %.5f\n", i, sum[i]/cnt[i]}' <(echo "$movie_rating_list")
    ```
    
    1. 위를 오름차순으로 정렬
    2. 소수점 5자리까지 출력하기 위해 뒤로 오는 0의 연속과, 소수점이 없을 때 ‘.’를 삭제
    
    ```bash
    sort -n | sed -E 's/0*$//g;s/\.$//g'
    ```
    
- 9번 메뉴
    1. Bye! 를 출력하고 현재 case 문을 빠져나감
    
    ```bash
    echo "Bye!"
    break
    ```