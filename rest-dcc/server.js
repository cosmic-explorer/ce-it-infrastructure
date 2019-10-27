const express = require('express')
const bodyParser = require('body-parser')
const { promisify } = require('util')
const waitPort = require('wait-port');

const databaseport = {
  host: 'docdb-database',
  port: 3306,
}

const initializeDatabase = require('./database')

const app = express()
app.use(bodyParser.json())

const startServer = async () => {
  await waitPort(databaseport)
    .then((open) => {
      if (open) console.log('MariaDB is now running')
      else console.log('The port did not open before the timeout...')
    })
    .catch((err) => {
      console.log(`An unknown error occured while waiting for the port: ${err}`)
    })

  await initializeDatabase(app)

  const port = process.env.SERVER_PORT || 8443
  await promisify(app.listen).bind(app)(port)
  console.log(`Listening on port ${port}`)
}

startServer()
