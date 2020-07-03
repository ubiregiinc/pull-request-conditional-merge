test = require("ava")
nock = require('nock')
github = require('githubot')

PRCM = require('../src/pull-request-conditional-merge')

test.cb "find pull request, fetch issue for label, fetch CI status, and merge", (t) ->
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

  nock('https://api.github.com')
    .get('/repos/soutaro/reponame/commits/xyzzy/check-runs')
    .reply(200, {
      check_runs: [
        status: "completed"
        conclusion: "success"
      ]
    })

  nock('https://api.github.com')
    .put('/repos/soutaro/reponame/pulls/1/merge')
    .reply(200, {})

  PRCM.find github, owner: "soutaro", repo: "reponame", sha: "1234567890", (pr) -> 
    pr.mergeIfReady ->
      t.end()
