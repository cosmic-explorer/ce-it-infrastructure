const fs = require('fs');
const qs = require('qs');
const fetch = require("node-fetch");

const checkToken = async token => {
  const body = qs.stringify({ token })

  const response = await fetch('http://oauth-server:4445/oauth2/introspect', {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Forwarded-Proto': 'https',
        'Content-Length': body.length
      },
      method: 'POST', body
  } )

  const json = await response.json()

  if (json['active'] !== true) throw new Error('Token not authorized')
  if (json['token_type'] !== 'access_token') throw new Error('Token is not access token')

  console.log('Authorized connection from ' + json['sub'])
}

module.exports = async (req, res, next) => {
  try {

    const { authorization } = req.headers
    if (!authorization) throw new Error('You must send an Authorization header')

    const [authType, token] = authorization.trim().split(' ')
    console.log(authType + ' ' + token)
    if (authType !== 'Bearer') throw new Error('Expected a Bearer token')

    await checkToken(token);

    next()
  } catch (error) {
    next(error.message)
  }
}
