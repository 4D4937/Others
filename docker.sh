#!/bin/bash

# 函数：创建容器
create_containers() {
    # 提示用户配置镜像加速服务
    echo "提示：如果您希望加速镜像拉取，可以配置 Docker daemon 的 registry-mirrors 为 https://dockerpull.pw/"
    echo "例如，在 /etc/docker/daemon.json 中添加："
    echo "{"
    echo "  \"registry-mirrors\": [\"https://dockerpull.pw/\"]"
    echo "}"
    echo "然后重启 Docker 服务：sudo systemctl restart docker"

    # 提示用户输入要创建的容器数量
    echo "请输入要创建的容器数量："
    read num

    # 检查输入是否为正整数（简单验证）
    if ! echo "$num" | grep -q '^[0-9]\+$' || [ "$num" -le 0 ]; then
        echo "错误：请输入一个有效的正整数。"
        exit 1
    fi

    # 循环创建指定数量的容器
    for i in $(seq 1 "$num"); do
        while true; do
            # 提示用户输入第 i 个容器的主机名
            echo "请输入第 $i 个容器的主机名："
            read hostname

            # 检查主机名是否为空
            if [ -z "$hostname" ]; then
                echo "主机名不能为空，请重新输入。"
            # 检查主机名是否已经被使用
            elif docker ps -a --format '{{.Names}}' | grep -q "^$hostname$"; then
                echo "主机名 $hostname 已经存在，请输入一个新的主机名。"
            else
                break
            fi
        done

        # 创建并启动容器，使用 CentOS 7 镜像，并在容器中运行指定脚本
        echo "正在创建容器 $hostname ..."
        docker run -it --rm \
            --cap-add=NET_ADMIN \
            --cap-add=SYS_ADMIN \
            --device=/dev/net/tun \
            --name "$hostname" \
            centos:7 \
            /bin/bash -c "wget -qO- https://raw.githubusercontent.com/4D4937/Others/refs/heads/master/set.sh | bash"

        # 检查容器是否创建成功
        if [ $? -eq 0 ]; then
            echo "容器 $hostname 创建并启动成功。"
        else
            echo "容器 $hostname 创建失败，请检查 Docker 环境或网络连接。"
        fi
    done

    echo "所有容器创建完成。"
}

# 函数：删除所有容器
delete_all_containers() {
    echo "警告：此操作将删除所有 Docker 容器，包括正在运行和已停止的容器。"
    echo "请确认是否继续？（y/n）"
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        # 停止所有正在运行的容器
        running_containers=$(docker ps -q)
        if [ -n "$running_containers" ]; then
            echo "正在停止所有运行中的容器..."
            docker stop $running_containers
        else
            echo "没有正在运行的容器。"
        fi

        # 删除所有容器
        all_containers=$(docker ps -a -q)
        if [ -n "$all_containers" ]; then
            echo "正在删除所有容器..."
            docker rm $all_containers
            echo "所有容器已删除。"
        else
            echo "没有容器需要删除。"
        fi
    else
        echo "操作已取消。"
    fi
}

# 主菜单
echo "请选择操作："
echo "1: 创建容器"
echo "2: 删除所有容器"
echo "3: 退出"
read choice

case $choice in
    1)
        create_containers
        ;;
    2)
        delete_all_containers
        ;;
    3)
        echo "退出脚本。"
        exit 0
        ;;
    *)
        echo "无效的选择，请重新运行脚本。"
        exit 1
        ;;
esac
