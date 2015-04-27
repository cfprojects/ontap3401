function getVar(varname,def) { 
	var myvalue = new String(eval("_level0." + varname)); 
	return (myvalue.length==0) ? def : myvalue; 
} 
function traceGlobal() { 
	for (x in _global) { trace('_global.' + x + ': ' + _global[x]); } 
} 
function traceList(lst) { lst = lst.split(","); 
	for (var x = 0; x < lst.length; x++) { trace(lst[x] + ': ' + eval(lst[x])); } 
} 

MovieClip.prototype.setDepth = function(x) { this.swapDepths(x); } 
MovieClip.prototype.getColor = function(c) { return parseInt("0x" + c); } 

MovieClip.prototype.setRotation = function(r) { 
	this._rotation = r; 
	switch (r) {
		case 90: { this._x += Stage.width; break; } 
		case -90: { this._y += Stage.height; break; } 
		case 180: { this._x += Stage.width; this._y += Stage.height; break; } 
	} 
}

MovieClip.prototype.rect = function(x,y,w,h) { 
	with (this) { 
		moveTo(x,y); 
		lineTo(x+w-1,y); 
		lineTo(x+w-1,y+h-1); 
		lineTo(x,y+h-1); 
		endFill(); 
	} 
} 

MovieClip.prototype.circle = function(r, x, y) {
    this.moveTo(x+r, y);
    a = Math.tan(22.5 * Math.PI/180);
    for (var angle = 45; angle<=360; angle += 45) {
        // endpoint:
        var endx = r*Math.cos(angle*Math.PI/180);
        var endy = r*Math.sin(angle*Math.PI/180);
		// control: 
        // (angle-90 is used to give the correct sign)
        var cx =endx + r*a*Math.cos((angle-90)*Math.PI/180);
        var cy =endy + r*a*Math.sin((angle-90)*Math.PI/180);
        this.curveTo(cx+x, cy+y, endx+x, endy+y);
    } this.endFill(); 
}

Stage.align = "TL"; 
Stage.scaleMode = "noScale"; 

_global.rotation = parseInt(getVar("rotation","0")); 
switch (_global.rotation) { 
	case -90: { ; } 
	case 90: { 
		_global.orientation = "vertical"; 
		_global.moviewidth = Stage.width; 
		_global.movielength = Stage.height; 
		break; 
	} 
	default: { 
		_global.orientation = "horizontal"; 
		_global.moviewidth = Stage.height; 
		_global.movielength = Stage.width; 
		break; 
	} 
} 
_global.maxvalue = parseInt(getVar("maxvalue","100")); 
_global.offset = parseInt(getVar("offset","0")); 
_global.sliderInput = getVar("inputnames","slider").split(","); 
_global.sliderCount = sliderInput.length; 
_global.position = getVar("position",String((_global.maxvalue+_global.offset)/2)).split(","); 
_global.trackheight = parseInt(getVar("trackheight",_global.moviewidth/2)); 
_global.tracklength = parseInt(getVar("tracklength",_global.movielength-trackheight)); 
_global.trackx = parseInt(getVar("trackx",(_global.movielength-tracklength)/2)); 
_global.tracky = parseInt(getVar("tracky",(_global.moviewidth-trackheight)/2)); 
_global.handleshape = getVar("handleshape","circle"); 
_global.handlesize = parseInt(getVar("handlesize",_global.moviewidth/2)); 
_global.xmin = Math.max(_global.handlesize,_global.trackx); 
_global.xmax = Math.min(_global.movielength-(2*_global.handlesize),_global.trackx+_global.tracklength); 
_global.ycenter = _global.tracky + _global.trackheight/2; 

// declare a function to return the value from the current slider position 
function getSliderValue(sPos) { return ((sPos / _global.tracklength) * (_global.maxvalue - _global.offset)) + _global.offset; } 

// declare a function to return the slider position for a specified slider value - invserse of getSliderValue 
function getSliderPosition(sVal) { return _global.tracklength * ((sVal - _global.offset)/(_global.maxvalue - _global.offset)); } 

this.createEmptyMovieClip("track",1); 
with (this.track) { 
	lineStyle(parseInt(getVar("trackborder","0")),getColor(getVar("trackbordercolor","000000")),parseint(getVar("trackborderalpha","100"))); 
	
	// make a gradient a dynamic color array 
	colors = getVar("trackcolor","FFFFFF,FFFFFF,DDDDDD").split(",");  
	for (var x = 0; x < colors.length; x++) { colors[x] = getColor(colors[x]); } 
	
	// all of the colors should be opaque 
	alphas = getVar("trackalpha","100,100,100").split(","); 
	for (x = 0; x < alphas.length; x++) { alphas[x] = parseInt(alphas[x]); } 
	
	// these ratios are steps from 0 to 255 where the gradient should reach a color indicated in the color array : 255=100% 
	ratios = getVar("trackratio","0,220,255").split(","); 
	for (x = 0; x < ratios.length; x++) { ratios[x] = parseInt(ratios[x]); }  
	
	// 0 radians is the equivalent of no rotation for the gradient 
	radians = parseFloat(getVar("trackradians","90")); 
	
	// build our matrix using the "box" method 
	matrix = { matrixType:"box", x:0, y:0, w:tracklength, h:trackheight, r: (radians/180)*Math.PI } 
	
	// put all that together in the beginGradientFill 
	beginGradientFill("linear",colors,alphas,ratios,matrix); 
	
	// draw the bounding box 
	rect(trackx,tracky,tracklength,trackheight); 
} 

this.createEmptyMovieClip("handle_0",2); 
with (this.handle_0) { 
	handlesize = _global.handlesize; 
	lineStyle(parseInt(getVar("handleborder","0")),getColor(getVar("handlebordercolor","606060")),parseInt(getVar("handleborderalpha","100"))); 
	
	// make a gradient a dynamic color array 
	colors = getVar("handlecolor","FFFFFF,FFFFFF,DDDDDD").split(","); 
	for (var x = 0; x < colors.length; x++) { colors[x] = getColor(colors[x]); } 
	
	// all of the colors should be opaque 
	alphas = getVar("handlealpha","100,100,100").split(","); 
	for (x = 0; x < alphas.length; x++) { alphas[x] = parseInt(alphas[x]); } 
	
	// these ratios are steps from 0 to 255 where the gradient should reach a color indicated in the color array : 255=100% 
	ratios = getVar("handleratio","0,200,255").split(","); 
	for (x = 0; x < ratios.length; x++) { ratios[x] = parseInt(ratios[x]); }  
	
	// 0 radians is the equivalent of no rotation for the gradient 
	radians = parseFloat(getVar("handleradians","45")); 
	
	// build our matrix using the "box" method 
	matrix = { matrixType:"box", x:0, y:0, w:handlesize*1.5, h:handlesize*1.5, r: (radians/180)*Math.PI } 
	
	// put all that together in the beginGradientFill 
	switch (_global.handleshape) { 
		case "circle": { 
			beginGradientFill("radial",colors,alphas,ratios,matrix); 
			circle(handlesize,_global.xmin,_global.ycenter); 
			break; 
		} 
		case "square": { 
			beginGradientFill("linear",colors,alphas,ratios,matrix); 
			rect(_global.xmin-handlesize,_global.ycenter-handlesize,2*handlesize,2*handlesize); 
			break; 
		} 
		case "rect": { 
			beginGradientFill("linear",colors,alphas,ratios,matrix); 
			rect(0,0,handlesize,2*handlesize); 
			break; 
		} 
		default: { 
			beginGradientFill("linear",colors,alphas,ratios,matrix); 
			eval(_global.handleshape); this.endFill(); break; 
		} 
	} 
} 


// allow the handles to be dragged and constrain them to their original order (left-to-right) and within the track and movie 
function onHandlePress () { 
	var handleID = parseInt(this._name.split("_")[1]); 
	var lasthandle = _root.handle.length -1; 
	var prehandle = (handleID > 0) ? _root.handle[handleID-1] : false; 
	var posthandle = (handleID < lasthandle) ? _root.handle[handleID+1] : false; 
	var leftmost = (prehandle == false) ? _global.xmin : prehandle._x + (2*_global.handlesize); 
	var rightmost = (posthandle == false) ? _global.xmax : posthandle._x - (2*_global.handlesize); 
	
	switch (_global.rotation) { 
		case 90: { ; } 
		case -90: { startDrag(this, false, this._x, leftmost, this._x, rightmost); break; } 
		default: { startDrag(this, false, leftmost, this._y, rightmost, this._y); } 
	} 
} 

// when the handle is released return the current slider value to the browser 
function onHandleRelease () { 
	var sliderValue = 0; 
	var handleID = parseInt(this._name.split("_")[1]); 
	var inputname = _global.sliderInput[handleid]; 
	this.stopDrag(); 
	switch (_global.rotation) { 
		case -90: { ; }
		case 90: { sliderValue = getSliderValue(this._y); break; } 
		default: { sliderValue = getSliderValue(this._x); break; } 
	} 
	fscommand(inputname,sliderValue); 
} 

// create an array of slider handles - associate functions with handle events and place the handles on the track 
handle = new Array(); 
handle[0] = this.handle_0; 
for (x = 0; x < _global.sliderCount; x++) { 
	if (x > 0) { duplicateMovieClip(this.handle_0,"handle_" + x,x+2); } 
	temp = eval("this.handle_" + x); handle[x] = temp; 
	temp.onPress = onHandlePress; 
	temp.onRelease = onHandleRelease; 
	temp.onReleaseOutside = onHandleRelease; 
	//temp._rotation = _global.rotation; 
	var position = _global.position[x]; 
	switch (_global.rotation) { 
		case -90: { ; } 
		case 90: { temp._y = getSliderPosition(_global.position[x]); break; } 
		default: { temp._x = getSliderPosition(_global.position[x]); break; } 
	} 
	temp.onPress(); temp.onRelease(); 
} 

// turn the track to accomodate flipped or rotated sliders 
this.track.setRotation(_global.rotation); 

stop(); 

