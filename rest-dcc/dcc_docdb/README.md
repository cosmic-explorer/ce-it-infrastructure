# DCC Database Tables

The interface uses [Sequelize](https://sequelize.readthedocs.io/en/v3/) which
requires information on the database tables. The files in this directory contains
the tables extracted from an existing DCC database using `sequelize-auto`. To
create these files, install `sequelize-auto` globally
```sh
npm install -g sequelize-auto mysql
```
and run
```sh
sequelize-auto -h localhost -d dcc_docdb -u docdbrw -x herecomethebadgers -o ./dcc_docdb -e mariadb
```
The resultin tables can then be imported with
```
const Project = database.import(__dirname + "/dcc_docdb")
```

The files produced by `sequelize-auto` fail [JavaScript Standard Style](https://standardjs.com/)
but this can be fixed by running `standard --fix`.
