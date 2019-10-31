module.exports = async (req, res, next) => {
  try {
    const { authorization } = req.headers
    if (!authorization) throw new Error('You must send an Authorization header')

    const [authType, token] = authorization.trim().split(' ')
    console.log(authType + ' ' + token)
    if (authType !== 'Bearer') throw new Error('Expected a Bearer token')

    next()
  } catch (error) {
    next(error.message)
  }
}
