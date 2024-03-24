#!/bin/bash

function getValue() {
    MSG=$1
    local -n VAR=$2

    if [ "$VAR" == "" ]; then
        read -p "$MSG：" INPUT
        if [[ $INPUT == "exit" ]]; then
            echo "終了"
            exit 0
        fi
        VAR=$INPUT
    else
        echo "$MSG：${VAR}"
    fi
}

if [ "$CACHE_FILE" != "" ]; then
    if [ -e "$CACHE_FILE" ]; then
        source "$CACHE_FILE"
    fi
fi

adb connect ${ADDRESS}:${PORT}
CONNECTED_ADDRESS=$(adb devices -l | grep $ADDRESS:$PORT | awk '{ print $1 }')

while [ "$CONNECTED_ADDRESS" == "" ];
do
    MODE=
    echo "選択してください。（exitを入力で中断）"
    echo -n "1. IPアドレス"; [ "$ADDRESS" != "" ] && echo "（現在の値：$ADDRESS）"
    echo -n "2. ポート"; [ "$PORT" != "" ] && echo "（現在の値：$PORT）"
    echo "3. ペアリング"
    echo "4. 接続を試す"
    getValue "選択" MODE

    if [ "$MODE" == "1" ]; then
        ADDRESS=
        getValue "IPアドレス" ADDRESS
    elif [ "$MODE" == "2" ]; then
        PORT=
        getValue "ポート" PORT
    elif [ "$MODE" == "3" ]; then
        ret=
        while ! echo $ret | grep "Successfully paired" > /dev/null;
        do
            getValue "ペア設定ポート" PAIR_PORT
            getValue "ペア設定コード" PAIR_CODE

            ret=$(adb pair ${ADDRESS}:${PAIR_PORT} $PAIR_CODE)
            echo $ret

            PAIR_PORT=
            PAIR_CODE=
        done

        continue
    elif [ "$MODE" == "4" ]; then
        adb connect ${ADDRESS}:${PORT}
        CONNECTED_ADDRESS=$(adb devices -l | grep $ADDRESS:$PORT | awk '{ print $1 }')
    elif [ "$MODE" == "5" ]; then
        exit
    fi
done

if [ "$CACHE_FILE" != "" ]; then
    echo ADDRESS=$ADDRESS > "$CACHE_FILE"
    echo PORT=$PORT >> "$CACHE_FILE"
fi