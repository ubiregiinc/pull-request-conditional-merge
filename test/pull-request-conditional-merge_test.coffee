test = require("ava")
nock = require('nock')
github = require('githubot')

PRCM = require('../src/pull-request-conditional-merge')

test.cb "find pull request, fetch detail for mergeable_state, and merge", (t) ->
  nock('https://api.github.com')
    .get('/repos/soutaro/reponame/pulls')
    .reply(200, [
      {
        number: 1,
        url: "https://api.github.com/repos/soutaro/reponame/pulls/1",
        head: {
          sha: "1234567890"
        }
      },
    ])

  nock('https://api.github.com')
    .get('/repos/soutaro/reponame/pulls/1')
    .reply(200, {
      url: "https://api.github.com/repos/soutaro/reponame/pulls/1",
      head: {
        sha: "1234567890"
      },
      state: "open",
      labels: [
        { name: "Bug" },
        { name: "ShipIt" }
      ],
      mergeable_state: "clean"
    })

  nock('https://api.github.com')
    .put('/repos/soutaro/reponame/pulls/1/merge')
    .reply(200, {})

  PRCM.find github, owner: "soutaro", repo: "reponame", sha: "1234567890", (pr) -> 
    pr.mergeIfReady ->
      t.end()
