mongojs            = require 'mongojs'
Datastore          = require 'meshblu-core-datastore'
RevokeTokenByQuery = require '../src/revoke-token-by-query'

describe 'RevokeTokenByQuery', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid

    @datastore = new Datastore
      database: mongojs 'meshblu-core-task-check-token'
      collection: 'devices'

    @datastore.remove done

  beforeEach ->
    @sut = new RevokeTokenByQuery
      datastore: @datastore
      pepper: 'totally-a-secret'
      uuidAliasResolver: @uuidAliasResolver

  describe '->do', ->
    context 'when given a valid token', ->
      beforeEach (done) ->
        record =
          uuid: 'thank-you-for-considering'
          token: 'never-gonna-guess-me'
          meshblu:
            tokens:
              'ZOGZOX7K4XywpyNFjVS+6SfbXFux8FNW7VT6NWmsz6E=': {
                tag: 'hello'
              }
        @datastore.insert record, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'used-as-biofuel'
            auth:
              uuid: 'thank-you-for-considering'
              token: 'the-environment'
          data:
            tag: 'hello'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expectedResponse =
          metadata:
            responseId: 'used-as-biofuel'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse
