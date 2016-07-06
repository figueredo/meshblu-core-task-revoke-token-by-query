TokenManager = require 'meshblu-core-manager-token'
http = require 'http'

class RevokeTokenByQuery
  constructor: ({datastore,pepper,uuidAliasResolver}) ->
    @tokenManager = new TokenManager {datastore, pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {toUuid} = request.metadata
    uuid = toUuid
    query = JSON.parse request.rawData
    @tokenManager.revokeTokenByQuery {uuid, query}, (error) =>
      return callback error if error?
      return @_doCallback request, 204, callback

module.exports = RevokeTokenByQuery
