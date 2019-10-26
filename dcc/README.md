# CE DCC Image

This systems requres an image of the DCC VM `dcc-syr-disk0.qcow2`

Build using 
```sh
. build-dcc.sh
```
and deploy with
```sh
docker-compose up --detach
```

## Swarm Mode

To create the DCC swarm from an already populated database, run 
```sh
docker swarm init --advertise-addr 127.0.0.1
echo badgers | docker secret create mariadb_root_password -
echo herecomethebadgers | docker secret create mysql_docdbrw_passwd -
docker stack deploy --compose-file dcc.yml dcc
```

To access the database from other nodes in the swarm, run the commands:
```sql
GRANT USAGE ON *.* TO 'docdbrw'@'%' IDENTIFIED BY 'herecomethebadgers';
GRANT SELECT, INSERT, UPDATE, DELETE ON dcc_docdb.* TO 'docdbrw'@'%';
FLUSH PRIVILEGES;
```

