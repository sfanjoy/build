# Add the EWT user group for ssh access
if [ -z "$1" ]; then
        echo "Usage: rpm_install.sh < base | db | http | develop >";
        echo ""
        exit
fi
#
if [ $1 == "base" ]; then
  dnf -y update
  echo "Starting RPM installs for Centos Stream 9 ........."
  dnf -y install nc chrony vim wget pinentry git
  echo "Starting Perl and Python RPM installs........."
  dnf -y install perl perl-DBI perl-DBD-Pg python39
elif [ $1 == "docker" ]; then
  # remove conflict packages with Docker first
  dnf -y remove podman runc
  curl https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
  sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/docker-ce.repo
  dnf --enablerepo=docker-ce-stable -y install docker-ce
  systemctl enable --now docker
elif [ $1 == "db" ]; then
  echo "Installing PostgreSQL..."
  dnf -y module enable postgresql:15
  dnf -y install postgresql-server
elif [ $1 == "http" ]; then
  echo "Installing http services..."
  dnf -y install nginx 
elif [ $1 == "develop" ]; then
  dnf -y install gcc gcc-c++ rpm-build boost boost-devel
else
  echo "***"
  echo "Option $1 is not a valid option."
  echo "***"
  exit
fi
echo ""
echo "$1 rpms installed."
echo ""
