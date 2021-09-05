#!/bin/bash

#输出参数
usage() {
    echo "Usage: sh redis.sh [install]"
    exit 1
}

if [ -x redis_base.sh ]
then
    source ./redis_base.sh
else
    echo "redis_base.sh没有运行权限，无法继续。"
    exit 1
fi

# redis安装
install(){
    echo "start install redis..."

echo "install mode: 1)Single   2)Sentinel   3)Cluster"

read -rp "Choose you need:(1,2,3):" mode

case ${mode} in 
    1)
        singleInstall
        ;;
    2)
        sentinelInstall
        ;;
    3)
        clusterInstall
        ;;
esac
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
   "install")
     install
     ;;
   *)
     usage
     ;;
esac