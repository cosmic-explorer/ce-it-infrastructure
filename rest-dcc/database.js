const Sequelize = require('sequelize')
const finale = require('finale-rest')
const path = require('path')
const fs = require('fs');

try {
    var docdbpasswd = fs.readFileSync('/run/secrets/mysql_docdbrw_passwd', 'ascii');
    docdbpasswd = docdbpasswd.replace(/\n$/, '')
} catch(e) {
    console.log('Error:', e.stack);
}

const database = new Sequelize('dcc_docdb', 'docdbrw', docdbpasswd, {
  dialect: 'mariadb',
  host: 'docdb-database'
})

const Author = database.import(path.join(__dirname, 'dcc_docdb/Author'))
const Institution = database.import(path.join(__dirname, 'dcc_docdb/Institution'))
const EmailUser = database.import(path.join(__dirname, 'dcc_docdb/EmailUser'))
const UsersGroup = database.import(path.join(__dirname, 'dcc_docdb/UsersGroup'))
const RemoteUser = database.import(path.join(__dirname, 'dcc_docdb/RemoteUser'))
const SecurityGroup = database.import(path.join(__dirname, 'dcc_docdb/SecurityGroup'))

const initializeDatabase = async (app) => {
  finale.initialize({ app, sequelize: database })

  finale.resource({
    model: Author,
    endpoints: ['/Author', '/Author/:id' ]
  })

  finale.resource({
    model: EmailUser,
    endpoints: ['/EmailUser', '/EmailUser/:id' ]
  })

  finale.resource({
    model: Institution,
    endpoints: ['/Institution', '/Institution/:id' ]
  })

  finale.resource({
    model: UsersGroup,
    endpoints: ['/UsersGroup', '/UsersGroup/:id' ]
  })

  finale.resource({
    model: RemoteUser,
    endpoints: ['/RemoteUser', '/RemoteUser/:id' ]
  })

  finale.resource({
    model: SecurityGroup,
    endpoints: ['/SecurityGroup', '/SecurityGroup/:id' ]
  })

  await database.authenticate()
}

module.exports = initializeDatabase
