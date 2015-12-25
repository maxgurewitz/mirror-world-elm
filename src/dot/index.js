(function(){function index(it
/**/) {
var out='<!DOCTYPE html><html> <head> <script src="'+( it.projectName )+'/js/elm.js"></script> </head> <body style="margin: 0;"> <script> Elm.fullscreen(Elm.Main); </script> </body></html>';return out;
}var itself=index, _encodeHTML=(function (doNotSkipEncoded) {
		var encodeHTMLRules = { "&": "&#38;", "<": "&#60;", ">": "&#62;", '"': "&#34;", "'": "&#39;", "/": "&#47;" },
			matchHTML = doNotSkipEncoded ? /[&<>"'\/]/g : /&(?!#?\w+;)|<|>|"|'|\//g;
		return function(code) {
			return code ? code.toString().replace(matchHTML, function(m) {return encodeHTMLRules[m] || m;}) : "";
		};
	}());if(typeof module!=='undefined' && module.exports) module.exports=itself;else if(typeof define==='function')define(function(){return itself;});else {window.render=window.render||{};window.render['index']=itself;}}());