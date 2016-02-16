var parser = require("./parser.js");

 result = parser.parse("(def x (+ 3 (/ 4 4)))(* x 3)\n")


$scope = {};

debugger;

for ( var i=0, len=result.length; i<len; i++ ){
  console.log(result[i].eval($scope));
}
