JDK_ARCHIVE=jdk-7-linux-x64.tar.gz
if [ ! -f $CACHE_DIR/$JDK_ARCHIVE ];then

    JDK_URL=http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.tar.gz

    wget --no-cookies \
    --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    $JDK_URL \
    -O $CACHE_DIR/$JDK_ARCHIVE

    echo 22761b214b1505f1a9671b124b0f44f4 > $JDK_ARCHIVE.md5

fi