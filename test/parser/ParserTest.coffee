
Parser = require "../../lib/parser"

parser = new Parser
  language: "coffee"
  glob: "test/samples/Math.coffee"
  arrayTags: [
    'param'
  ]
  #defaults:
  #  testProp: true
    # will not overwrite if the property exists!

    # object format needs to be noted: {basicInfo} etc, so people can specify sane defaults

console.log "==COFFEE=="
parser.write()
console.log parser.parse()

parser = new Parser
  language: "js"
  glob: "test/samples/Math.js"
  arrayTags: [
    'param'
  ]

console.log "==JS=="
#console.log parser.parse()