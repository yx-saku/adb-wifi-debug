#!/bin/bash -e

apt-get install -y wget git unzip nmap

# aptでadbをインストールするとapt pairコマンドがないため、直接adb最新版をインストール
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip && \
    unzip platform-tools-latest-linux.zip -d /adb && \
    ln -s /adb/platform-tools/adb /usr/local/bin/adb