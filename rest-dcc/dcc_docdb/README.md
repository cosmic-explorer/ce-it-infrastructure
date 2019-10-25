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
sequelize-auto -h localhost -d dcc_docdb -u root -x xxxxxxx -o ./dcc_docdb -e mysql
```
The resultin tables can then be imported with
```
const Project = sequelize.import(__dirname + "/dcc_docdb")
```
