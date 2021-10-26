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

  fetchPullDetail: (callback) ->
    @github.get @pull.url, (@pull) =>
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
    hasLabel = @pull.labels.some (label) => label.name == @label

    @logger?.debug "mergeable_state = #{@pull.mergeable_state}, hasLabel = #{hasLabel}"
    @pull.state == "open" && hasLabel && @pull.mergeable_state == "clean"

  mergeIfReady: (callback) ->
    @fetchPullDetail =>
      @logger?.debug "Fetched pull detail..."
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
