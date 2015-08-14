#! /bin/bash
#
#     This file is part of the Squashtest platform.
#     Copyright (C) 2010 - 2012 Henix, henix.fr
#
#     See the NOTICE file distributed with this work for additional
#     information regarding copyright ownership.
#
#     This is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     this software is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with this software.  If not, see <http://www.gnu.org/licenses/>.
#


#That script will :
#- check that the java environnement exists,
#- the version is adequate,
#- will run the application


# Default variables
JAR_NAME="org.apache.felix.main-4.2.1.jar" # Java main library
HTTP_PORT=8080                             # Port for HTTP connector (default 8080; disable with -1)
# Directory variables
TMP_DIR=../tmp                             # Jetty tmp and work directory
BUNDLES_DIR=../bundles                     # Bundles directory
CACHE_DIR=..                               # Cache directory
CONF_DIR=../conf                           # Configurations directory
LOG_DIR=../logs                            # Log directory
JETTY_HOME=../jettyhome                    # Jetty home directory
LUCENE_DIR=../luceneindexes                # Lucene indexes directory
PLUGINS_DIR=../plugins                     # Plugins directory
# DataBase parameters
DB_URL=${DB_URL:-"jdbc:h2:../data/squash-tm"}           # DataBase URL
DB_DRIVER=${DB_DRIVER:-"org.h2.Driver"}                    # DataBase driver
DB_USERNAME=${DB_USERNAME:-"sa"}                             # DataBase username
DB_PASSWORD=${DB_PASSWORD:-"sa"}                             # DataBase password
DB_DIALECT=${DB_DIALECT:-"org.hibernate.dialect.H2Dialect"} # DataBase dialect
## Do not configure a third digit here
REQUIRED_VERSION=1.6
# Extra Java args
JAVA_ARGS=${JAVA_ARGS:-"-Xms128m -Xmx512m -XX:MaxPermSize=192m -server"}


# Tests if java exists
echo -n "$0 : checking java environment... ";

java_exists=`java -version 2>&1`;

if [ $? -eq 127 ]
then
    echo;
    echo "$0 : Error : java not found. Please ensure that \$JAVA_HOME points to the correct directory.";
    echo "If \$JAVA_HOME is correctly set, try exporting that variable and run that script again. Eg : ";
    echo "\$ export \$JAVA_HOME";
    echo "\$ ./$0";
    exit -1;
fi

echo "done";

# Create logs and tmp directories if necessary
if [ ! -e "$LOG_DIR" ]; then
    mkdir $LOG_DIR
fi

if [ ! -e "$TMP_DIR" ]; then
    mkdir $TMP_DIR
fi

# Tests if the version is high enough
echo -n "checking version... ";

NUMERIC_REQUIRED_VERSION=`echo $REQUIRED_VERSION |sed 's/\./0/g'`;
java_version=`echo $java_exists | grep version |cut -d " " -f 3  |sed 's/\"//g' | cut -d "." -f 1,2 | sed 's/\./0/g'`;

if [ $java_version -lt $NUMERIC_REQUIRED_VERSION ]
then
    echo;
    echo "$0 : Error : your JRE does not meet the requirements. Please install a new JRE, required version ${REQUIRED_VERSION}.";
    exit -2;
fi

echo  "done";


# Let's go !
echo "$0 : starting Felix... ";

export _JAVA_OPTIONS="-Ddb.driver=${DB_DRIVER} -Ddb.url=${DB_URL} -Ddb.username=${DB_USERNAME} -Ddb.password=${DB_PASSWORD} -Ddb.dialect=${DB_DIALECT} -Duser.language=en"
DAEMON_ARGS="${JAVA_ARGS} -Dbundles.dir=${BUNDLES_DIR} -Dcache.dir=${CACHE_DIR} -Dconf.dir=${CONF_DIR} -Dlog.dir=${LOG_DIR} -Dplugins.dir=${PLUGINS_DIR} -Djetty.logs=${LOG_DIR} -Dbundles.configuration.location=${CONF_DIR} -Dfelix.config.properties=file:${CONF_DIR}/felix.config.properties -Dfelix.system.properties=file:${CONF_DIR}/felix.system.properties -Djetty.port=${HTTP_PORT} -Djetty.home=${JETTY_HOME} -Dlucene.dir=${LUCENE_DIR} -Dgosh.args=--noi -Djava.io.tmpdir=${TMP_DIR} -Dlog4j.configuration=file:./conf/log4j.properties -jar ${JAR_NAME}"

find ${TMP_DIR} -delete > /dev/null 2>&1

exec java ${DAEMON_ARGS}

