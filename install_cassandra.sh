#!/bin/bash
# script assumes that everything will be done in the directory it is started from
# aka it uses relative paths.

# ensure that the script is run as root, otherwise fail
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# download Cassandra 3.11.5 
# use curl as it comes pre-packaged with most Linux OSs
# curl -o apache-cassandra-3.11.5-bin.tar.gz https://www-eu.apache.org/dist/cassandra/3.11.5/apache-cassandra-3.11.5-bin.tar.gz

# unarchive the download
# -v means verbose - show files being extracted
# -x extract files from the tar 
# -f the argument that follows is the name of the file to issue the command on
tar -xvf apache-cassandra-3.11.5-bin.tar.gz

# setup cassandra directories
# cassandra can do this itself but it's good to be explicit
mkdir apache-cassandra-3.11.5/data/
mkdir apache-cassandra-3.11.5/data/commit_log
mkdir apache-cassandra-3.11.5/data/data
mkdir apache-cassandra-3.11.5/data/saved_caches
mkdir apache-cassandra-3.11.5/data/hints

# Cassandra uses a relative path for logs, data and other files and should be
# able to start without any re-configuration assuming the localhost hostname
# is available
# The & at the end means that Cassandra will start in the background, and not in 
# the shell running this script
# -R is required so Cassandra can be started by th root user
apache-cassandra-3.11.5/bin/cassandra -R &

# wait 30 seconds to allow cassandra to start
echo "Sleeping for 30 seconds..."
sleep 30

# the -e stands for 'execute' - allowing for the command to take a query as a parameter
# Create a keyspace
# As this is a single node, SimpleStrategy can be used and replication_factor has to be 1. 
apache-cassandra-3.11.5/bin/cqlsh -e "CREATE KEYSPACE firstks WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};"
# Create a table for that keyspace
apache-cassandra-3.11.5/bin/cqlsh -e "CREATE TABLE firstks.test(id uuid PRIMARY KEY, value text);"
# Insert some data
apache-cassandra-3.11.5/bin/cqlsh -e "INSERT INTO firstks.test(id, value) VALUES (now(), 'aaaa');"
# read the data back
apache-cassandra-3.11.5/bin/cqlsh -e "SELECT * FROM firstks.test;"
