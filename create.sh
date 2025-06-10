#!/usr/bin/env bash

# Vultr VPS 交互式创建脚本
# 作者: AI Assistant
# 版本: 1.2.0 (修复 jq 解析错误)
#
# 功能:
# - 使用 Vultr API v2 交互式创建云服务器实例
# - 创建后轮询实例状态，等待 IP 地址分配完成
# - 自动选择地区、套餐、操作系统和 SSH 密钥
# - 支持自定义主机名和标签
# - 包含完整的错误处理和用户体验优化

# --- 初始化与错误处理 ---
set -e
set -o pipefail

# --- 全局变量和常量 ---
readonly API_URL="https://api.vultr.com/v2"
COLOR_PROMPT=$(tput setaf 3) # 黄色
COLOR_INFO=$(tput setaf 6)   # 青色
COLOR_SUCCESS=$(tput setaf 2) # 绿色
COLOR_ERROR=$(tput setaf 1)  # 红色
COLOR_RESET=$(tput sgr0)      # 重置颜色

# --- 脚本退出时的清理函数 ---
cleanup() {
    echo -e "\n${COLOR_INFO}脚本已退出。${COLOR_RESET}" >&2
    tput cnorm # 恢复光标
}
trap cleanup EXIT

# --- 核心函数 (选择部分无变化) ---

# 1. 检查依赖和API密钥
check_dependencies() {
    echo -e "${COLOR_INFO}1. 正在检查依赖工具...${COLOR_RESET}" >&2
    command -v curl >/dev/null 2>&1 || { echo >&2 -e "${COLOR_ERROR}错误: 'curl' 未安装，请先安装它。${COLOR_RESET}"; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo >&2 -e "${COLOR_ERROR}错误: 'jq' 未安装，请先安装它。${COLOR_RESET}"; exit 1; }
    echo "   - curl... ${COLOR_SUCCESS}OK${COLOR_RESET}" >&2
    echo "   - jq... ${COLOR_SUCCESS}OK${COLOR_RESET}" >&2

    if [[ -z "${VULTR_API_KEY}" ]]; then
        echo >&2 -e "${COLOR_ERROR}错误: 环境变量 'VULTR_API_KEY' 未设置。${COLOR_RESET}"
        echo >&2 "请执行 export VULTR_API_KEY='你的Vultr API密钥' 后再运行脚本。"
        exit 1
    fi
     echo -e "   - VULTR_API_KEY... ${COLOR_SUCCESS}OK${COLOR_RESET}\n" >&2
}

# 2. Vultr API 调用封装
vultr_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    # ... (此函数内部逻辑不变, 其错误输出已使用 >&2, 是正确的)
    local response
    local http_code
    local curl_exit_code

    response=$(curl -sS -H "Authorization: Bearer ${VULTR_API_KEY}" \
                    -H "Content-Type: application/json" \
                    -X "$method" \
                    --data "$data" \
                    -w "\n%{http_code}" \
                    "${API_URL}${endpoint}")
    curl_exit_code=$?
    
    if [ $curl_exit_code -ne 0 ]; then
        echo >&2 -e "${COLOR_ERROR}错误: cURL 请求失败，退出码: $curl_exit_code。请检查网络连接。${COLOR_RESET}"
        exit 1
    fi

    http_code=$(tail -n1 <<< "$response")
    local body=$(sed '$ d' <<< "$response")

    if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
        echo >&2 -e "${COLOR_ERROR}错误: API 请求失败 (HTTP $http_code)。${COLOR_RESET}"
        echo >&2 "API 响应:"
        echo >&2 "$body" | jq . || echo >&2 "$body"
        exit 1
    fi

    if echo "$body" | jq -e '.error' > /dev/null; then
        echo >&2 -e "${COLOR_ERROR}错误: API 返回错误信息。${COLOR_RESET}"
        echo >&2 "API 响应:"
        echo >&2 "$body" | jq .
        exit 1
    fi

    echo "$body"
}


# 3. 交互式选择菜单
select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    options+=("退出脚本")
    
    PS3="${COLOR_PROMPT}${prompt}${COLOR_RESET}"
    
    select opt in "${options[@]}"; do
        if [[ "$REPLY" -gt 0 && "$REPLY" -le ${#options[@]} ]]; then
            if [[ "$opt" == "退出脚本" ]]; then
                exit 0
            fi
            echo "$opt"
            return
        else
            echo -e "${COLOR_ERROR}无效的选择，请输入列表中的数字。${COLOR_RESET}" >&2
        fi
    done
}

# --- 执行流程函数 (选择部分无变化) ---
select_region() {
    echo -e "${COLOR_INFO}2. 正在获取可用地区...${COLOR_RESET}" >&2
    declare -A regions_map
    local region_options=()
    while IFS='|' read -r id display_name; do
        regions_map["$display_name"]="$id"
        region_options+=("$display_name")
    done < <(vultr_api_call "GET" "/regions" | jq -r '.regions[] | "\(.id)|\(.city), \(.country) (\(.id))"')
    local selected_display_name=$(select_option "请选择一个地区: " "${region_options[@]}")
    SELECTED_REGION_ID="${regions_map[$selected_display_name]}"
    SELECTED_REGION_NAME="$selected_display_name"
    echo -e "您选择了: ${COLOR_SUCCESS}${SELECTED_REGION_NAME}${COLOR_RESET}\n" >&2
}

select_plan() {
    echo -e "${COLOR_INFO}3. 正在获取 '${SELECTED_REGION_NAME}' 地区的可用套餐...${COLOR_RESET}" >&2
    # ... (代码不变)
    declare -A plans_map
    local plan_options=()
    local query=".plans[] | select(.locations | index(\"$SELECTED_REGION_ID\")) | select(.type == \"vc2\" or .type == \"vhf\" or .type == \"vdc\") | \"\(.id)|[\(.type)] CPU: \(.vcpu_count), 内存: \(.ram/1024)GB, 硬盘: \(.disk)GB, 价格: $\(.monthly_cost)/月\""
    while IFS='|' read -r id display_name; do
        plans_map["$display_name"]="$id"
        plan_options+=("$display_name")
    done < <(vultr_api_call "GET" "/plans" | jq -r "$query")
    if [ ${#plan_options[@]} -eq 0 ]; then
        echo -e "${COLOR_ERROR}错误: 在地区 '${SELECTED_REGION_NAME}' 未找到类型为 vc2, vhf 或 vdc 的可用套餐。${COLOR_RESET}" >&2
        exit 1
    fi
    local selected_display_name=$(select_option "请选择一个套餐: " "${plan_options[@]}")
    SELECTED_PLAN_ID="${plans_map[$selected_display_name]}"
    SELECTED_PLAN_NAME="$selected_display_name"
    echo -e "您选择了: ${COLOR_SUCCESS}${SELECTED_PLAN_NAME}${COLOR_RESET}\n" >&2
}

select_os() {
    echo -e "${COLOR_INFO}4. 正在获取可用操作系统...${COLOR_RESET}" >&2
    # ... (代码不变)
    declare -A os_map
    local os_options=()
    local query='.os[] | select(.arch == "x64" and .family != "snapshot" and .family != "backup" and .family != "iso") | "\(.id)|\(.name)"'
    while IFS='|' read -r id display_name; do
        os_map["$display_name"]="$id"
        os_options+=("$display_name")
    done < <(vultr_api_call "GET" "/os" | jq -r "$query")
    local selected_display_name=$(select_option "请选择一个操作系统: " "${os_options[@]}")
    SELECTED_OS_ID="${os_map[$selected_display_name]}"
    SELECTED_OS_NAME="$selected_display_name"
    echo -e "您选择了: ${COLOR_SUCCESS}${SELECTED_OS_NAME}${COLOR_RESET}\n" >&2
}

select_ssh_key() {
    echo -e "${COLOR_INFO}5. 正在获取账户下的 SSH 密钥...${COLOR_RESET}" >&2
    # ... (代码不变)
    declare -A ssh_keys_map
    local ssh_key_options=()
    while IFS='|' read -r id display_name; do
        ssh_keys_map["$display_name"]="$id"
        ssh_key_options+=("$display_name")
    done < <(vultr_api_call "GET" "/ssh-keys" | jq -r '.ssh_keys[] | "\(.id)|\(.name)"')
    SELECTED_SSH_KEY_ID=""
    SELECTED_SSH_KEY_NAME="使用密码登录"
    if [ ${#ssh_key_options[@]} -eq 0 ]; then
        echo -e "${COLOR_PROMPT}未找到 SSH 密钥，实例将使用密码登录。${COLOR_RESET}\n" >&2
        return
    fi
    ssh_key_options+=("跳过 (使用密码登录)")
    local selected_display_name=$(select_option "请选择一个 SSH 密钥 (推荐): " "${ssh_key_options[@]}")
    if [[ "$selected_display_name" != "跳过 (使用密码登录)" ]]; then
        SELECTED_SSH_KEY_ID="${ssh_keys_map[$selected_display_name]}"
        SELECTED_SSH_KEY_NAME="$selected_display_name"
    fi
    echo -e "您选择了: ${COLOR_SUCCESS}${SELECTED_SSH_KEY_NAME}${COLOR_RESET}\n" >&2
}

get_custom_inputs() {
    echo -e "${COLOR_INFO}6. 请输入自定义信息...${COLOR_RESET}" >&2
    # ... (代码不变)
    while true; do
        read -p "${COLOR_PROMPT}请输入主机名 (例如: my-server): ${COLOR_RESET}" INSTANCE_HOSTNAME
        if [[ -n "$INSTANCE_HOSTNAME" ]]; then
            break
        else
            echo -e "${COLOR_ERROR}主机名不能为空，请重新输入。${COLOR_RESET}" >&2
        fi
    done
    read -p "${COLOR_PROMPT}请输入标签 (可选, 多个用逗号分隔): ${COLOR_RESET}" INSTANCE_TAGS
    echo "" >&2
}

# --- [已修正] 等待IP地址分配的函数 ---
wait_for_ip_address() {
    local instance_id="$1"
    local attempts=0
    local max_attempts=20 # 最多等待 20 * 10 = 200 秒
    local interval=10     # 每 10 秒查询一次
    local spinner=('/' '-' '\' '|')

    # 将用户提示信息输出到 stderr (>&2)
    echo -e "${COLOR_INFO}实例创建请求已发送，正在等待 IP 地址分配...${COLOR_RESET}" >&2

    while [[ $attempts -lt $max_attempts ]]; do
        # 将 spinner 动态更新信息输出到 stderr (>&2)
        echo -n -e "\r${COLOR_PROMPT}查询中 (尝试 $((attempts + 1))/${max_attempts})... ${spinner[$((attempts % 4))]}${COLOR_RESET}" >&2
        
        local instance_details
        instance_details=$(vultr_api_call "GET" "/instances/${instance_id}")

        local ip_address
        ip_address=$(echo "$instance_details" | jq -r '.instance.main_ip')
        
        local instance_status
        instance_status=$(echo "$instance_details" | jq -r '.instance.status')

        if [[ "$ip_address" != "0.0.0.0" && "$instance_status" == "active" ]]; then
            # [关键修复] 将成功提示信息也输出到 stderr (>&2)
            echo -e "\r${COLOR_SUCCESS}✓ IP 地址已成功获取!                              ${COLOR_RESET}" >&2
            
            # [关键修复] 将纯净的 JSON 数据输出到 stdout，以便被变量捕获
            echo "$instance_details"
            return 0
        fi

        ((attempts++))
        sleep $interval
    done

    # [关键修复] 将超时错误信息输出到 stderr (>&2)
    echo -e "\r${COLOR_ERROR}错误: 等待超时 (${max_attempts}次尝试)。实例仍在后台创建中。${COLOR_RESET}" >&2
    echo -e "${COLOR_PROMPT}请稍后登录 Vultr 控制面板查看最终状态。${COLOR_RESET}" >&2
    return 1
}


# --- 确认并创建实例的函数 (逻辑不变，现在可以正确工作了) ---
confirm_and_create() {
    # 将所有 echo 都重定向到 stderr
    echo -e "------------------- 配置摘要 -------------------" >&2
    echo -e "地区        : ${COLOR_SUCCESS}${SELECTED_REGION_NAME}${COLOR_RESET}" >&2
    echo -e "套餐        : ${COLOR_SUCCESS}${SELECTED_PLAN_NAME}${COLOR_RESET}" >&2
    echo -e "操作系统    : ${COLOR_SUCCESS}${SELECTED_OS_NAME}${COLOR_RESET}" >&2
    echo -e "SSH 密钥    : ${COLOR_SUCCESS}${SELECTED_SSH_KEY_NAME}${COLOR_RESET}" >&2
    echo -e "主机名      : ${COLOR_SUCCESS}${INSTANCE_HOSTNAME}${COLOR_RESET}" >&2
    echo -e "标签        : ${COLOR_SUCCESS}${INSTANCE_TAGS:- (未设置)} ${COLOR_RESET}" >&2
    echo -e "------------------------------------------------\n" >&2

    local json_payload
    json_payload=$(jq -n \
        --arg region "$SELECTED_REGION_ID" \
        --arg plan "$SELECTED_PLAN_ID" \
        --arg os_id "$SELECTED_OS_ID" \
        --arg hostname "$INSTANCE_HOSTNAME" \
        '{region: $region, plan: $plan, os_id: $os_id, hostname: $hostname}')

    if [[ -n "$SELECTED_SSH_KEY_ID" ]]; then
        json_payload=$(echo "$json_payload" | jq '. + {sshkey_id: [$ssh_key]}' --arg ssh_key "$SELECTED_SSH_KEY_ID")
    fi
     if [[ -n "$INSTANCE_TAGS" ]]; then
        tags_json=$(echo "$INSTANCE_TAGS" | tr ',' '\n' | jq -R . | jq -s .)
        json_payload=$(echo "$json_payload" | jq --argjson tags "$tags_json" '. + {tags: $tags}')
    fi

    echo -e "${COLOR_INFO}将要发送的API请求体预览:${COLOR_RESET}" >&2
    echo "$json_payload" | jq . >&2
    echo "" >&2

    read -p "${COLOR_PROMPT}确认创建吗? (y/N): ${COLOR_RESET}" confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        echo -e "${COLOR_ERROR}操作已取消。${COLOR_RESET}" >&2
        exit 0
    fi
    
    echo -e "\n${COLOR_INFO}正在发送创建请求...${COLOR_RESET}" >&2
    local creation_response
    creation_response=$(vultr_api_call "POST" "/instances" "$json_payload")
    
    local instance_id
    instance_id=$(echo "$creation_response" | jq -r '.instance.id')

    # 调用等待函数，现在 final_instance_details 只会包含纯净 JSON
    local final_instance_details
    final_instance_details=$(wait_for_ip_address "$instance_id")
    
    # 检查 wait_for_ip_address 的退出码
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    
    echo -e "\n${COLOR_SUCCESS}✓ 实例创建并启动成功!${COLOR_RESET}" >&2
    echo -e "------------------- 最终实例详情 -------------------" >&2
    # 现在这个 jq 命令可以正确解析 final_instance_details 了
    echo "$final_instance_details" | jq -r '.instance | 
        "ID            : \(.id)\n" +
        "主机名        : \(.hostname)\n" +
        "主 IP 地址    : \(.main_ip)\n" + 
        "状态          : \(.status)\n" +
        "服务器状态    : \(.server_status)\n" +
        "密码          : \(.default_password)"' | sed 's/^/ /' >&2 # 输出到 stderr
    echo -e "-----------------------------------------------------\n" >&2

    local password=$(echo "$final_instance_details" | jq -r '.instance.default_password')
    local ip=$(echo "$final_instance_details" | jq -r '.instance.main_ip')

    echo -e "${COLOR_INFO}后续操作提示:${COLOR_RESET}" >&2
    if [[ -n "$SELECTED_SSH_KEY_ID" ]]; then
        echo "您可以使用以下命令通过 SSH 连接 (如果密钥正确):" >&2
        echo -e "   ${COLOR_PROMPT}ssh root@${ip}${COLOR_RESET}" >&2
    else
        echo "您可以使用上面的密码通过 SSH 连接:" >&2
        echo -e "   ${COLOR_PROMPT}ssh root@${ip}${COLOR_RESET}" >&2
        echo -e "${COLOR_ERROR}强烈建议您首次登录后立即修改默认密码!${COLOR_RESET}" >&2
    fi
}

# --- 主函数 ---
main() {
    clear
    echo "===============================================" >&2
    echo "    Vultr VPS 交互式创建脚本 (API v2)    " >&2
    echo "===============================================" >&2
    echo >&2
    
    tput civis # 隐藏光标
    
    check_dependencies
    select_region
    select_plan
    select_os
    select_ssh_key
    get_custom_inputs
    confirm_and_create
}

# --- 脚本入口 ---
main "$@"
