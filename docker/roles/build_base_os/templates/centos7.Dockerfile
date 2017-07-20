FROM centos:7.3.1611

ARG os="centos"
ARG version="7"
ARG basearch="x86_64"

# 標準のリポジトリの参照先を理研に変更
WORKDIR /etc/yum.repos.d
RUN sed -i -e "s/^mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//\#mirrorlist\=http\:\/\/mirrorlist\.centos\.org\//g" ./*
RUN sed -i -e "s/^\#baseurl\=http\:\/\/mirror\.centos\.org\//baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\//g" ./*

# yumのproxy設定
#RUN echo "proxy=http://XXX.XXX.XXX.XXX:8080" >> /etc/yum.conf
RUN echo "proxy=http://192.168.56.2:3128" >> /etc/yum.conf
#RUN echo "proxy_username=XXXXXX" >> /etc/yum.conf
RUN echo "proxy_username=user" >> /etc/yum.conf
#RUN echo "proxy_password=XXXXXX" >> /etc/yum.conf
RUN echo "proxy_password=password" >> /etc/yum.conf

# リポジトリの追加（epel）
RUN yum install -y epel-release
RUN sed -i -e "s/^mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/\#mirrorlist\=https\:\/\/mirrors\.fedoraproject\.org/g" ./*
RUN sed -i -e "s/^#baseurl\=http\:\/\/download.fedoraproject.org\/pub/baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\/fedora/g" ./*

# リポジトリの追加（scl）
RUN yum install -y centos-release-scl
RUN sed -i -e "s/^baseurl\=http\:\/\/mirror\.centos\.org\//baseurl\=http\:\/\/ftp\.riken\.jp\/Linux\//g" ./*

RUN yum install -y openssh-server
RUN /usr/sbin/sshd-keygen 
RUN mkdir /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys 
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

# 
WORKDIR /
