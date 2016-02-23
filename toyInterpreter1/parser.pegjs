{

function Boolean(value){
	this.type = "Boolean";
	this.value= value;
}

var isBoolean=function(obj){
	return (obj instanceof Boolean);
}

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
  this.apply = body;
	this.argNum = argNum || -1;
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

function length(obj){
	if ( isNone(obj) ){
		return 0;
	}else if ( !isCons(obj) ){
		throw "Invalid length apply to non Cons";
	}else {
		return 1 + length(obj.tail);
	}
}

function $apply(code, args, globalEnv, scope){
	if ( isFunc(code) ){
		if ( code.name == "+" ){
			function tmpFunc(list, _global, _scope){
				if ( isNone(list) ) { return new Num(0);}
				else { return new Num($eval(list.head, _global, _scope).value + tmpFunc(list.tail, _global, _scope).value); }
			}
			return tmpFunc(args, globalEnv, scope );
		}
	}else {
		return new xError("can't be apply of code", {"code":code,"arguments":args});
	}
}

function $eval( _code, _globalEnv, _callerEnv )
{
	var code = _code || [];
	var globalEnv = _globalEnv || {};
	var callerEnv = _callerEnv || {};

	var scope = {"callerEnv":callerEnv};
	if ( code.__proto__ === Array.prototype ){
		for ( var idx=0; idx<code.length; idx++ ){
			console.log($eval( code[idx], globalEnv, callerEnv));
		}
	}else{
		switch (code.type){
			case "Number":
				return new Num(code.value);
				break;
			case "Boolean":
				return new Boolean(code.value);
				break;
			case "Cons":
				return $apply( $eval(code.head, globalEnv, scope), code.tail, globalEnv, callerEnv);
				break;
			case "Id":
				if (code.name == "+" ){
					return new Func("+", {});
				}
				break;
			default:
				return new xError("unknow type to Eval", code);
		}
	}
}

function Program( stmtList ){
	var program = this;
	this.stmtList = stmtList;
	this.eval = function(globalEnv){
		return $eval(program.stmtList, globalEnv);
	};
}

}



program = prog:(_ fac:factor _ {return fac})* {return new Program(prog);}

list = list:(item:factor _ {return item;})* { return ArrayToList(list); }

factor = symbol / word/ number / Boolean / ("(" _ l:list _ ")") {return l;}

symbol = sym:("+" / "-" / "*" / "/") { return new Id(sym); }

word = wordStart letter* { return new Id(text());}
wordStart = [a-zA-Z]
letter = [a-zA-Z0-9]


Boolean= BoolTrue / BoolFalse
BoolTrue='#t' { return new Boolean(true);}
BoolFalse='#f' { return new Boolean(false);}

number = integer { return new Num(parseInt(text())) }
integer = zero / (digit1_9 digit*)
digit1_9 = [1-9]
digit = [0-9]
zero = "0"

_ "whitespace" = (" " / "\r" / "\t" / "\n" / "\f")*
