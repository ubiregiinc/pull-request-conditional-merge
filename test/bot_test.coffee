test = require("ava")
nock = require('nock')
github = require('githubot')
httpMocks = require('node-mocks-http')

PRCM = require('../src/pull-request-conditional-merge')
Exp = require('../src/express')

scopes = {}

test.beforeEach =>
  scopes = {}

  nock('https://api.github.com')
    .get('/repos/soutaro/reponame/pulls')
    .reply(200, [
      {
        number: 1,
        url: "https://api.github.com/repos/soutaro/reponame/pulls/1",
        head: {
          sha: "1234567890"
        }
        state: "open",
        _links: {
          issue: {
            href: "https://api.github.com/repos/soutaro/reponame/issues/1"
          },
          statuses: {
            href: "https://api.github.com/repos/soutaro/reponame/statuses/xyzzy"
          }
        }
      },
    ])

  nock('https://api.github.com')
    .get('/repos/soutaro/reponame/issues/1')
    .reply(200, {
      labels: [
        { name: "Bug" },
        { name: "ShipIt" }
      ]
    })

  nock('https://api.github.com')
    .get('/repos/soutaro/reponame/statuses/xyzzy')
    .reply(200, [
      {
        context: "ci/pr",
        state: "success"
      }
    ])

  scopes.merge = nock('https://api.github.com')
    .put('/repos/soutaro/reponame/pulls/1/merge')
    .reply(200, {})

test.afterEach =>
  scopes = {}
  nock.restore()

test.cb "actions merges pull request", (t) =>
  request = httpMocks.createRequest
    method: 'POST'
    url: "dummy",
    headers:
      "X-Github-Event": "status"
    body:
      name: "mojombo/reponame"
      sha: "1234567890"

  response = httpMocks.createResponse()

  action = Exp.action PRCM, github, null, "soutaro", null, ->
    t.truthy scopes.merge.isDone()
    t.is response.statusCode, 200
    t.is response._getData(), ""
    t.end()

  action(request, response)

test.cb "action calls setup function", (t) =>
  request = httpMocks.createRequest
    method: 'POST'
    url: "dummy",
    headers:
      "X-Github-Event": "status"
    body:
      name: "mojombo/reponame"
      sha: "1234567890"

  response = httpMocks.createResponse()

  setupIsOK = false
  setup = (pr) ->
    setupIsOK = pr != null

  action = Exp.action PRCM, github, null, "soutaro", setup, ->
    t.truthy setupIsOK
    t.end()

  action(request, response)
