function tap_formerror(str,frm) { var html = ""; 
	var node = frm.nodeName.toLowerCase(); if (node != 'form') { frm = frm.form; } 
	var presenter = (typeof frm.tap_errorelement != 'undefined')? frm.tap_errorelement: null; 
	
	if (presenter != null) { 
		if (typeof presenter == 'string') { presenter = document.getElementById(presenter); } 
		if (presenter != null && typeof presenter.innerHTML != 'undefined') { 
			// provide css-class based formatting for multi-input form validators to match server-side validation 
			str = str.replace(/\n  ([^\n]+)/g,"<div>$1</div>"); 
			str = str.replace(/((<div>[^<]+<\/div>)+)/g,"<div class=\"tap_formvalidate_list\">$1</div>"); 
			
			// put each error on its own line 
			str = str.split("\n"); presenter.style.display = "block"; 
			for (var x = 0; x < str.length; x++) { html += "<div>" + str[x] + "</div>"; } 
			
			if (node=='form') { presenter.innerHTML = html; frm.tap_errorelement = null; return true; } 
			else { 
				if (presenter.innerHTML.toLowerCase().indexOf(html.toLowerCase()) < 0) { presenter.innerHTML += html; } 
				frm.tap_errorelement = null; return true; 
			} 
		} 
	} return alert(str); 
} 

function tap_inputvalue(input) { 
	input = (input.tagName.search(/(input|select|textarea|button)/i) >= 0)? input: input.getElementsByTagName('input')[0]; 
	var ival = (typeof input.value != 'undefined' && typeof input.checked == 'undefined')? input.value: null; 
	var x = 0; 
	
	if (typeof window[input.id + '_inputvalue'] != 'undefined') { return eval(input.id + '_inputvalue()'); } 
	
	if (input.type.toLowerCase() == 'select-multiple') { 
		ival = ''; 
		
		for (x = 0; x < input.length; x++) { 
			if (input.options[x].selected==true) { ival += ',' + input.options[x].value; } 
		} 
		
		ival = (ival.length==0)? null : ival.substring(1,ival.length); 
	} 
	else if (typeof input.checked != 'undefined') { 
		if (typeof input.name != 'undefined' && input.name.length > 0) { 
			input = input.form[input.name]; ival = ''; 
			
			if (typeof input.length != 'undefined') { 
				for (x = 0; x < input.length; x++) { 
					if ((typeof input[x].checked == 'undefined') || input[x].checked==true) { 
						if (typeof input[x].value != 'undefined') { ival += ',' + input[x].value; } 
					} 
				} 
				
				ival = (ival.length==0)? null : ival.substring(1,ival.length); 
			} else { ival = input.value; } 
		} else { ival = input.value; } 
	} 
	
	return (ival == null)? '': ival; 
} 

function tap_formvalues(frm) { 
	var field = (arguments.length > 1 && typeof arguments[1] == 'string')? arguments[1].toLowerCase(): null; 
	var x = 0; var input = null; var ivalue = null; 
	var formdata = new Object(); var iname = null; 
	for (var i = 0; i < frm.length; i++) { input = frm[i]; 
		if (typeof input.name != 'undefined' && input.name.length > 0) { 
			iname = input.name.toLowerCase(); 
			if (field == null || field == iname) { 
				if (input.type == 'button' || input.type == 'submit' || input.type == 'reset') { ; } // buttons shouldn't be used to transport data 
				else if (input.type == 'select-multiple') { 
					for (x = 0; x < input.length; x++) { 
						if (input.options[x].selected==true) { 
							formdata[iname] = (typeof formdata[iname] == 'undefined')? input.options[x].value : formdata[iname] + ',' + input.options[x].value; 
						} 
					} 
				} else if ((input.type != 'radio' && input.type != 'checkbox') || input.checked == true) { 
					formdata[iname] = (typeof formdata[iname] == 'undefined') ? input.value : formdata[iname] + ',' + input.value; 
				} 
			} 
		} 
	} 
	if (field == null) { return formdata; } 
	else { return (typeof formdata[field] == 'undefined')? '': formdata[field]; } 
} 

function tap_formpopulate(frm,formdata) { 
	var input = null; var iname = null; var x = null; 
	for (var i = 1; i < frm.length; i++) { input = frm[i]; 
		if (typeof input.name != 'undefined' && input.name.length > 0) { 
			iname = input.name.toLowerCase(); 
			if (typeof formdata[iname] != 'undefined') { 
				switch (input.type) {
					case 'radio': { ; } 
					case 'checkbox': { 
						input.checked = (new String(',' + formdata[iname] + ',').toLowerCase().indexOf(',' + input.value.toLowerCase() + ',') >= 0)? true : false; 
						break; 
					} 
					case 'select': { ; } 
					case 'select-one': { ; } 
					case 'select-mulitple': { 
						for (x = 0; x < input.length; x++) { 
							input.options[x].selected = (new String(',' + formdata[iname] + ',').toLowerCase().indexOf(',' + input.value.toLowerCase() + ',') >= 0)? true : false; 
						} break; 
					} 
					default: { input.value = formdata[iname]; } 
				} 
				if (typeof input.id != 'undefined' && input.id.length > 0 
				&& typeof eval(input.id + '_focus') != 'undefined') 
					{ eval(input.id + '_focus();'); } 
			} 
		} 
	} 
} 

function tap_requirefield(str) { return (typeof str=='string' && str.match(new RegExp('\\S'))!=null)? true: false; } 

function tap_inputislength(str,len) { return (tap_requirefield(str)==false || str.length == parseInt(len)); }  
function tap_inputislengthmax(str,len) { return (tap_requirefield(str)==false || str.length <= parseInt(len)); } 
function tap_inputislengthmin(str,len) { return (tap_requirefield(str)==false || str.length >= parseInt(len)); } 
function tap_inputislengthrange(str,range) { range = range.split(','); 
	return (tap_requirefield(str)==false || (str.length >= parseInt(range[0]) && str.length <= parseInt(range[1]))); 
} 

function tap_inputisemail(str) { 
	if (tap_requirefield(str)==false) { return true; } // don't check email format if no value is provided 
	else { return str.toLowerCase().match(new RegExp('^[a-z0-9][-.\\w]*@[-a-z0-9]+(\\.[a-z]{2,6}){1,3}$'))!=null; } 
} 

function tap_inputishttp(str) { 
	if (tap_requirefield(str)==false) { return true; } // don't check url format if no value is provided 
	else { return str.toLowerCase().match(new RegExp('^https?://([-a-z0-9]+\\.)?[-a-z0-9]+(\\.[a-z]{2,6}){1,3}([?/].*)?$'))!=null; } 
} 

function tap_inputisdate(str,format) { 
	if (tap_requirefield(str)==false) { return true; } // don't check the date format if no value is provided 
	else if (typeof tap_lsinputisdate == 'function') { return tap_lsinputisdate(str); } 
	else { return str.match(new RegExp(format))!=null; } 
} 

function tap_inputisnumeric(str) { if (tap_requirefield(str)==false) { return true; } else { return (isNaN(str) == false); } } 
function tap_inputisnumericmax(str,mx) { return (tap_requirefield(str)==false || (isNaN(str) == false && parseFloat(str) <= parseFloat(mx))); } 
function tap_inputisnumericmin(str,mn) { return (tap_requirefield(str)==false || (isNaN(str) == false && parseFloat(str) >= parseFloat(mn))); } 
function tap_inputisnumericrange(str,range) { 
	range = range.split(','); 
	if (tap_requirefield(str)==false) { return true; } 
	else if (isNaN(str)==true 
		|| parseFloat(str) < parseFloat(range[0]) 
		|| parseFloat(str) > parseFloat(range[1])) { return false; } 
	else { return true; } 
} 

function tap_getTabbedElement(container) { 
	container = (typeof container == 'string')? document.getElementById(container): container; 
	var child = container.childNodes; 
	var temp = null; 
	
	for (var i = 0; i < child.length; i++) { 
		if (child[i].tagName) { 
			if (child[i].tabIndex && child[i].tabIndex > 0) { return child[i]; } 
			temp = tap_getTabbedElement(child[i]); 
			if (temp != null) { return temp; } 
		} 
	} 
	
	return null; 
} 

function tap_focusTabbedElement(container) { 
	var element = tap_getTabbedElement(container); 
	if (element != null) { element.focus(); } 
} 

function tap_tabNext(input) { 
	var f = input.form; var index = input.tabIndex; 
	for (var i = 0; i < f.length; i++) { 
		if (f.elements[i].tabIndex > index) { f.elements[i].focus(); return; } 
	} input = f.elements[f.length=1]; 
	if (input.type != 'hidden') { f.focus(); } 
} 

function tap_importHTML(html,target) { 
	target = (typeof target == 'string')? document.getElementById(target): target; 
	var script = ""; 
	
	// unfortunately Internet Explorer won't allow the use of getElementsByTagName('script') 
	// the .innerHTML property doesn't include the elements after it's set 
	var ev = ""; if (html.search(/<\s*script/) >= 0) { 
		ev = "*" + html.replace(/(\/\/\]\]>(\s|\r|\n)*)?<\s*(\/?)\s*script[^>]*>((\s|\r|\n)*\/\/\s*<!\[CDATA\[)?/gi," <$3script> "); 
		ev = ev.split(/<\/?script>/g); 
		for (var i = 1; i < ev.length; i+=2) { script += ev[i] + "\r\n"; } 
	} 
	
	// don't include the script tags in other browsers to prevent possible duplication 
	target.innerHTML = html.replace(/<\s*script[^>]*>(.|\n|\r)*?<\s*\/\s*script\s*>/gi,""); 
	
	// install the javascript 
	if (script.length!=0) {  
		if (window.execScript) { window.execScript(script); } // msdn library says the 2nd argument is required, but IE7 disagrees 
		else { window.setTimeout(script,0); } 
	} 
} 

isMouseOut = function(event,e,check) { 
	var target = (typeof event.srcElement!='undefined')? event.srcElement: event.target; 
	for (var i in check) { 
		if (typeof target[i] != typeof check[i] || target[i] != check[i]) { return false; } 
	} 
	if (typeof e.offsetLeft == 'undefined') { return false; } 
	var x = e.offsetLeft; 
	var y = e.offsetTop; 
	var w = e.offsetWidth; 
	var h = e.offsetHeight; 
	
	while (e = e.offsetParent) {
		x += e.offsetLeft; 
		y += e.offsetTop; 
	} 
	var clientX = (event.pageX)? event.pageX: event.clientX; 
	var clientY = (event.pageY)? event.pageY: event.clientY; 
	
	return (clientX <= x || clientY <= y || clientX >= x + w || clientY >= y + h)? true: false; 
} 

function tapStopNonNumericInput(input,evt) { 
	var theKey = (evt.charCode)? evt.charCode: evt.keyCode; 
	if (typeof theKey == 'number') { 
		var theChar = String.fromCharCode(theKey); 
		if (",.".indexOf(theChar) >= 0 && input.value.indexOf(theChar) >= 0) { return false; } 
		if (theKey < 48) { return true; } 
		if (isNaN(input.value + theChar)==true) { return false; } 
	} 
	return true; 
} 

function tap_toggleTree(node) { 
	if (node.className.indexOf('closed') >= 0) 
		{ window.setTimeout(node.id + '_treeopen()',0); } 
	else { window.setTimeout(node.id + '_treeclose()',0); } 
} 

function tap_treeOpen(node) { 
	node.className = node.className.replace(/ closed$/,' open'); 
	node = document.getElementById(node.id + '_item'); 
	node.className = node.className.replace(/ closed$/,' open'); 
} 

function tap_treeClose(node) { 
	node.className = node.className.replace(/ open$/,' closed'); 
	node = document.getElementById(node.id + '_item'); 
	node.className = node.className.replace(/ open$/,' closed'); 
} 

