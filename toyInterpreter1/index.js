var parser = require("./parser.js");

 result = parser.parse("(+ 2 3 4)\n")


$scope = {};

debugger;

for ( var i=0, len=result.length; i<len; i++ ){
  console.log(result[i].eval($scope));
}
