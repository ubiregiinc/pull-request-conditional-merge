test = require("ava")
sinon = require("sinon")
nock = require('nock')
github = require('githubot')

PRCM = require('../src/pull-request-conditional-merge')

test.cb "find yields if pull request for given commit hash found", (t) ->
  stub = nock('https://api.github.com')
          .get('/repos/soutaro/reponame/pulls')
          .reply(200, [
            {
              number: 1,
              head: {
                sha: "1234567890"
              }
            },
            {
              number: 2,
              head: {
                sha: "abcdefg"
              }
            }
          ])

  PRCM.find github, owner: "soutaro", repo: "reponame", sha: "1234567890", (pr) -> 
    t.is(pr.pull.number, 1)
    t.end()

test.cb "find yields null if no pull request found", (t) ->
  stub = nock('https://api.github.com')
          .get('/repos/soutaro/reponame/pulls')
          .reply(200, [
            {
              number: 1,
              head: {
                sha: "1234567890"
              }
            },
          ])

  PRCM.find github, owner: "soutaro", repo: "reponame", sha: "xyzzy", (pr) -> 
    t.is(pr, null)
    t.end()
