var readline = require('readline'),
    rl = readline.createInterface(process.stdin, process.stdout);
var parser = require("./parser.js");

rl.setPrompt('ischeme> ');
rl.prompt();

$scope = {}

rl.on('line', function(line) {
    var result = parser.parse(line);
    for ( var i=0, len=result.length; i<len; i++ ){
      console.log(result[i].eval($scope));
    }
    rl.prompt();
}).on('close', function() {
    console.log('Have a great day!');
    process.exit(0);
});
