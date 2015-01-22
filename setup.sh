#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Setting up locales..."
/usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "Setting up APT mirrors..."
`cat >/etc/apt/sources.list <<\EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
EOF
`

echo "Settitng up Passenger's APT repository..."
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates
echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list

echo 'Upgrading all packages...'
apt-mark hold grub
apt-mark hold grub-common
apt-get -y update
apt-get -y upgrade
apt-mark unhold grub
apt-mark unhold grub-common

echo "Installing miscellaneous packages packages..."
apt-get install -y build-essential curl git nodejs imagemagick subversion python-software-properties \
        zip unzip libz-dev libreadline-dev zlib1g zlib1g-dev sqlite3 libsqlite3-dev openssl libssl-dev \
        libffi-dev linux-tools-generic systemtap sbcl gdb

echo 'Installing PostgreSQL...'
apt-get install -y postgresql postgresql-contrib postgresql-client libpq-dev

echo 'Installing MySQL...'
apt-get install -y mysql-server mysql-client

echo "Installing redis..."
apt-get install -y redis-server  libhiredis-dev

echo 'Installing Nginx + Passenger...'
apt-get install -y passenger nginx-extras

echo 'Installing rbenv...'
`cat >/home/vagrant/install_rbenv.sh <<\EOF
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
EOF
`
chmod +x /home/vagrant/install_rbenv.sh
su vagrant -c "bash -c /home/vagrant/install_rbenv.sh"
rm /home/vagrant/install_rbenv.sh

echo 'Configuring a nice session environment...'
`cat >>/home/vagrant/.bash_profile <<\EOF
alias ls="ls --color=auto"
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias glog='git log --oneline --decorate --graph'
export CLICOLOR="YES"
export PS1="[\[\033[0;31m\]\u\[\033[0m\]@\h:\[\033[1;37m\]\w\[\033[0m\]]\$ "
export LANG="en_US.UTF-8"
EOF
`

echo 'Cleanup old and unused packages...'
apt-get -y autoremove
apt-get -y autoclean
apt-get -y clean

echo 'Finished.'
