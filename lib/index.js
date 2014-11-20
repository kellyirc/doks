
require('coffee-script/register');

var Parser = require("./parser.coffee");
var parser = new Parser({config: "doks.json"});

parser.write();