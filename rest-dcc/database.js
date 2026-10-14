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

// Lists are returned in full. finale-rest paginates at 100 rows by default and
// the COmanage provisioner reads only one page, which re-inserted every
// UsersGroup membership beyond the first 100 on each sync. All six tables are
// small enough to return whole.
const initializeDatabase = async (app) => {
  finale.initialize({ app, sequelize: database })

  finale.resource({
    model: Author,
    endpoints: ['/Author', '/Author/:AuthorID' ],
    pagination: false
  })

  finale.resource({
    model: EmailUser,
    endpoints: ['/EmailUser', '/EmailUser/:EmailUserID' ],
    pagination: false
  })

  finale.resource({
    model: Institution,
    endpoints: ['/Institution', '/Institution/:InstitutionID' ],
    pagination: false
  })

  finale.resource({
    model: UsersGroup,
    endpoints: ['/UsersGroup', '/UsersGroup/:UsersGroupID' ],
    pagination: false
  })

  finale.resource({
    model: RemoteUser,
    endpoints: ['/RemoteUser', '/RemoteUser/:RemoteUserID' ],
    pagination: false
  })

  finale.resource({
    model: SecurityGroup,
    endpoints: ['/SecurityGroup', '/SecurityGroup/:GroupID' ],
    pagination: false
  })

  await database.authenticate()
}

module.exports = initializeDatabase
