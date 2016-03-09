test = require("ava")
nock = require("nock")

PRCM = require('../src/pull-request-conditional-merge')

test "ready when open, label is given, CI passes", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open'
  }

  pr.issue = {
    labels: [
      { name: "ShipIt" }
      { name: "WIP" }
    ]
  }

  pr.statuses = [
    {
      context: "super-ci/pr"
      state: "success"
    },
    {
      context: "super-ci/pr"
      state: "pending"
    }
  ]

  t.ok pr.readyToMerge()

test "not ready when label is missing, CI passes", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open'
  }

  pr.issue = {
    labels: [
      { name: "WIP" }
    ]
  }

  pr.statuses = [
    {
      context: "super-ci/pr"
      state: "success"
    },
    {
      context: "super-ci/pr"
      state: "pending"
    }
  ]

  t.notOk pr.readyToMerge()

test "not ready when label is given, but CI fails", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open'
  }

  pr.issue = {
    labels: [
      { name: "ShipIt" }
    ]
  }

  pr.statuses = [
    {
      context: "super-ci/pr"
      state: "error"
    },
    {
      context: "super-ci/pr"
      state: "pending"
    }
  ]

  t.notOk pr.readyToMerge()

test "not ready when label is given, but some CI fails", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open'
  }

  pr.issue = {
    labels: [
      { name: "ShipIt" }
    ]
  }

  pr.statuses = [
    {
      context: "super-ci/pr"
      state: "success"
    },
    {
      context: "super-ci/push"
      state: "error"
    }
  ]

  t.notOk pr.readyToMerge()

test "not ready when label is given, but no CI succeeded", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open'
  }

  pr.issue = {
    labels: [
      { name: "ShipIt" }
    ]
  }

  pr.statuses = [
  ]

  t.notOk pr.readyToMerge()
