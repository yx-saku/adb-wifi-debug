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

function getPort() {
    echo -n "ポート自動検出($ADDRESS)... "
    PORT=$(nmap $ADDRESS -p 35000-46000 -T4 | awk "/\/tcp/" | cut -d/ -f1)
    echo $PORT
}

function connect {
    adb connect ${ADDRESS}:${PORT}
    CONNECTED_ADDRESS=$(adb devices -l | grep $ADDRESS:$PORT | awk '{ print $1 }')
}

if [ "$CACHE_FILE" != "" ]; then
    if [ -e "$CACHE_FILE" ]; then
        source "$CACHE_FILE"
    fi
fi

if [ "$ADDRESS" != "" ]; then
    if [ "$PORT" != "" ]; then
        connect
    fi
fi

while [ "$CONNECTED_ADDRESS" == "" ];
do
    MODE=
    echo "選択してください。（exitを入力で中断）"
    echo -n "1. IPアドレス"; [ "$ADDRESS" != "" ] && echo "（現在の値：$ADDRESS）" || echo 
    echo -n "2. ポート"; [ "$PORT" != "" ] && echo "（現在の値：$PORT）" || echo 
    echo "3. ペアリング"
    echo "4. 接続を試す"
    getValue "選択" MODE

    if [ "$MODE" == "1" ]; then
        ADDRESS=
        getValue "IPアドレス" ADDRESS

        TMP_PORT=$PORT
        getPort
        if [ "$PORT" == "" ]; then
            PORT=$TMP_PORT
        fi

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
    elif [ "$MODE" == "4" ]; then
        if [ "$ADDRESS" != "" ] && [ "$PORT" != "" ]; then
            connect
        fi
    fi
done

if [ "$CACHE_FILE" != "" ]; then
    echo ADDRESS=$ADDRESS > "$CACHE_FILE"
    echo PORT=$PORT >> "$CACHE_FILE"
fi