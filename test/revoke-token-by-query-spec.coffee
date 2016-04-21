mongojs            = require 'mongojs'
Datastore          = require 'meshblu-core-datastore'
redis              = require 'fakeredis'
uuid               = require 'uuid'
RevokeTokenByQuery = require '../src/revoke-token-by-query'

describe 'RevokeTokenByQuery', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    @redisKey = uuid.v1()
    @cache = redis.createClient @redisKey

    database = mongojs 'meshblu-core-task-check-token', ['devices']
    @datastore = new Datastore
      database: database
      collection: 'devices'

    database.devices.remove done

  beforeEach ->
    @sut = new RevokeTokenByQuery
      cache: @cache
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
        @cache.set 'thank-you-for-considering:ZOGZOX7K4XywpyNFjVS+6SfbXFux8FNW7VT6NWmsz6E=', 'set', done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'used-as-biofuel'
            auth:
              uuid: 'thank-you-for-considering'
              token: 'the-environment'
          rawData:
            '{"tag":"hello"}'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expectedResponse =
          metadata:
            responseId: 'used-as-biofuel'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

      it 'should not have the token in the cache', (done)->
        @cache.exists 'thank-you-for-considering:ZOGZOX7K4XywpyNFjVS+6SfbXFux8FNW7VT6NWmsz6E=', (error, result) =>
          expect(result).to.equal 0
          done()
