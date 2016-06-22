# !/bin/bash
#use root please
nginx_fpm_user='_www'
nginx_fpm_group='_www'
# while getopt "u:g:h" opt
# do
# 	case $opt in 
# 		u) 
# 			nginx_fpm_user=${OPTARG};;
# 		g) 
# 			nginx_fpm_group=${OPTARG};;
# 		h) 
# 			echo "params:"
# 			echo "-h		display this help and exit"
# 			echo "-u 		the user of nginx and php-fpm,default:_www"
# 			echo "-g 		the group of nginx and php-fpm,default:_www"
# 			exit 0
# 			;;
# 	esac
# done
change_source=0
set -- `getopt -o hu:g: -l with-change-source,with-user:,with-group,help -- $*`
while [ ! -z $1 ]
do
	case $1 in
		-u|--with-user)
			nginx_fpm_user=$2
			shift
			shift
			;;
		g|--with-group)	
			nginx_fpm_group=$2
			shift
			shift
			;;
		--with-change-source)
			change_source=1
			shift
			;;	
		h|--help)
			echo "params:"
			echo "--with-change-source set up your apt-get resource to Chinese resource"
			echo "-h, --help		display this help and exit"
			echo "-u, --with-user 		the user of nginx and php-fpm,default:_www"
			echo "-g, --with-group 		the group of nginx and php-fpm,default:_www"
			exit 0
			;;
		--)
			shift
			break
			;;
	esac
done	
if [ $change_source -eq 1 ]
	then
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	echo "deb http://mirrors.aliyun.com/ubuntu/ vivid main restricted universe multiverse" > /etc/apt/sources.list
	echo "deb http://mirrors.aliyun.com/ubuntu/ vivid-security main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb http://mirrors.aliyun.com/ubuntu/ vivid-updates main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb http://mirrors.aliyun.com/ubuntu/ vivid-proposed main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb http://mirrors.aliyun.com/ubuntu/ vivid-backports main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb-src http://mirrors.aliyun.com/ubuntu/ vivid main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb-src http://mirrors.aliyun.com/ubuntu/ vivid-security main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb-src http://mirrors.aliyun.com/ubuntu/ vivid-updates main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb-src http://mirrors.aliyun.com/ubuntu/ vivid-proposed main restricted universe multiverse" >> /etc/apt/sources.list
	echo "deb-src http://mirrors.aliyun.com/ubuntu/ vivid-backports main restricted universe multiverse" >> /etc/apt/sources.list
	apt-get update
fi
which python 2> ./error.log
if [ $? -ne 0 ]
	then
	apt-get -y install build-essential zlib1g-dev python-dev libjpeg-dev
fi
if [ ! -d /usr/local/Cellar ]
	then
	mkdir -p /usr/local/Cellar/openssl
	mkdir /usr/local/Cellar/libcurl
	mkdir /usr/local/Cellar/pcre
	mkdir /usr/local/Cellar/nginx
	mkdir /usr/local/Cellar/libpng
	mkdir /usr/local/Cellar/freetype
	mkdir /usr/local/Cellar/libxml2
	#mkdir /usr/local/Cellar/freetds
	#mkdir /usr/local/Cellar/libjpeg
	mkdir /usr/local/Cellar/gettext
	mkdir /usr/local/Cellar/mhash
	mkdir /usr/local/Cellar/libmcrypt
	
	mkdir /usr/local/Cellar/php5
	mkdir  /usr/local/etc/php5
	mkdir /usr/local/etc/nginx
fi	
configure() {
	#通过bin和sbin目录下的文件个数查看是否已经安装了软件
	if [ `ls /usr/local/Cellar/${4}/sbin | wc -l` -ne 0 -o `ls /usr/local/Cellar/${4}/include | wc -l` -ne 0 ]
	#if [[ `ls /usr/local/Cellar/${4}/sbin | wc -l` -ne 0 || `ls /usr/local/Cellar/${4}/include | wc -l` -ne 0 ]]
		then
		return 1
	fi
	tar -xf $1
	if [ $? -ne 0 ]
		then	
		echo "tar {$4} error"
		exit
	fi
	#rm -rf $1
	cd $2
	./configure $3
	make && make install
	cd ../
	if [ $2 != './pcre-8.38' ]
		then
		rm -rf $2
	fi
	return 0
}
################################################libxml2############################################################
#需要python-dev
configure 'libxml2-2.9.3.tar.gz' './libxml2-2.9.3' '--prefix=/usr/local/Cellar/libxml2' 'libxml2'
################################################libxml2############################################################
exit
####################################################libcurl#######################################################
configure 'curl-7.47.1.tar.gz' './curl-7.47.1' '--prefix=/usr/local/Cellar/libcurl' 'libcurl'
####################################################libcurl#######################################################
####################################################bzip2#######################################################
#configure 'bzip2-1.0.6.tar.gz' './bzip2-1.0.6' '--prefix=/usr/local/Cellar/bzip2' 'bzip2'
if [ ! -s /usr/local/bin/bzip2 ]
	then
	tar -xf bzip2-1.0.6.tar.gz
	cd ./bzip2-1.0.6
	make -f Makefile-libbz2_so
	make && make install
	cd ../
	rm -rf ./bzip2-1.0.6
fi
####################################################bzip2#######################################################
####################################################pcre#######################################################
configure 'pcre-8.38.tar.gz' './pcre-8.38' '--prefix=/usr/local/Cellar/pcre' 'pcre'
####################################################pcre#######################################################
################################################openssl##########################################################
if [ `ls /usr/local/Cellar/openssl | wc -l` -eq 0 ]
	then
	`tar -xf openssl-1.0.2g.tar.gz`
	if [ $? -ne 0 ]
		then	
		echo 'tar openssl error'
		exit
	fi
	#rm -rf openssl-1.0.2g.tar.gz
	cd ./openssl-1.0.2g
	./config --prefix=/usr/local/Cellar/openssl
	make && make depend && make install
	cd ../
	#rm -rf ./openssl-1.0.2g
fi
####################################################openssl#######################################################
################################################libpng##########################################################
#需要zlib
#export LDFLAGS="-L/usr/local/Cellar/zlib/lib"		#there is not space between -L and the Dir
#export CPPFLAGS="-I/usr/local/Cellar/zlib/include"
#configure 'libpng-1.6.21.tar.gz' './libpng-1.6.21' '--prefix=/usr/local/Cellar/libpng --with-zlib-prefix=/usr/local/Cellar/zlib/'
configure 'libpng-1.6.21.tar.gz' './libpng-1.6.21' '--prefix=/usr/local/Cellar/libpng' 'libpng'
################################################libpng##########################################################
####################################################nginx#######################################################
if [ ! `cat /etc/group | grep ${nginx_fpm_group}` ]
	then
	groupadd -g 1002 ${nginx_fpm_group}
fi
if [ ! `id -u ${nginx_fpm_user}` ]
	then
	useradd ${nginx_fpm_user} -r -g 1002
fi	
configure 'nginx-1.8.1.tar.gz' './nginx-1.8.1' "--prefix=/usr/local/Cellar/nginx --conf-path=/usr/local/etc/nginx/nginx.conf --user=${nginx_fpm_user} --group=${nginx-fpm_group} --with-openssl=../openssl-1.0.2g --with-pcre=../pcre-8.38" 'nginx'
if [ -x /usr/local/Cellar/nginx/sbin/nginx ]
	then
	path=sbin/nginx
else
	path=bin/nginx
fi
chmod u+s "/usr/local/Cellar/nginx/""${path}"
ln -s "/usr/local/Cellar/nginx/""${path}" "/usr/local/""${path}"
####################################################nginx#######################################################
################################################libmcrypt############################################################
configure 'libmcrypt-2.5.7.tar.gz' './libmcrypt-2.5.7' '--prefix=/usr/local/Cellar/libmcrypt' 'libmcrypt'
################################################libmcrypt############################################################
################################################mhash############################################################
configure 'mhash-0.9.9.9.tar.gz' './mhash-0.9.9.9' '--prefix=/usr/local/Cellar/mhash' 'mhash'
################################################mhash############################################################
################################################gettext############################################################
configure 'gettext-0.19.7.tar.gz' './gettext-0.19.7' '--prefix=/usr/local/Cellar/gettext' 'gettext'
################################################gettext############################################################
################################################jpeg############################################################
# if [ ! -d /usr/local/Cellar/libjpeg/bin ]
# 	then
# 	mkdir  /usr/local/Cellar/libjpeg/bin /usr/local/Cellar/libjpeg/include /usr/local/Cellar/libjpeg/lib
# 	mkdir -p /usr/local/Cellar/libjpeg/man/man1
# fi
# configure 'jpegsrc.v6b.tar.gz' './jpeg-6b' '--prefix=/usr/local/Cellar/libjpeg' 'libjpeg'
################################################jpeg############################################################
################################################freetds############################################################
#configure 'freetds-0.91.100.tar.gz' './freetds-0.91.100' '--prefix=/usr/local/Cellar/freetds' 'freetds'
################################################freetds############################################################
################################################freetype############################################################
configure 'freetype-2.4.0.tar.gz' './freetype-2.4.0' '--prefix=/usr/local/Cellar/freetype' 'freetype'
################################################freetype############################################################
####################################################php#######################################################
configure 'php-5.6.19.tar.gz' './php-5.6.19' "--prefix=/usr/local/Cellar/php5 --with-fpm-user=${nginx_fpm_user} --with-fpm-group=${nginx-fpm_group} --sysconfdir=/usr/local/etc/php5 --with-config-file-path=/usr/local/etc/php5 --with-config-file-scan-dir=/usr/local/etc/php5/conf.d --mandir=/usr/local/Cellar/php5/share/man --enable-calendar --enable-dba --enable-ftp --enable-gd-native-ttf --enable-mbregex --enable-mbstring --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --with-freetype-dir=/usr/local/Cellar/freetype --with-gd --with-gettext=/usr/local/Cellar/gettext --with-iconv-dir=/usr --with-jpeg-dir=/usr/lib --with-mhash=/usr/local/Cellar/mhash --with-mcrypt=/usr/local/Cellar/libmcrypt --with-png-dir=/usr/local/Cellar/libpng --with-xmlrpc --with-zlib=/usr --without-gmp --without-snmp --with-libxml-dir=/usr/local/Cellar/libxml2 --libexecdir=/usr/local/Cellar/php5/libexec --with-bz2=/usr/local --enable-debug --with-openssl=/usr/local/Cellar/openssl --enable-fpm --with-fpm-user=${nginx_fpm_user} --with-fpm-group=${nginx_fpm_group} --with-curl=/usr/local/Cellar/libcurl --with-mysql-sock=/tmp/mysql.sock --with-mysqli=mysqlnd --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --enable-pcntl --enable-phpdbg --enable-zend-signals" 'php5'
####################################################php#########################################################