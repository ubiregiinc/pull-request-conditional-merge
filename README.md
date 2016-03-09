# Pull Request Conditional Merge

This library is implement a bot to merge your pull request when CI passes.

You CI does not finish instantly; running tests takes minutes, or many jobs already may be queued.
Then, you may have said something like this:

> Okay, I will merge this PR once CI passes.

This does not make you feel nice.
You have to remember PRs you have to merge it later.
You may forget a PR to be merged fixing serious typo on your web site and should be deployed as soon as possible.

You definitely need a bot to merge PR automatically, when CI got green.

![Pull Request merged by bot](https://raw.githubusercontent.com/soutaro/pull-request-conditional-merge/master/merged-by-bot.png)

This library is to merge PR when:

* The PR is labeled with `ShipIt` (you can customize the name of label)
* All CIs associated with the PR succeeded

## Getting Started

### 1. Install

```
$ npm install --save pull-request-conditional-merge
```

### 2. Add new action to your web app (maybe Hubot?)

```coffee
PullRequestConditionalMerge = require("pull-request-conditional-merge")

module.exports = (robot) ->
  github = require('githubot')(robot)

  robot.router.post "/merge-pullrequest", (req, res) ->
    res.end ""

    return unless req.get('X-Github-Event') == "status"

    data = req.body
    repo = data.name.split('/')[1]
    sha = data.sha

    robot.logger.debug "Receiving hook: repo=#{repo}, sha=#{sha}"

    PullRequestConditionalMerge.find github, owner: "your-company", repo: repo, sha: sha, (pr) ->
      if pr
        robot.logger.debug "Found a PR: #{pr.pull.url}"
        pr.mergeIfReady ->
          robot.logger.debug "#{pr.pull.url} has been merged!"
      else
        robot.logger.debug "No PR found..."
```

### 3. Setup a status hook on your GitHub repo

`status` hook is the one you need.

## Customization

### Label name

If you do not like `ShipIt` label, you can use your own label name.

```coffee
PullRequestConditionalMerge.find github, owner: owner, repo: repo, sha: sha, (pr) ->
  pr.label = "MergeIt"
```

### Logger

You can assign `logger` property.
`debug` is the only level the library is using now.

```coffee
PullRequestConditionalMerge.find github, owner: owner, repo: repo, sha: sha, (pr) ->
  pr.logger = {
    debug: (message) -> console.log(message)
  }
```

With hubot:

```coffee
PullRequestConditionalMerge.find github, owner: owner, repo: repo, sha: sha, (pr) ->
  pr.logger = robot
```

### Commit message

The default commit message is:

```
Merge pull request #3381, via bot
```

Assign a function to `commitMessage` to customize the message:

```
PullRequestConditionalMerge.find github, owner: owner, repo: repo, sha: sha, (pr) ->
  pr.commitMessage = -> "Merge by bot"
```

## Author

Soutaro Matsumoto (matsumoto@soutaro.com)
