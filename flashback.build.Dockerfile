FROM --platform=linux/amd64 centos:7 AS env

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum update -y

RUN curl -s "https://cmake.org/files/v3.29/cmake-3.29.0-linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local

ENV PACKAGES libfdt-devel ccache \
  tar git gcc flex bison build-essential make gstreamer-1.0 uuid-dev vcpkg GLIBCXX_3.4.19 wget \
   zlib-devel glib2-devel SDL-devel pixman-devel unzip \
   epel-release
RUN yum install -y $PACKAGES

SHELL ["/bin/bash", "--login", "-c"]
RUN gcc --version

RUN yum -y install gcc-c++ \
    libsqlite3x-devel.x86_64 \
    libarchive-devel.x86_64

COPY . /etc/flashback

WORKDIR /etc/flashback

RUN cd /etc/flashback && make clean all

ENTRYPOINT [ "/etc/flashback" ]

# ----------

# DOCKER-COMMANDS
# docker build -t cpp-flashback . -f ./flashback.build.Dockerfile
# docker run --platform linux/amd64  -it --entrypoint /bin/bash cpp-flashback
# docker run -it --entrypoint /bin/bash cpp-flashback
# docker rm -v -f $(docker ps -qa) # REMOVES ALL RUNNING CONTAINER
# docker start -a -i 
# docker exec -it <CONTAINER-ID> bash #--> attach already running container

# ----------

# Git repo link
# git clone https://github.com/laffer1/flashback

# ----------

# Update CFLAGS flashback/Makefile
# CFLAGS= -pthread -Wall -pedantic -D_FILE_OFFSET_BITS=64 -D__BSD_VISIBLE=1 -g -gdwarf-2 -gstrict-dwarf -O0 -Wall -Wextra -Wconversion -Warray-temporaries -fcheck-array-temporaries

# Update LIBS flashback/Makefile (comment out => -lbz2 -lz)
# LIBS= -lsqlite3 -larchive

# ----------

# Build command execute at '/etc/flashback' directory
# make clean all

# ----------

# Command to find ELF files:
# find . -exec file {} \; | grep --color -i elf
# find $WHERE -type f -exec hexdump -n 4 -e '4/1 "%2x" " {}\n"'  {} \; | grep ^7f454c46
# find $WHERE -type f -exec hexdump -n 4 -e '4/1 "%1_u" " {}\n"'  {} \; | grep ^delELF
# find $WHERE -type f -exec head -c 4 {} \; -exec echo " {}" \;  | grep ^.ELF



