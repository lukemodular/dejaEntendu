(
p = SerialPort(
    "/dev/ttyACM0",
    baudrate: 230400,    //115200, 230400
	crtscts: false);
);


//SerialPort.devices;
//p.close;    // close the port
//SerialPort.closeAll;    // close all ports

Tdef(\golWriter).play;
Tdef(\golWriter).stop;


///////////////
//FrameWriter
(
Tdef(\golWriter, {
var envir, copy, neighbours, preset, rule, wrap, envirStream;
var rows= 32, cols= 32;
	wrap = true;

//if borderless envir
/*-- select rule here --*/
//rule= #[[], [3]];
//rule= #[[5, 6, 7, 8], [3, 5, 6, 7, 8]];
//rule= #[[], [2]];                                             //rule "/2" seeds
//rule= #[[], [2, 3, 4]];
//rule= #[[1, 2, 3, 4, 5], [3]];
//rule= #[[1, 2, 5], [3, 6]];
//rule= #[[1, 3, 5, 7], [1, 3, 5, 7]];  //--> cubes!
//rule= #[[1, 3, 5, 8], [3, 5, 7]];
rule= #[[2, 3], [3]];                                           //rule "23/3" conway's life
//rule= #[[2, 3], [3, 6]];                                      //rule "23/36" highlife
//rule= #[[2, 3, 5, 6, 7, 8], [3, 6, 7, 8]];
//rule= #[[2, 3, 5, 6, 7, 8], [3, 7, 8]];
//rule= #[[2, 3, 8], [3, 5, 7]];
//rule= #[[2, 4, 5], [3]];
//rule= #[[2, 4, 5], [3, 6, 8]];
//rule= #[[3, 4], [3, 4]];
//rule= #[[3, 4, 6, 7, 8], [3, 6, 7, 8]];               //rule "34578/3678" day&night
//rule= #[[4, 5, 6, 7], [3, 5, 6, 7, 8]];
//rule= #[[4, 5, 6], [3, 5, 6, 7, 8]];
//rule= #[[4, 5, 6, 7, 8], [3]];
//rule= #[[5], [3, 4, 6]];
neighbours= #[[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
envir= Array2D(rows, cols);
copy= Array2D(rows, cols);
cols.do{|x| rows.do{|y| envir.put(x, y, 0)}};
/*-- select preset here --*/
//preset= #[[0, 0], [1, 0], [0, 1], [1, 1]]+(cols/2); //block
//preset= #[[0, 0], [1, 0], [2, 0]]+(cols/2); //blinker
//preset= #[[0, 0], [1, 0], [2, 0], [1, 1], [2, 1], [3, 1]]+(cols/2); //toad
//preset= #[[1, 0], [0, 1], [0, 2], [1, 2], [2, 2]]+(cols/2); //glider
//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [0, 1], [4, 1], [0, 2], [1, 3], [4, 3]]+(cols/2); //lwss
//preset= #[[1, 0], [5, 0], [6, 0], [7, 0], [0, 1], [1, 1], [6, 2]]+(cols/2); //diehard
//preset= #[[0, 0], [1, 0], [4, 0], [5, 0], [6, 0], [3, 1], [1, 2]]+(cols/2); //acorn
//preset= #[[12, 0], [13, 0], [11, 1], [15, 1], [10, 2], [16, 2], [24, 2], [0, 3], [1, 3], [10, 3], [14, 3], [16, 3], [17, 3], [22, 3], [24, 3], [0, 4], [1, 4], [10, 4], [16, 4], [20, 4], [21, 4], [11, 5], [15, 5], [20, 5], [21, 5], [34, 5], [35, 5], [12, 6], [13, 6], [20, 6], [21, 6], [34, 6], [35, 6], [22, 7], [24, 7], [24, 8]]+(cols/4); //gosper glider gun
//preset= #[[0, 0], [2, 0], [2, 1], [4, 2], [4, 3], [6, 3], [4, 4], [6, 4], [7, 4], [6, 5]]+(cols/2); //infinite1
//preset= #[[0, 0], [2, 0], [4, 0], [1, 1], [2, 1], [4, 1], [3, 2], [4, 2], [0, 3], [0, 4], [1, 4], [2, 4], [4, 4]]+(cols/2); //infinite2
//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [9, 0], [10, 0], [11, 0], [12, 0], [13, 0], [17, 0], [18, 0], [19, 0], [26, 0], [27, 0], [28, 0], [29, 0], [30, 0], [31, 0], [32, 0], [34, 0], [35, 0], [36, 0], [37, 0], [38, 0]]+(cols/4); //infinite3
//preset= Array.fill(rows, {|i| [0, i]});
//preset= Array.fill(rows, {|i| [i, 0]});
//preset= Array.fill(rows, {|i| [i, i]});
//preset= Array.fill(cols, {|i| [i, 0]});
//preset= Array.series((cols*rows/2).rand, [0,0], [2,0]);
//preset= Array.series((rows/2)*(cols), [0,0], [0,2]).put(cols.rand, [0,0]);
preset= Array.fill(cols*rows, {[cols.rand, rows.rand]});

preset.do{|point|
	envir.put(point[0], point[1], 1);
	//p.putAll(Int8Array[point[0], point[1], 8]);
	//0.01.wait;
	};

i= 0;

loop{
	i= i+1;
	cols.do{|x|
		rows.do{|y|
			if(envir.at(x, y)==1, {
				//p.putAll(Int8Array[y, x, 8]);
				//0.01.wait;
			});
			if(envir.at(x, y)==0, {
				//p.putAll(Int8Array[y, x, 0]);
				//0.01.wait;
			});
		};
	};
		envirStream = envir.asArray;
		p.putAll(envirStream);
		envirStream.size.postln;
		envirStream.postln;
	1.0.wait;

	cols.do{|x|
		rows.do{|y|
			var sum= 0;
			neighbours.do{|point|
				var nX= x+point[0];
				var nY= y+point[1];
				if(wrap, {
					sum= sum+envir.at(nX%cols, nY%rows); //no borders
					}, {
						if((nX>=0)&&(nY>=0)&&(nX<cols)&&(nY<rows), {sum= sum+envir.at(nX, nY)}); //borders
				});
			};
			if(rule[1].includes(sum), {     //borne
				copy.put(x, y, 1);

				}, {
					if(rule[0].includes(sum), {     //lives on
						copy.put(x, y, envir.at(x, y));
						}, {    //dies
							copy.put(x, y, 0);
					});
			});
		};
	};
	envir= copy.deepCopy;
		//0.1.wait;

};
});
);

//////////////
//Serial Tests

p.put(0);
p.put(0);
p.put(8);

p.putAll(Int8Array[1, 1, 8]);
p.putAll(Int8Array[1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12]);

(
r = Routine({p.putAll(Int8Array[
	1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12,
	1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12,
	1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12,
	1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12, 1, 32, 12, 12]);}).play;
);

(
r= Routine({
    inf.do{|i|
       	p.putAll(Int8Array[32.rand, 32.rand, 8.rand]);
        0.01.wait;
    };
}).play;
)


(
r= Routine({
    32.do{|x|
		32.do{|y|
       	p.putAll(Int8Array[y, x, 0]);
        0.008.wait;
    };
	};
}).play;
)

r.stop;


///////////////
//Pixelwriter
(
Tdef(\golWriter, {
var envir, copy, neighbours, preset, rule, wrap;
var rows= 32, cols= 32;
wrap= true;

//if borderless envir
/*-- select rule here --*/
//rule= #[[], [3]];
//rule= #[[5, 6, 7, 8], [3, 5, 6, 7, 8]];
//rule= #[[], [2]];                                             //rule "/2" seeds
//rule= #[[], [2, 3, 4]];
//rule= #[[1, 2, 3, 4, 5], [3]];
//rule= #[[1, 2, 5], [3, 6]];
//rule= #[[1, 3, 5, 7], [1, 3, 5, 7]];  //--> cubes!
//rule= #[[1, 3, 5, 8], [3, 5, 7]];
rule= #[[2, 3], [3]];                                           //rule "23/3" conway's life
//rule= #[[2, 3], [3, 6]];                                      //rule "23/36" highlife
//rule= #[[2, 3, 5, 6, 7, 8], [3, 6, 7, 8]];
//rule= #[[2, 3, 5, 6, 7, 8], [3, 7, 8]];
//rule= #[[2, 3, 8], [3, 5, 7]];
//rule= #[[2, 4, 5], [3]];
//rule= #[[2, 4, 5], [3, 6, 8]];
//rule= #[[3, 4], [3, 4]];
//rule= #[[3, 4, 6, 7, 8], [3, 6, 7, 8]];               //rule "34578/3678" day&night
//rule= #[[4, 5, 6, 7], [3, 5, 6, 7, 8]];
//rule= #[[4, 5, 6], [3, 5, 6, 7, 8]];
//rule= #[[4, 5, 6, 7, 8], [3]];
//rule= #[[5], [3, 4, 6]];
neighbours= #[[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
envir= Array2D(rows, cols);
copy= Array2D(rows, cols);
cols.do{|x| rows.do{|y| envir.put(x, y, 0)}};
/*-- select preset here --*/
//preset= #[[0, 0], [1, 0], [0, 1], [1, 1]]+(cols/2); //block
//preset= #[[0, 0], [1, 0], [2, 0]]+(cols/2); //blinker
//preset= #[[0, 0], [1, 0], [2, 0], [1, 1], [2, 1], [3, 1]]+(cols/2); //toad
//preset= #[[1, 0], [0, 1], [0, 2], [1, 2], [2, 2]]+(cols/2); //glider
//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [0, 1], [4, 1], [0, 2], [1, 3], [4, 3]]+(cols/2); //lwss
//preset= #[[1, 0], [5, 0], [6, 0], [7, 0], [0, 1], [1, 1], [6, 2]]+(cols/2); //diehard
//preset= #[[0, 0], [1, 0], [4, 0], [5, 0], [6, 0], [3, 1], [1, 2]]+(cols/2); //acorn
//preset= #[[12, 0], [13, 0], [11, 1], [15, 1], [10, 2], [16, 2], [24, 2], [0, 3], [1, 3], [10, 3], [14, 3], [16, 3], [17, 3], [22, 3], [24, 3], [0, 4], [1, 4], [10, 4], [16, 4], [20, 4], [21, 4], [11, 5], [15, 5], [20, 5], [21, 5], [34, 5], [35, 5], [12, 6], [13, 6], [20, 6], [21, 6], [34, 6], [35, 6], [22, 7], [24, 7], [24, 8]]+(cols/4); //gosper glider gun
//preset= #[[0, 0], [2, 0], [2, 1], [4, 2], [4, 3], [6, 3], [4, 4], [6, 4], [7, 4], [6, 5]]+(cols/2); //infinite1
//preset= #[[0, 0], [2, 0], [4, 0], [1, 1], [2, 1], [4, 1], [3, 2], [4, 2], [0, 3], [0, 4], [1, 4], [2, 4], [4, 4]]+(cols/2); //infinite2
//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [9, 0], [10, 0], [11, 0], [12, 0], [13, 0], [17, 0], [18, 0], [19, 0], [26, 0], [27, 0], [28, 0], [29, 0], [30, 0], [31, 0], [32, 0], [34, 0], [35, 0], [36, 0], [37, 0], [38, 0]]+(cols/4); //infinite3
//preset= Array.fill(rows, {|i| [0, i]});
//preset= Array.fill(rows, {|i| [i, 0]});
//preset= Array.fill(rows, {|i| [i, i]});
//preset= Array.fill(cols, {|i| [i, 0]});
//preset= Array.series((cols*rows/2).rand, [0,0], [2,0]);
//preset= Array.series((rows/2)*(cols), [0,0], [0,2]).put(cols.rand, [0,0]);
preset= Array.fill(cols*rows, {[cols.rand, rows.rand]});

preset.do{|point|
	envir.put(point[0], point[1], 1);
	//p.putAll(Int8Array[point[0], point[1], 8]);
	//0.01.wait;
	};

i= 0;

loop{
	i= i+1;
	cols.do{|x|
		rows.do{|y|
			if(envir.at(x, y)==1, {
				p.putAll(Int8Array[y, x, 8]);
				0.01.wait;
			});
			if(envir.at(x, y)==0, {
				p.putAll(Int8Array[y, x, 0]);
				0.01.wait;
			});
		};
	};

	cols.do{|x|
		rows.do{|y|
			var sum= 0;
			neighbours.do{|point|
				var nX= x+point[0];
				var nY= y+point[1];
				if(wrap, {
					sum= sum+envir.at(nX%cols, nY%rows); //no borders
					}, {
						if((nX>=0)&&(nY>=0)&&(nX<cols)&&(nY<rows), {sum= sum+envir.at(nX, nY)}); //borders
				});
			};
			if(rule[1].includes(sum), {     //borne
				copy.put(x, y, 1);

				}, {
					if(rule[0].includes(sum), {     //lives on
						copy.put(x, y, envir.at(x, y));
						}, {    //dies
							copy.put(x, y, 0);
					});
			});
		};
	};
	envir= copy.deepCopy;
		0.01.wait;

};
});
);



(
var envir, copy, neighbours, preset, rule, wrap;
var w, u, width= 800, height= 800, rows= 32, cols= 32, cellWidth, cellHeight;
w= Window("ca - 2 pen", Rect(0, 0, width, height), false);
u= UserView(w, Rect(0, 0, width, height));
u.background= Color.white;
cellWidth= width/cols;
cellHeight= height/rows;
wrap= true;

//if borderless envir
/*-- select rule here --*/
//rule= #[[], [3]];
//rule= #[[5, 6, 7, 8], [3, 5, 6, 7, 8]];
//rule= #[[], [2]];                                             //rule "/2" seeds
//rule= #[[], [2, 3, 4]];
//rule= #[[1, 2, 3, 4, 5], [3]];
//rule= #[[1, 2, 5], [3, 6]];
//rule= #[[1, 3, 5, 7], [1, 3, 5, 7]];  //--> cubes!
//rule= #[[1, 3, 5, 8], [3, 5, 7]];
rule= #[[2, 3], [3]];                                           //rule "23/3" conway's life
//rule= #[[2, 3], [3, 6]];                                      //rule "23/36" highlife
//rule= #[[2, 3, 5, 6, 7, 8], [3, 6, 7, 8]];
//rule= #[[2, 3, 5, 6, 7, 8], [3, 7, 8]];
//rule= #[[2, 3, 8], [3, 5, 7]];
//rule= #[[2, 4, 5], [3]];
//rule= #[[2, 4, 5], [3, 6, 8]];
//rule= #[[3, 4], [3, 4]];
//rule= #[[3, 4, 6, 7, 8], [3, 6, 7, 8]];               //rule "34578/3678" day&night
//rule= #[[4, 5, 6, 7], [3, 5, 6, 7, 8]];
//rule= #[[4, 5, 6], [3, 5, 6, 7, 8]];
//rule= #[[4, 5, 6, 7, 8], [3]];
//rule= #[[5], [3, 4, 6]];
neighbours= #[[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];
envir= Array2D(rows, cols);
copy= Array2D(rows, cols);
cols.do{|x| rows.do{|y| envir.put(x, y, 0)}};
/*-- select preset here --*/
//preset= #[[0, 0], [1, 0], [0, 1], [1, 1]]+(cols/2); //block
//preset= #[[0, 0], [1, 0], [2, 0]]+(cols/2); //blinker
//preset= #[[0, 0], [1, 0], [2, 0], [1, 1], [2, 1], [3, 1]]+(cols/2); //toad
//preset= #[[1, 0], [0, 1], [0, 2], [1, 2], [2, 2]]+(cols/2); //glider
//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [0, 1], [4, 1], [0, 2], [1, 3], [4, 3]]+(cols/2); //lwss
//preset= #[[1, 0], [5, 0], [6, 0], [7, 0], [0, 1], [1, 1], [6, 2]]+(cols/2); //diehard
//preset= #[[0, 0], [1, 0], [4, 0], [5, 0], [6, 0], [3, 1], [1, 2]]+(cols/2); //acorn
//preset= #[[12, 0], [13, 0], [11, 1], [15, 1], [10, 2], [16, 2], [24, 2], [0, 3], [1, 3], [10, 3], [14, 3], [16, 3], [17, 3], [22, 3], [24, 3], [0, 4], [1, 4], [10, 4], [16, 4], [20, 4], [21, 4], [11, 5], [15, 5], [20, 5], [21, 5], [34, 5], [35, 5], [12, 6], [13, 6], [20, 6], [21, 6], [34, 6], [35, 6], [22, 7], [24, 7], [24, 8]]+(cols/4); //gosper glider gun
//preset= #[[0, 0], [2, 0], [2, 1], [4, 2], [4, 3], [6, 3], [4, 4], [6, 4], [7, 4], [6, 5]]+(cols/2); //infinite1
//preset= #[[0, 0], [2, 0], [4, 0], [1, 1], [2, 1], [4, 1], [3, 2], [4, 2], [0, 3], [0, 4], [1, 4], [2, 4], [4, 4]]+(cols/2); //infinite2
//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [9, 0], [10, 0], [11, 0], [12, 0], [13, 0], [17, 0], [18, 0], [19, 0], [26, 0], [27, 0], [28, 0], [29, 0], [30, 0], [31, 0], [32, 0], [34, 0], [35, 0], [36, 0], [37, 0], [38, 0]]+(cols/4); //infinite3
//preset= Array.fill(rows, {|i| [0, i]});
//preset= Array.fill(rows, {|i| [i, 0]});
//preset= Array.fill(rows, {|i| [i, i]});
//preset= Array.fill(cols, {|i| [i, 0]});
//preset= Array.series((cols*rows/2).rand, [0,0], [2,0]);
preset= Array.series((rows/2)*(cols), [0,0], [0,2]).put(cols.rand, [0,0]);
//preset= Array.fill(cols*rows, {[cols.rand, rows.rand]});

preset.do{|point|
	envir.put(point[0], point[1], 1);
	//p.putAll(Int8Array[point[0], point[1], 8]);
	};

i= 0;
u.drawFunc= {
	i= i+1;
	Pen.fillColor= Color.black;
	cols.do{|x|
		rows.do{|y|
			if(envir.at(x, y)==1, {
				Pen.addRect(Rect(x*cellWidth, height-(y*cellHeight), cellWidth, cellHeight));
			});
		};
	};
	Pen.fill;
	cols.do{|x|
		rows.do{|y|
			var sum= 0;
			neighbours.do{|point|
				var nX= x+point[0];
				var nY= y+point[1];
				if(wrap, {
					sum= sum+envir.at(nX%cols, nY%rows); //no borders
					}, {
						if((nX>=0)&&(nY>=0)&&(nX<cols)&&(nY<rows), {sum= sum+envir.at(nX, nY)}); //borders
				});
			};
			if(rule[1].includes(sum), {     //borne
				copy.put(x, y, 1);
				//p.putAll(Int8Array[x, y, 1]);
				//0.1.wait;
				}, {
					if(rule[0].includes(sum), {     //lives on
						copy.put(x, y, envir.at(x, y));
						}, {    //dies
							copy.put(x, y, 0);
							//p.putAll(Int8Array[x, y, 0]);
							//0.1.wait;
					});
			});
		};
	};
	envir= copy.deepCopy;
};
Routine({while{w.isClosed.not} {u.refresh; i.postln; (1).wait}}).play(AppClock);
w.front;
)


p.doneAction = { "my serial port got closed".postln; }

p.close;    // close the port

SerialPort.closeAll;    // close all ports


Tdef(\x, {
	var doThat, doThis = [1,2,3].choose;
	doThis.postln;
	1.wait;
	doThat = [1,2,3].choose;
	doThat.postln;
	loop { 0.5.wait; "aaaaaaaaaaaaaazz".scramble.postln } }).play;