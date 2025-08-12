FROM   kt71020/perl-ordta-base-mac:latest_version

# Python3 安裝

RUN apt update && apt install -y python3 python3-pip
RUN pip3 install -U googlemaps

# 安装SSH服务和其他依赖
RUN apt-get update && apt-get install -y openssh-server zsh joe
RUN mkdir /var/run/sshd

# 安裝locales和設置zh_TW.UTF-8
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# 安裝 Zsh
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# 設置環境變量
ENV LANG=zh_TW.UTF-8  
ENV LANGUAGE=zh_TW:en  
ENV LC_ALL=zh_TW.UTF-8  



# 设置root密码为“password”（您可以选择其他密码）
RUN echo 'root:b1uxcdq' | chpasswd

# 其他配置，例如禁止root使用密钥登录
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


# 启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]

WORKDIR /app





