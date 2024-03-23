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

if [ "$PORT_CACHE_FILE" != "" ]; then
    if [ "$PORT" == "" ]; then
        if [ -e "$PORT_CACHE_FILE" ]; then
            PORT=$(cat "$PORT_CACHE_FILE")
        fi
    fi
fi

adb connect ${ADDRESS}:${PORT}
CONNECTED_ADDRESS=$(adb devices -l | grep $ADDRESS:$PORT | awk '{ print $1 }')

while [ "$CONNECTED_ADDRESS" == "" ];
do
    MODE=
    echo "何を入力するか選択してください。"
    echo "1. IPアドレス"
    echo "2. ポート"
    echo "3. ペアリング"
    echo "4. 接続を試す"
    echo "5. 中断"
    getValue "選択" MODE

    if [ "$MODE" == "1" ]; then
        ADDRESS=
        getValue "IPアドレス" ADDRESS
    elif [ "$MODE" == "2" ]; then
        PORT=
        getValue "ポート" PORT
    elif [ "$MODE" == "3" ]; then
        ret=
        while ! echo $ret | grep "Successfully paired";
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