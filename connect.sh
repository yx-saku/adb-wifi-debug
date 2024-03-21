#!/bin/bash

function getValue() {
    MSG=$1
    local -n VAR=$2

    if [ "$VAR" == "" ]; then
        read -p "$MSG()" INPUT
        if [[ $INPUT == "exit" ]]; then
            echo "終了"
            exit 0
        fi
        VAR=$INPUT
    else
        echo "$MSG${VAR}"
    fi
}

if [ "$PORT_CACHE_FILE" != "" ]; then
    if [ "$PORT" == "" ]; then
        if [ -e "$PORT_CACHE_FILE" ]; then
            PORT=$(cat "$PORT_CACHE_FILE")
        fi
    fi
fi

getValue "IPアドレス" ADDRESS

while [ "$CONNECTED_ADDRESS" == "" ];
do
    getValue "ポート" PORT

    adb connect ${ADDRESS}:${PORT}

    CONNECTED_ADDRESS=$(adb devices -l | grep $ADDRESS:$PORT | awk '{ print $1 }')
    if [ "$CONNECTED_ADDRESS" == "" ]; then
        if [ "$PAIRED" == "true" ]; then
            PORT=
        else
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

            PAIRED=true
        fi
    fi
done

echo $PORT > "$PORT_CACHE_FILE"