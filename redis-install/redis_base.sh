#!/bin/bash

#redis工具

#单机模式安装
singleInstall(){
    echo "start Single mode install..."
    path=$(changepackage)

    #解压安装目录
    dir=$(dirname "$path")
    cd "${dir}" || exit
    file=${path//${dir}\//}
    installdir=${file//.tar.gz/}
    echo "$installdir"
    tar -xzvf "${file}"
    rm -f "${file}"
    mv "${installdir}" redis
    cd redis || exit
    filepath="${dir}/redis"

    #配置用户权限
    mkdir /home/redis
    chown redis:redis /home/redis
    groupadd -r redis &&useradd -r -g redis redis
    chown redis:redis "${filepath}"


    #安装
    yum -q -y install gcc automake autoconf libtool make
    make MALLOC=libc
    ARCHITECTURE=$(getconf LONG_BIT)
    if [ "$ARCHITECTURE" == "32" ]; then
        make CFLAGS="-march=x86-64"
        make install
    elif [ "$ARCHITECTURE" == "64" ]; then
        make&&make install
    fi

    #修改配置文件
    mkdir bak
    chown redis:redis bak
    mkdir log
    chown redis:redis log
    mkdir conf
    chown redis:redis conf
    cp redis.conf redis.confbak
    sed -i -e 's\logfile\#logfile\g' -e '/^#logfile/a\logfile '"${filepath}"'\/log\/redis.log' redis.conf
    sed -i 's/dir .\//dir '"${filepath}"'\/bak/g' redis.conf
    sed -i 's/daemonize no/daemonize yes/g' redis.conf
    mv redis.conf conf/
    
}

#哨兵模式安装
sentinelInstall(){
    echo "start Sentinel mode install..."
}

#集群模式安装
clusterInstall(){
    echo "start Cluster mode install..."
}

#指定安装包
changepackage(){
    read -erp "安装包位置(tar.gz):" path
    if echo "${path}" | grep -q ".tar.gz$"
    then
        if checkfile "${path}" 0
        then
            echo "${path}"
            return
        else
            read -rp "您输入的位置：${path},不存在,是否重新输入继续安装（yes/no）" oncemore
            if [[ $oncemore == "yes" ]]
            then
                singleInstall
            else
                exit 1
            fi
        fi
    else
        read -rp "您输入的位置：${path},不是指定格式安装包,是否重新输入继续安装（yes/no）" oncemore
        if [[ $oncemore == "yes" ]]
        then
            singleInstall
        else
            exit 1
        fi
    fi
}

#验证目录存在
checkdir(){
    if [ -d "$1" ]
    then
        return 0
    else
        return 1
    fi
}

#验证文件存在
checkfile(){
    if [ -f "$1" ]
    then
        return 0
    else
        return 1
    fi
}