
require('coffee-script/register');
var _ = require('lodash');
var git = require('git-rev-sync');
var argv = require('minimist')(process.argv.slice(2));

if(argv.v) {
    console.log(git.tag());
    return;
}

if(argv.h) {
    console.log('-h\n\tShow this help');
    console.log('-v\n\tPrint doks version');
    console.log('--file fileName\n\tSpecify a file for configuring parser - defaults to doks.json');
    return;
}

var Parser = require("./parser.coffee");
var fileName = _.isString(argv.file) ? argv.file : 'doks.json';
var parser = new Parser({config: fileName});

if(parser.options.keySort.length > 0) {
    parser.write(parser.parseIntoTree);
} else {
    parser.write();
}
