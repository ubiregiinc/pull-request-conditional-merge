test = require("ava")
nock = require("nock")

PRCM = require('../src/pull-request-conditional-merge')

test "ready when open, mergeable_state is clean", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open',
    labels: [
      { name: "ShipIt" },
      { name: "WIP" }
    ],
    mergeable_state: "clean"
  }

  t.truthy pr.readyToMerge()

test "not ready when open, mergeable_state is unknown", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open',
    labels: [
      { name: "ShipIt" },
      { name: "WIP" }
    ],
    mergeable_state: "unknown"
  }

  t.falsy pr.readyToMerge()

test "not ready when label is missing, mergeable_state is clean", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open',
    labels: [
      { name: "WIP" }
    ],
    mergeable_state: "clean"
  }

  t.falsy pr.readyToMerge()

test "not ready when label is given, but mergeable_state is unstable", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open',
    labels: [
      { name: "ShipIt" }
    ],
    mergeable_state: "unstable"
  }

  t.falsy pr.readyToMerge()

test "not ready when label is given, but mergeable_state is blocked", (t) ->
  pr = new PRCM()

  pr.pull = {
    state: 'open',
    labels: [
      { name: "ShipIt" }
    ],
    mergeable_state: "blocked"
  }

  t.falsy pr.readyToMerge()
