TokenManager = require 'meshblu-core-manager-token'
http = require 'http'

class RevokeTokenByQuery
  constructor: (options={}) ->
    {@datastore,cache,pepper,uuidAliasResolver} = options
    @tokenManager = new TokenManager {@datastore, cache, pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {toUuid} = request.metadata
    data = JSON.parse request.rawData
    @tokenManager.revokeTokenByQuery {uuid: toUuid, data}, (error) =>
      return callback error if error?
      return @_doCallback request, 204, callback

module.exports = RevokeTokenByQuery
