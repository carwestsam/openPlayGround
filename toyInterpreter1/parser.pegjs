{

function Num( number ){
	this.type = "Number";
  this.value = number;
}

var isNum = function(obj){
	return ( obj instanceof Num );
}

function Id( name ){
	this.type = "Id";
  this.name = name;
}

var isId = function(obj){
	return ( obj instanceof Id );
}

function None(){
  this.type = "None";
}

var isNone = function(obj){
	return ( obj instanceof None );
}


function xError(msg, obj){
  this.type = "xError";
  this.msg = msg;
	this.obj = obj || {};
  console.log("xError", msg, obj);
}

function Func(name, body, argNum){
  this.type = "Function";
	this.name = name;
  //this.apply = body;
	this.argNum = argNum || -1;

	var $this = this;
	this.apply = function(env, args){
		if ( argNum>=0 && length(args)!=$this.argNum ){
			return new xError("Function " + $this.name + " expected " + argNum + " argument(s) but got " + length(args));
		}
		debugger;
		return body(env, args);
	}
}

var isFunc = function(obj){
	return ( obj instanceof Func );
}

function Cons(head, tail){
  this.type = "Cons";
  this.head = head;
  this.tail = tail;
}
var isCons = function(obj){
	return ( obj instanceof Cons );
}
var isConsOrNone = function(obj){
	return isCons(obj) || isNone(obj);
}


function ArrayToList(array){
	function combine(idx, len, array){
    	if ( idx + 1 == len ){
        	return new Cons(array[idx], new None());
        }else {
        	return new Cons(array[idx], combine(idx+1, len, array));
        }
    }

    var len = array.length;
    if ( len == 0 ){
    	return new None();
    }else {
    	return combine(0, array.length, array );
    }
}

Array.prototype.eval = function(env){
	for ( var i=0, len=this.length; i<len; i++ ){
    	this[i].eval(env);
    }
}

var basicFuncBuilder = function ( name, coreFunc ){
	var inter = function (env, args){
		if ( args.type == "None" ){
			return inter;
		}else if ( args.type == "Cons" ){
			if ( args.tail.type == "None" ){
				return new Num( ((args.head).eval(env)).value );
			}else {
				return new Num( coreFunc( ((args.head).eval(env)).value, inter(env, args.tail).value ));
			}
		}
	}
	return new Func(name, function(env, args){
		return inter(env, args);
	});
}

var define = new Func("define", function(env, args){
	if ( length(args) != 2 ){
		return new xError("def accept 2 arguments");
	}
	env[(args.head).name] = ((args.tail).head).eval(env);
	return new None();
});

var lambda = new Func("lambda", function(env, args){
	if ( !isCons(args) || !isConsOrNone(args.head) || !isCons(args.tail)  ){
		return new xError("invalid lambda format");
	}

	var tmpObj = args;
	while ( !isNone(tmpObj) ){
		if (!isId(tmpObj.head)){
			return new xError("invalid lambda param list");
		}
		tmpObj = tmpObj.tail;
	}

	return new Func("anonymous", function(e, a){

	}, length(args.head));
})

var internalFunctions = {
	"+": basicFuncBuilder("+", function(a,b) { return a+b;}),
	"-": basicFuncBuilder("-", function(a,b) { return a-b;}),
	"*": basicFuncBuilder("*", function(a,b) { return a*b;}),
	"/": basicFuncBuilder("/", function(a,b) { return a/b;}),
	"def": define,
	"lambda" : lambda
};


Id.prototype.eval = function(env){
	if ( internalFunctions.hasOwnProperty(this.name) ){
    	return internalFunctions[this.name];
	}else if ( env.hasOwnProperty( this.name ) ){
    	return env[this.name];
  }else {
    	return new xError("Id work xError", this);
  }
}

xError.prototype.eval = function(env){
	return this;
}

Cons.prototype.eval = function(env){
	var head = (this.head).eval(env);
    if ( head.type == "Function" ){
    	return head.apply( env, this.tail );
    }else {
    	return new xError("can't be apply", this);
    }
}

function length(obj){
	if ( isNone(obj) ){
		return 0;
	}else if ( !isCons(obj) ){
		throw "Invalid length apply to non Cons";
	}else {
		return 1 + length(obj.tail);
	}
}

Num.prototype.eval = function(env){
	return this;
}


}

program = (_ fac:factor _ {return fac;})*

list = list:(item:factor _ {return item;})* { return ArrayToList(list); }

factor = symbol / word/ number / ("(" _ l:list _ ")") {return l;}

symbol = sym:("+" / "-" / "*" / "/") { return new Id(sym); }

word = wordStart letter* { return new Id(text());}
wordStart = [a-zA-Z]
letter = [a-zA-Z0-9]

number = integer { return new Num(parseInt(text())) }
integer = zero / (digit1_9 digit*)
digit1_9 = [1-9]
digit = [0-9]
zero = "0"

_ "whitespace" = (" " / "\r" / "\t" / "\n" / "\f")*
