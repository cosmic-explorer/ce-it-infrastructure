const Sequelize = require('sequelize')
const finale = require('finale-rest')
const path = require('path')

const database = new Sequelize('dcc_docdb', 'docdbrw', 'herecomethebadgers', {
  dialect: 'mariadb',
  host: 'localhost',
  operatorsAliases: false
})

const Docdb = database.import(path.join(__dirname, 'dcc_docdb/Author'))

const initializeDatabase = async (app) => {
  finale.initialize({ app, sequelize: database })

  finale.resource({
    model: Docdb,
    endpoints: ['/Author', '/Author/:id']
  })

  await database.authenticate()
}

module.exports = initializeDatabase
