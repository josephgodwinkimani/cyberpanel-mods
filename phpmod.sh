#!/bin/bash

echo "Default PHP version changer for cyberpanel apps"
echo "Version chosen here will be used for phpmyadmin / snappymail"
echo ""

## read php version from input and configures it
read -r -p "Choose one of the following php versions [53-54-55-56-70-71-72-73-74-80-81-82-83]: " Input_Number
echo ""

case "$Input_Number" in
  53)
    if [ -f /usr/local/lsws/lsphp53/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp53/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 5.3"
    else
      echo "ERROR! Missing PHP 5.3? Check if /usr/local/lsws/lsphp53 exists."
    fi
    ;;
  54)
    if [ -f /usr/local/lsws/lsphp54/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 5.4"
    else
      echo "ERROR! Missing PHP 5.4? Check if /usr/local/lsws/lsphp54 exists."
    fi
    ;;
  55)
    if [ -f /usr/local/lsws/lsphp55/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp55/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 5.5"
    else
      echo "ERROR! Missing PHP 5.5? Check if /usr/local/lsws/lsphp55 exists."
    fi
    ;;
  56)
    if [ -f /usr/local/lsws/lsphp56/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 5.6"
    else
      echo "ERROR! Missing PHP 5.6? Check if /usr/local/lsws/lsphp56 exists."
    fi
    ;;
  70)
    if [ -f /usr/local/lsws/lsphp70/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp70/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 7.0"
    else
      echo "ERROR! Missing PHP 7.0? Check if /usr/local/lsws/lsphp70 exists."
    fi
    ;;
  71)
    if [ -f /usr/local/lsws/lsphp71/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp71/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 7.1"
    else
      echo "ERROR! Missing PHP 7.1? Check if /usr/local/lsws/lsphp71 exists."
    fi
    ;;
  72)
    if [ -f /usr/local/lsws/lsphp72/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp72/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 7.2"
    else
      echo "ERROR! Missing PHP 7.2? Check if /usr/local/lsws/lsphp72 exists."
    fi
    ;;
  73)
    if [ -f /usr/local/lsws/lsphp73/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 7.3"
    else
      echo "ERROR! Missing PHP 7.3? Check if /usr/local/lsws/lsphp73 exists."
    fi
    ;;
  74)
    if [ -f /usr/local/lsws/lsphp74/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp74/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 7.4"
    else
      echo "ERROR! Missing PHP 7.4? Check if /usr/local/lsws/lsphp74 exists."
    fi
    ;;
  80)
    if [ -f /usr/local/lsws/lsphp80/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp80/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 8.0"
    else
      echo "ERROR! Missing PHP 8.0? Check if /usr/local/lsws/lsphp80 exists."
    fi
    ;;
  81)
    if [ -f /usr/local/lsws/lsphp81/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp81/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 8.1"
    else
      echo "ERROR! Missing PHP 8.1? Check if /usr/local/lsws/lsphp81 exists."
    fi
    ;;
  82)
    if [ -f /usr/local/lsws/lsphp82/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp82/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 8.2"
    else
      echo "ERROR! Missing PHP 8.2? Check if /usr/local/lsws/lsphp82 exists."
    fi
    ;;
  83)
    if [ -f /usr/local/lsws/lsphp83/bin/lsphp ]; then
      rm -f /usr/local/lscp/fcgi-bin/lsphp &&
      ln -s /usr/local/lsws/lsphp83/bin/lsphp /usr/local/lscp/fcgi-bin/lsphp
      echo "Changed default version to PHP 8.3"
    else
      echo "ERROR! Missing PHP 8.3? Check if /usr/local/lsws/lsphp83 exists."
    fi
    ;;
  *)
    echo -e "Please write php version in the following format [53-54-55-56-70-71-72-73-74-80-81-82-83]\n"
    exit
    ;;
esac
