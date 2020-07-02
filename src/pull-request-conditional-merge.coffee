groupBy = (array, group) ->
  result = {}

  array.forEach (x) =>
    k = group(x)
    if result[k]
      result[k].push(x)
    else
      result[k] = [x]

  xs = []

  for k,v of result
    xs.push(v)

  xs

# 
# pr = new PullRequestConditionalMerge(github, pull)
# pr.label = "ReadyToMerge"
# pr.logger = logger
# pr.commitMessage = -> "Merged by bot :imp:"
# pr.mergeIfReady()
# 
class PullRequestConditionalMerge
  constructor: (@github, @pull) ->
    @label = "ShipIt"
    @logger = null
    @commitMessage = -> "Merge pull request \##{@pull.number}, via bot"

  fetchIssue: (callback) ->
    @github.get @pull._links.issue.href, (@issue) =>
      callback()

  fetchStatus: (callback) ->
    @github.get @pull._links.statuses.href, (@statuses) =>
      callback()

  fetchCheckRuns: (callback) ->
    check_runs_url = @pull._links.statuses.href.replace(/^(.+)\/statuses\/(.+)$/, '$1/commits/$2/check-runs')
    @github.withOptions(apiVersion: 'antiope-preview').get check_runs_url, (res) =>
      @check_runs = res.check_runs
      callback()

  merge: (callback) ->
    url = @pull.url + "/merge"
    body = {
      commit_message: @commitMessage()
      sha: @pull.head.sha
    }
    @logger?.debug "Trying to merge #{@pull.url}, #{@pull.head.sha}..."
    @github.put url, body, callback

  readyToMerge: () ->
    hasLabel = @issue.labels.some (label) => label.name == @label
    ciSucceeds = groupBy @statuses, (status) ->
      status.context
    .every (ss) ->
      ss.some (s) ->
        s.state == "success"

    checkSucceeds = @check_runs.every (check) ->
      check.status == "completed" && check.conclusion == "success"

    checkLength = @statuses.length + @check_runs.length

    @logger?.debug "state = #{@pull.state}, hasLabel = #{hasLabel}, ciSucceeds = #{ciSucceeds}, checkSucceeds = #{checkSucceeds}"
    @pull.state == "open" && hasLabel && ciSucceeds && checkSucceeds && checkLength > 0

  mergeIfReady: (callback) ->
    @fetchIssue =>
      @logger?.debug "Fetched issue..."
      @fetchStatus =>
        @logger?.debug "Fetched status..."
        @fetchCheckRuns =>
          @logger?.debug "Fetched check-runs..."
          if @readyToMerge()
            @merge =>
              callback()

  # PullRequestConditionalMerge.find @github, owner: "ubiregiinc", repo: "ubiregi-server", sha: "12345678", (pr) =>
  #   ....
  @find: (github, { owner, repo, sha }, k) ->
    url = "https://api.github.com/repos/#{owner}/#{repo}/pulls"
    github.get url, (pulls) =>
      cm = null
      
      pulls.forEach (pull) =>
        if pull.head.sha == sha
          cm = new PullRequestConditionalMerge(github, pull)

      k(cm)

module.exports = PullRequestConditionalMerge
