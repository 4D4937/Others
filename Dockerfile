# 使用 CentOS 7 作为基础镜像
FROM centos:7

# 安装 SSH 服务和相关工具
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum -y update && \
    yum -y install openssh-server openssh-clients passwd && \
    yum clean all

# 生成 SSH 主机密钥
RUN ssh-keygen -A

# 设置 root 用户密码
RUN echo "root:666" | chpasswd

# 配置 SSH 服务
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 暴露 SSH 默认端口
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
