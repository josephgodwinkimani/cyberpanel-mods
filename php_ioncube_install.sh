#!/bin/bash

#ioncube_loader_installation

a=7.2
b=7.3
c=7.4
e=8.1

cd /usr/local/

sudo apt install wget -y

wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

tar -xvf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local

echo
echo

CURRENT=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")

echo "current php version of this system PHP-$CURRENT"

DISTRO=`cat /etc/*-release | grep "^ID=" | grep -E -o "[a-z]\w+"`

echo "Your operating system is $DISTRO"


if [  $CURRENT = $a ];
then

      if [ "$DISTRO" = "ubuntu" ]; then
      
         cp ioncube/ioncube_loader_lin_7.2.so /usr/local/lsws/lsphp72/lib/php/20170718/
         echo "zend_extension=ioncube_loader_lin_7.2.so" >> /usr/local/lsws/lsphp72/etc/php/7.2/mods-available/01-ioncube.ini     
         systemctl restart lsws
         echo "ioncube_loader_7.2 sucessfully installed"
         
      elif [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "almalinux" ]; then
      
        cp --verbose ioncube/ioncube_loader_lin_7.2.so /usr/local/lsws/lsphp72/lib64/php/modules/
        echo "zend_extension=ioncube_loader_lin_7.2.so" >> /usr/local/lsws/lsphp72/etc/php.d/01-ioncube.ini
        service lsws restart
        echo "ioncube_loader_7.2 sucessfully installed"
        
      else
         echo "$DISTRO"
         echo "Sorry this is not for you"
      fi


elif [  $CURRENT = $b  ];
then
      
      if [ "$DISTRO" = "ubuntu" ]; then
      
            cp ioncube/ioncube_loader_lin_7.3.so /usr/local/lsws/lsphp73/lib/php/20180731/
            echo "zend_extension=ioncube_loader_lin_7.2.so" >> /usr/local/lsws/lsphp73/etc/php/7.3/mods-available/01-ioncube.ini     
            systemctl restart lsws
            echo "ioncube_loader_7.3 sucessfully installed"
         
      elif [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "almalinux" ]; then
      
            cp --verbose ioncube/ioncube_loader_lin_7.3.so /usr/local/lsws/lsphp73/lib64/php/modules/
            echo "zend_extension=ioncube_loader_lin_7.3.so" >> /usr/local/lsws/lsphp73/etc/php.d/01-ioncube.ini
            service lsws restart
            echo "ioncube_loader_7.3 sucessfully installed"
        
      else
         echo "$DISTRO"
         echo "Sorry this is not for you"
      fi

elif [  $CURRENT = $c  ];
then
      
      if [ "$DISTRO" = "ubuntu" ]; then
      
            cp ioncube/ioncube_loader_lin_7.4.so /usr/local/lsws/lsphp74/lib/php/20190902/
            echo "zend_extension=ioncube_loader_lin_7.4.so" >> /usr/local/lsws/lsphp74/etc/php/7.4/mods-available/01-ioncube.ini     
            systemctl restart lsws
            echo "ioncube_loader_7.4 sucessfully installed"
         
      elif [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "almalinux" ]; then
      
            cp --verbose ioncube/ioncube_loader_lin_7.4.so /usr/local/lsws/lsphp74/lib64/php/modules/
            echo "zend_extension=ioncube_loader_lin_7.4.so" >> /usr/local/lsws/lsphp74/etc/php.d/01-ioncube.ini
            service lsws restart
            echo "ioncube_loader_7.4 sucessfully installed"
        
      else
         echo "$DISTRO"
         echo "Sorry this is not for you"
      fi

elif [  $CURRENT = $d  ];
then
      
      if [ "$DISTRO" = "ubuntu" ]; then
      
            cp ioncube/ioncube_loader_lin_8.1.so /usr/local/lsws/lsphp81/lib/php/20210902/
            echo "zend_extension=ioncube_loader_lin_8.1.so" >> /usr/local/lsws/lsphp81/etc/php/8.1/mods-available/01-ioncube.ini     
            systemctl restart lsws
            echo "ioncube_loader_8.1 sucessfully installed"
         
      elif [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "almalinux" ]; then
      
            cp --verbose ioncube/ioncube_loader_lin_8.1.so /usr/local/lsws/lsphp81/lib64/php/modules/
            echo "zend_extension=ioncube_loader_lin_8.1.so" >> /usr/local/lsws/lsphp81/etc/php.d/01-ioncube.ini
            service lsws restart
            echo "ioncube_loader_8.1 sucessfully installed"
        
      else
         echo "$DISTRO"
         echo "Sorry this is not for you"
      fi


else
   echo "None of the conditions met"
fi

cd /usr/local/
rm -rf ioncube_loaders_lin_x86-64.tar.gz

#ioncube_loader_installation
