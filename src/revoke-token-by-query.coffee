TokenManager = require 'meshblu-core-manager-token'
http = require 'http'

class RevokeTokenByQuery
  constructor: (options={}) ->
    {@datastore,pepper,uuidAliasResolver} = options
    @tokenManager = new TokenManager {@datastore, pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid} = request.metadata.auth
    return @_doCallback request, 422, callback unless uuid?

    @tokenManager.revokeTokenByQuery uuid, request.data, (error, verified) =>
      return callback error if error?
      return @_doCallback request, (if verified then 204 else 422), callback

module.exports = RevokeTokenByQuery
