const fs = require('fs');
const  qs = require('qs');

try {
    var clientsecret = fs.readFileSync('/run/secrets/dcc_rest_secret', 'ascii');
    clientsecret = clientsecret.replace(/\n$/, '')
} catch(e) {
    console.log('Error:', e.stack);
}

module.exports = async (req, res, next) => {
  try {

    const { authorization } = req.headers
    if (!authorization) throw new Error('You must send an Authorization header')

    const [authType, token] = authorization.trim().split(' ')
    console.log(authType + ' ' + token)
    if (authType !== 'Bearer') throw new Error('Expected a Bearer token')

    const body = qs.stringify({ token })

    fetch('http://oauth-server:4445/oauth2/introspect', {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Forwarded-Proto': 'https',
          'Content-Length': body.length
        },
        method: 'POST', body
    }).then(body => {
        if (!body.active) {
            throw new Error('Token is not active')
        } else if (body.token_type !== 'access_token') {
            throw new Error('Token is not an access token')
        }
        console.log('authorized new connection')
    })

    next()
  } catch (error) {
    next(error.message)
  }
}
