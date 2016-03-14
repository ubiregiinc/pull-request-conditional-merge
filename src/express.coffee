Express = {}

Express.action = (PullRequestConditionalMerge, github, logger, owner, setup, callback) ->
  (req, res) ->
    res.end ""

    return unless req.get('X-Github-Event') == "status"

    data = req.body
    repo = data.name.split('/')[1]
    sha = data.sha

    logger?.debug "Receiving hook: repo=#{repo}, sha=#{sha}"

    PullRequestConditionalMerge.find github, owner: owner, repo: repo, sha: sha, (pr) ->
      if pr
        setup(pr) if setup?
        logger?.debug "Found a PR: #{pr.pull.url}"
        pr.mergeIfReady ->
          logger?.debug "#{pr.pull.url} has been merged!"
          callback() if callback?
      else
        logger?.debug "No PR found..."
        callback() if callback?

module.exports = Express
