
Parser = require "../../lib/parser"

parser = new Parser
  language: "coffee"
  glob: "test/samples/Math.coffee"
  arrayTags: [
    'param'
  ]

console.log "==COFFEE=="
parser.write()

parser = new Parser
  language: "js"
  glob: "test/samples/Math.js"
  arrayTags: [
    'param'
  ]

console.log "==JS=="
console.log parser.parse()