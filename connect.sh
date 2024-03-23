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
    echo "何を入力するか選択してください。"
    echo "1. IPアドレス"
    echo "2. ポート"
    ehco "3. ペアリング"
    ehco "4. 接続を試す"
    getValue "IPアドレス" MODE

    if [ "$MODE" == "1" ];
        getValue "IPアドレス" ADDRESS
    elif [ "$MODE" == "2" ];
        getValue "ポート" PORT
    elif [ "$MODE" == "3" ];
        PORT=

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
    elif [ "$MODE" == "4" ];
        adb connect ${ADDRESS}:${PORT}
        CONNECTED_ADDRESS=$(adb devices -l | grep $ADDRESS:$PORT | awk '{ print $1 }')
    fi
done

if [ "$PORT_CACHE_FILE" != "" ]; then
    echo $PORT > "$PORT_CACHE_FILE"
fi