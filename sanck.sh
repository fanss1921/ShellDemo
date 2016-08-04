#!/bin/bash

# ���װ�̰���ߣ�������һЩBUG�������������֡���ͷ������
#
# 2016��8��3��10:48:07
#
# @author ���

declare -i tputlines; #����̨�߶� 
declare -i tputcols;  #����̨���
declare -i HIGHT
declare -i WIDTH
declare -ia map;
declare -a way; #��ǰ����Ŀ�귽��
declare -a xsnackBody; # ����0Ϊͷ���
declare -a ysnackBody;
declare -i l_snack;
declare -i PIDSnack;
declare -ia snackfood;
declare gamestaus;

function initMap() # ���ͣ�x,y
{
    tputlines=`tput lines`;
    tputcols=`tput cols`;
    HIGHT=$((${tputlines}-3));
    WIDTH=$((${tputcols}-50));
    map[0]=1;        #x0
    map[1]=1;        #y0
    map[2]=${WIDTH}; #x1
    map[3]=${HIGHT}; #y1
}

function printMap()
{
    for ((i=0; i<=$WIDTH; i++))
    {
        for ((j=0; j<=$HIGHT; j++))
        {
            if [[ $i == ${map[0]} || $i == ${map[2]} ]] || [[ $j == ${map["1"]} || $j == ${map["3"]} ]];then
            {
                print "wall" $i $j;
            };fi;
        }
    }
}

function print()
{
    case "$1" in
        "map")  echo -e "\e[${3};${2}H\e[44m \e[0m";;
        "wall") echo -e "\e[${3};${2}H\e[42;30m#\e[0m";;
        "head") echo -e "\e[${3};${2}H\e[42;30m*\e[0m";;
        "body") echo -e "\e[${3};${2}H\e[42m+\e[0m";;
        "tail") echo -e "\e[${3};${2}H\e[42;30m-\e[0m";;
        "food") echo -e "\e[${3};${2}H\e[30m@\e[0m";;
        "clear") echo -e "\e[${3};${2}H \e[0m";; #\e[40m
    esac;
}

function clearTerminal()
{
    echo -ne "\e[2J";
}

function initSnack()
{
    local ymid;
    let ymid=\(${map[1]}+${map[3]}\)\/2
    local xmid;
    let xmid=\(${map[0]}+${map[2]}\)\/2
    way[0]="��";
    way[1]="��";
    l_snack=$1;
    
    for((i=0;i<$l_snack;i++))
    {
        let xsnackBody[$i]=$xmid-$i;
        let ysnackBody[$i]=$ymid;
    }
}

function printSnack()
{
    print "head" ${xsnackBody[0]} ${ysnackBody[0]};
    for((i=1;i<l_snack-1;i++))
    {
        print "body" ${xsnackBody[$i]} ${ysnackBody[$i]};
    }
    print "tail" ${xsnackBody[((${l_snack}-1))]} ${ysnackBody[((${l_snack}-1))]};
}

function movetoNext()
{
    snackEat
    print "clear" ${xsnackBody[((${l_snack}-1))]} ${ysnackBody[((${l_snack}-1))]}
    for((i=$l_snack;i>0;i--))
    {
        ysnackBody[$i]=${ysnackBody[((${i}-1))]};
        xsnackBody[$i]=${xsnackBody[((${i}-1))]};
    }
    case ${way[0]} in
    "��")   let ysnackBody[0]-- ;;
    "��")   let ysnackBody[0]++ ;;
    "��")   let xsnackBody[0]-- ;;
    "��")   let xsnackBody[0]++ ;;
    esac;
    gameOverTest;
    printSnack;
}

function turnway() #�ϡ��¡�����
{
    if [[ ${way[0]} != ${way[1]} ]];then
        if ! (([ ${way[0]} == "��" -a ${way[1]} == "��" ] || [ ${way[0]} == "��" -a ${way[1]} == "��" ]) || \
            ([ ${way[0]} == "��" -a ${way[1]} == "��" ] || [ ${way[0]} == "��" -a ${way[1]} == "��" ]));then
            way[0]=${way[1]};
        fi
    else
        movetoNext;
    fi
}

function readisign()
{
    case $1 in
    "A") way[1]="��" ;;
    "B") way[1]="��" ;;
    "C") way[1]="��" ;;
    "D") way[1]="��" ;;
    esac;
    turnway;
}

function createFood()
{
    snackfood[0]=$(($RANDOM%($WIDTH-2)+2))
    snackfood[1]=$(($RANDOM%($HIGHT-2)+2))
    print "food" ${snackfood[0]} ${snackfood[1]}
}

function snackEat()
{
    if [ ${xsnackBody[0]} == ${snackfood[0]} -a ${ysnackBody[0]} == ${snackfood[1]} ];then
        let l_snack++;
        createFood;
    fi;
}

function gameoverinfo()
{
    gamestaus="over"
#    kill -30 $PPID
    echo "           Game Over!!!      ";
    echo "       �밴Ctrl+C �뿪��Ϸ      ";
}

function gameOverTest()
{
    local gameover="false";
    for((i=1;i<l_snack;i++))
    {
        if [ ${xsnackBody[0]} == ${xsnackBody[$i]} ] && [ ${ysnackBody[0]} == ${ysnackBody[$i]} ];then
            gameover="true";
        fi;
    }
    if [ ${xsnackBody[0]} == ${map[0]} ] || [ ${xsnackBody[0]} == ${map[2]} ] \
    || [ ${ysnackBody[0]} == ${map[1]} ] || [ ${ysnackBody[0]} == ${map[3]} ];then
        gameover="true"
    fi;
    if [ $gameover == "true" ];then
        gameoverinfo;
    fi;
}

function initSnackTrap()
{
    trap "readisign A" 35
    trap "readisign B" 36
    trap "readisign D" 37
    trap "readisign C" 38
    trap "exit 2" 2
}
function snackProcess()
{
    tput civis;
    initSnackTrap
    initMap
    printMap
    createFood
    initSnack 6
    movetoNext;
    gamestaus="normal"
    while [ ${gamestaus} == "normal" ];do
    {
        movetoNext;
        sleep 0.5;
    };done;
}

function readinput()
{
    local input;
    while(true);do
    {
        read -st 1 -n 1 input;
        if [[ $input == $'\033' ]];then
            read -st 1 -n 1 input;
            if [[ $input == '[' ]];then
                read -st 1 -n 1 input;
                case $input in
                "A") `kill -35 $PIDSnack`;;
                "B") `kill -36 $PIDSnack`;;
                "D") `kill -38 $PIDSnack`;;
                "C") `kill -37 $PIDSnack`;;
                esac;
            fi;
        fi;
    };done;
}

function exitGame()
{
    kill -2 $PIDSnack
    tput cnorm;
    recoverTerminal;
    exit 2;
}

function initReadTrap()
{
    trap "exitGame" 2
}

function initTerminal()
{
    clearTerminal;
    initReadTrap;
    readinput;
}

function recoverTerminal()
{
    tput cup $tputlines 0
    clearTerminal
}

function readProcess()
{
    initTerminal;
}

function help()
{
    echo "
                    /^\/^\\
                  _|__|  O|
         \/     /~     \_/ \\
          \____|__________/  \\
                 \\_______      \\
                          \     \                 \\
                           |     |                  \\
                          /      /                    \\
                         /     /                       \\
                       /      /                         \\ \\
                      /     /                            \\  \\
                    /     /             _----_            \\   \\
                   /     /           _-~      ~-_         |   |
                  (      (        _-~    _--_    ~-_     _/   |
                   \      ~-____-~    _-~    ~-_    ~-_-~    /
                     ~-_           _-~          ~-_       _-~   
                        ~--______-~                ~-___-~"
    echo -e "\n\n\n"
    echo -e "                       ��ӭ������Ϸ��\n"
    echo -e "         ����,�����װ�̰����!��"
    echo -e "         ����˵�����������Ҽ������ߵķ���ײ��ǽ����ҧ���Լ�����Ϸ�������\n"
    for ((i=6;i>0;i--))
    {
        echo "${i}s��ʼ��Ϸ";
        sleep 1;
    }
}

help
snackProcess &
PIDSnack=$!
readProcess;
