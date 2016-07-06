_                  = require 'lodash'
mongojs            = require 'mongojs'
Datastore          = require 'meshblu-core-datastore'
RevokeTokenByQuery = require '../src/revoke-token-by-query'

describe 'RevokeTokenByQuery', ->
  beforeEach (done) ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid

    database = mongojs 'meshblu-core-task-check-token', ['tokens']
    @datastore = new Datastore
      database: database
      collection: 'tokens'

    database.tokens.remove done

  beforeEach ->
    @sut = new RevokeTokenByQuery
      datastore: @datastore
      pepper: 'totally-a-secret'
      uuidAliasResolver: @uuidAliasResolver

  describe '->do', ->
    context 'when given a valid token', ->
      beforeEach (done) ->
        record = [
          {
            uuid: 'thank-you-for-considering'
            hashedToken: 'ZOGZOX7K4XywpyNFjVS+6SfbXFux8FNW7VT6NWmsz6E='
            metadata:
              tag: 'hello'
          },
          {
            uuid: 'thank-you-for-considering'
            hashedToken: 'bOT5i3r4bUXvG5owgEVUBOtnF30zyuShfocALDoi1HA='
            metadata:
              tag: 'hello'
          }
          {
            uuid: 'thank-you-for-considering'
            hashedToken: 'T/GMBdFNOc9l3uagnYZSwgFfjtp8Vlf6ryltQUEUY1U='
            metadata:
              tag: 'not-this-one'
          }
        ]
        @datastore.insert record, done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'used-as-biofuel'
            toUuid: 'thank-you-for-considering'
            auth:
              uuid: 'should-not-use-this-uuid'
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

      it 'should have the one remainder token', (done) ->
        @datastore.find { uuid: 'thank-you-for-considering' }, (error, records) =>
          return done error if error?
          expect(_.map(records, 'hashedToken')).to.deep.equal [
            'T/GMBdFNOc9l3uagnYZSwgFfjtp8Vlf6ryltQUEUY1U='
          ]
          done()
