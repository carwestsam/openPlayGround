var readline = require('readline'),
    rl = readline.createInterface(process.stdin, process.stdout);
var parser = require("./parser.js");

rl.setPrompt('ischeme> ');
rl.prompt();

$scope = {}

rl.on('line', function(line) {
    var program = parser.parse(line);
    program.eval($scope);
    rl.prompt();
}).on('close', function() {
    console.log('Have a great day!');
    process.exit(0);
});
