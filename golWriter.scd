(
p = SerialPort(
	"/dev/ttyACM0",
	baudrate: 230400,    //115200, 230400
	crtscts: false);
);

"Testing Matrix CAN commands".postln;

// ==========================================
// 000h(+nodeID) IDENTIFY
// ==========================================

fork{ p.putAll("t00020001\r");}.play // IDENTIFY all - CAN 0x700+nodeID packet + display on matrix
fork{ p.putAll("t00020000\r");}.play // IDENTIFY all - CAN 0x700+nodeID packet + with no display on matrix
fork{ p.putAll("t01920001\r");}.play // IDENTIFY 0x19 (node 25) - CAN 0x719 packet + display on matrix

fork{ p.putAll("t00020100\r");}.play // RESET all


// ==========================================
// 100h(+nodeID) SOUND
// ==========================================

// [VOLUME set] 0x100+nodeID cmd=0
// len 3  bytes 0[cmd] 1-2[volume 16-bit]  (volume/1000.0) = gain  (e.g. 1000 = 1.0 gain)

fork{ p.putAll("t100300"++0.asHexString(4)++"\r");}.play  // VOLUME set (all) 0 = 0 gain
fork{ p.putAll("t100300"++200.asHexString(4)++"\r");}.play  // VOLUME set (all) 200 = 0.2 gain
fork{ p.putAll("t100300"++1000.asHexString(4)++"\r");}.play // VOLUME set (all) 1000 = 1.0 gain
fork{ p.putAll("t100300"++2500.asHexString(4)++"\r");}.play  // VOLUME set (all) 2500 = 2.5 gain

// [VOLUME fadeIn] 0x100+nodeID cmd=1
// len 3  bytes 0[cmd] 1-2[mS 16-bit]

fork{ p.putAll("t100301"++2000.asHexString(4)++"\r");}.play  // VOLUME fadeIn (all) 2000 = 2sec

// [VOLUME fadeOut] 0x100+nodeID cmd=2
// len 3  bytes 0[cmd] 1-2[mS 16-bit]

fork{ p.putAll("t100302"++5000.asHexString(4)++"\r");}.play  // VOLUME fadeOut (all) 5000 = 5sec

// [SOUND noteOff] 0x100+nodeID cmd=3
// len 1  bytes 0[cmd]  1-2[mS 16-bit]

fork{ p.putAll("t1003030000"++"\r");}.play  // SOUND noteOff (all) 0mS (immediate)

// [SOUND NoteOn] 0x180+nodeID
// len 7  bytes 0-1[freq] 2[amplitude] 3-4[length in mS] 5[attack] 6[release]

fork{ p.putAll("t1807"
	++175.asHexString(4) // freq (0-44100)
	++80.asHexString(2)   // amplitude 0-255 scaled to 0-1.0
	++2500.asHexString(4)  // length in mS for noteOffTimer
	++200.asHexString(2)   // attack in mS * 4 (0-255) becomes 0-1020
	++50.asHexString(2)  // release in mS * 4 (0-255) becomes 0-1020
	++"\r");}.play


// send NoteOn via OSC CANserial bridge
var freq, amp, len, attack, release;
freq = 175;
amp = 80;
len = 2500;
attack = 200;
release = 50;
b.sendMsg("/CAN0", 0x180, 7, (freq >> 8) & 0xFF, freq & 0xFF, amp, (len >> 8) & 0xFF, len & 0xFF, attack, release);


// ==========================================
// 200h(+nodeID) LED
// ==========================================

// ------------------------------------------
// [LED clear display] 0x200+nodeID cmd=0
// len 4  bytes 0[cmd] 1[R] 2[G] 3[B]
// ------------------------------------------

fork{ p.putAll("t200400"++"000000"++"\r");}.play // LED clear display (all) with 0,0,0 color
fork{ p.putAll("t200400"++"402080"++"\r");}.play // LED clear display (all) with 0x40,0x20,0x80 color


// ------------------------------------------
// [LED brightness] 0x200+nodeID cmd=1
// len 2  bytes 0[cmd] 1[brightness
// ------------------------------------------

fork{ p.putAll("t200201"++  0.asHexString(2)++"\r");}.play // LED brightness (all) 0 (off)
fork{ p.putAll("t200201"++255.asHexString(2)++"\r");}.play // LED brightness (all) 255 (max)
fork{ p.putAll("t200201"++ 20.asHexString(2)++"\r");}.play // LED brightness (all) 20

// ------------------------------------------
// [LED draw character] 0x280+nodeID cmd=2
// len 8  bytes 0[cmd] [X] 2[Y] 3[R] 4[G] 5[B] 6[font0-3] 7[char]
// ------------------------------------------
// GLOBAL coordinates used
fork{ p.putAll("t280802C824FF00FF03"++"A".ascii[0].asHexString(2)++"\r");}.play // LED char (all) 0xFF,0x00,0xFF- global coordinates X= 0xC0 (192) Y=0x24 (36) + font (3)
fork{ p.putAll("t280802C22400FFFF01"++"b".ascii[0].asHexString(2)++"\r");}.play // LED char (all) 0x00,0xFF,0xFF - global coordinates X= 0xC2 (194) Y=0x24 (36) + font (1)

// LOCAL coordinates used - repeated on all displays if addr 0x280 - else use 0x280+nodeID
fork{ p.putAll("t28080208184F40FF10"++"D".ascii[0].asHexString(2)++"\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0)
fork{ p.putAll("t28080210184F408F31"++"E".ascii[0].asHexString(2)++"\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0) - transparent
fork{ p.putAll("t28080218184F404F11"++"J".ascii[0].asHexString(2)++"\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0)



// ------------------------------------------
// [LED phrase] 0x300+nodeID
// ------------------------------------------
// len 8  bytes 0[Xh] 1[Xl] 2[Y] 3[R] 4[G] 5[B] 6[font0-3] 7 [phrase index]
// byte 6 - add 0x10 (bit4) to enable local coordinates for X & Y instead of default global coordinates when this bit is 0
// byte 6 - add 0x20 (bit5) to set TRANSPARENCY flag - not yet working in SmartMatrix lib

// GLOBAL coordinates used
fork{ p.putAll("t300800C024FF00FF0000\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x00 - global coordinates X= 0xC0 (192) Y=0x24 (36) + font (0)
fork{ p.putAll("t300800C22400FFFF0100\r");}.play // LED phrase #0 (all) 0x00,0xFF,0xFF with font 0x01 = global coordinates X= 0xC2 (194) Y=0x24 (36) + font (1)

// LOCAL coordinates used
fork{ p.putAll("t3008000410FF00FF1000\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0)
fork{ p.putAll("t3008000410FF00FF3000\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0) - transparent

fork{ p.putAll("t300800020700FFFF1102\r",);}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x01
fork{ p.putAll("t300800020700FFFF3102\r",);}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x01 - transparent

fork{ p.putAll("t300800020200FFFF1102\r");}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x11 = local coordinates(1) + font (1)
fork{ p.putAll("t300800020200FFFF3102\r");}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x11 = local coordinates(1) + font (1) - transparent


// ------------------------------------------
// [LED scrollText] 0x380+nodeID
// ------------------------------------------
// len 8  bytes 0[startX] 1[startY] 2[R] 3[G] 4[B] 5[speed] 6[font0-3] 7[phrase index]

// LOCAL coordinates used

fork{ p.putAll("t3808"++ // LED scroll (all)
	0.asHexString(2)++ // start offset from left
	10.asHexString(2)++ // offset from top
	"FF00FF"++ // RGB
	20.asHexString(2)++ // speed
	1.asHexString(2)++ // font
	0.asHexString(2)++"\r");}.play // phrase

fork{ p.putAll("t3808"++
	10.asHexString(2)++ // start offset from left
	24.asHexString(2)++ // offset from top
	"FFFF00"++ // RGB
	30.asHexString(2)++ // speed
	2.asHexString(2)++ // font
	1.asHexString(2)++"\r");}.play // phrase


// ------------------------------------------
// test random draw characters
// ------------------------------------------

p.putAll("t200400"++"000000"++"\r"); // LED clear display (all) with 0,0,0 color

(
r = Routine({
	    var byte, str, val, x_pos, y_pos, color_rgb, char_val, font_val;
	    1024.do{|i|
		x_pos = 572.rand; // 192 + (56.rand);
		y_pos = 184.rand; // 32 + (24.rand);
		color_rgb = 0xFFFFFF.rand;
		char_val = 65+(24.rand); // 'A'
		font_val = 3;

		i.post;
		" X=".post; x_pos.post;
		" Y=".post; y_pos.post;
		" char=".post; char_val.asAscii(0).post;
		" color=".post; color_rgb.asHexString(6).postln;

		// len 8  bytes 0[Xh] 1[Xl] 2[Y] 3[R] 4[G] 5[B] 6[font0-3] 7[char]
		// LED char (all) 0x00,0xFF,0xFF with font 0x01 = global coordinates X= 0xC2 (194) Y=0x24 (36) + font (1)
		//fork {
			p.putAll("t2808"++x_pos.asHexString(4)++y_pos.asHexString(2)++color_rgb.asHexString(6)++font_val.asHexString(2)++char_val.asHexString(2)++"\r");
		//}.play;

		0.01.wait;
	};
}).play;
)



// ------------------------------------------
// test animate brightness
// ------------------------------------------
(
r = Routine({
	    var byte, str, val;
	    255.do{|i|
		        i.postln;
		p.putAll("t200201"++(255-i).asHexString(2)++"\r"); // LED brightness (all) 255 (max)
		0.01.wait;
		};
}).play;
)


// ------------------------------------------
// close serial
// ------------------------------------------
p.close;    // close the port
SerialPort.closeAll;    // close all ports


// ------------------------------------------
// OSC CANserial bridge tests
// ------------------------------------------

b = NetAddr.new("127.0.0.1", 7110);    // run this once to create the NetAddr

b.sendMsg("/CAN0", 0x200, 8, 0, 1, 2, 3, 4, 5, 6, 7);
b.sendMsg("/CAN0", 0x200, 8, 0, 1, 2, 3, 4, 5, 6); // wrong length test (l=8 when only 7 arguments)

(
r = Routine({
	    var byte, str, val;
	    255.do{|i|
		        i.postln;
		b.sendMsg("/CAN0", 0x200, 2, 1, i); // animate brightness
		//0.001.wait;
		};
}).play;
)

b.sendMsg("/CAN0", 0x000, 2, 0, 1); // identify

b.sendMsg("/CAN0", 0x200, 2, 1, 15); // 15/255 brightness

b.sendMsg("/CAN0", 0x200, 4, 0, 0, 0, 0); // LED clear display (all) with 0,0,0 color

(
r = Routine({
	    var byte, str, val, x_pos, y_pos, color_r, color_g, color_b, char_val, font_val;
	    20000.do{|i|
		x_pos = 572.rand; // 192 + (56.rand);
		y_pos = 184.rand; // 32 + (24.rand);
		color_r = 0xFF.rand;
		color_g = 0xFF.rand;
		color_b = 0xFF.rand;
		char_val = 65+(24.rand); // 'A'
		font_val = 3;

//		i.post;
//		" X=".post; x_pos.post;
//		" Y=".post; y_pos.post;
//		" char=".post; char_val.asAscii(0).postln;

		// len 8  bytes 0[Xh] 1[Xl] 2[Y] 3[R] 4[G] 5[B] 6[font0-3] 7[char]
		// LED char (all) 0x00,0xFF,0xFF with font 0x01 = global coordinates X= 0xC2 (194) Y=0x24 (36) + font (1)
		b.sendMsg("/CAN0", 0x280, 8, (x_pos >> 8) & 0xFF, x_pos & 0xFF, y_pos, color_r, color_g, color_b, font_val, char_val);
		0.0002.wait; // 0.0001 starts giving us less than 1024 packets output
	};
}).play;
)

b.disconnect;


// BUNDLE test -- NOT YET WORKING
; Send bundle now

b.sendBundle(0.2, ["/CAN0", 0x000, 2, 0, 0],["/CAN0", 0x000, 2, 0, 1] ]);

b.sendBundle(0.2,		// our time value is set to 0.2 seconds after the message arrives
	["/CAN0", "variablesine", 1000, 1, 0, "freq", 200],
	["/CAN0", "variablesine", 1001, 1, 0, "freq", 300],
	["/CAN0", "variablesine", 1002, 1, 0, "freq", 400]);


// ------------------------------------------
// misc tests
// ------------------------------------------

(
f = {
	arg id, len, b0, b1, b2, b3, b4, b5, b6, b7;
	var c = "t" ++ id.asHexString(3) ++ len.asHexString(1) ++ b0.asHexString(2)
++ b1.asHexString(2) ++ b2.sHexString(2) // X Y
++ b3.asHexString(2) ++ b4.asHexString(2) ++ b5.asHexString(2) // COLOR
++ b6.asHexString(2) ++ b7.asHexString(2) ++ "\r"; // font # (+local/global bit6), phrase #
	//c.postln;
	fork{ p.putAll(c); }.play
}
)
f(0x200,8,0,1,2,3,4,5,6,7).postln;

    inf.do{|i|
       	p.putAll(Int8Array[32.rand, 32.rand, 8.rand]);
        0.01.wait;
    };

var c = "t" ++ 0x280.asHexString(3) ++ 8.asHexString(1)
++ 194.asHexString(4) ++ 40.asHexString(2) // X Y
++ 0xDD.asHexString(2) ++ 0xEE.asHexString(2) ++ 0xFF.asHexString(2) // COLOR
++ 1.asHexString(2) ++ 1.asHexString(2) ++ "\r"; // font # (+local/global bit6), phrase #
postln(c);
fork{ p.putAll(c); }.play





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
	1.5.wait;

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