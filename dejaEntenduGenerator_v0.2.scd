/////////////////////////////////////////////
///////////////////////////////////////
//déjà Entendu generator v0.2
//////////////////////////////////////////////

(
p = SerialPort(
	"/dev/ttyACM0",
	baudrate: 230400,    //115200, 230400
	crtscts: false);
);


(
q = SerialPort(
	"/dev/ttyACM1",
	baudrate: 230400,    //115200, 230400
	crtscts: false);
);

// ------------------------------------------
// close serial
// ------------------------------------------
p.close;    // close the port
SerialPort.closeAll;    // close all ports
SerialPort.clear;
SerialPort.cleanupAll;
SerialPort.listDevices;


// ------------------------------------------
// OSC CANserial bridge tests
// ------------------------------------------

b = NetAddr.new("127.0.0.1", 7110);    // run this once to create the NetAddr

b.sendMsg("/CAN0", 0x200, 8, 0, 1, 2, 3, 4, 5, 6, 7);
b.sendMsg("/CAN0", 0x200, 8, 0, 1, 2, 3, 4, 5, 6); // wrong length test (l=8 when only 7 arguments)

(
r = Routine({
	    var byte, str, val;
	    1023.do{|i|
		        i.postln;
		b.sendMsg("/CAN0", 0x200, 2, 1, 255.rand); // animate brightness
		0.001.wait;
		};
}).play;
)

b.sendMsg("/CAN0", 0x200, 2, 1, 15); // 15/255 brightness
b.sendMsg("/CAN0", 0x200, 2, 1, 15);

/////////////////////
//OSC LED

//OSC clear with color
b.sendMsg("/CAN0", 0x200, 4, 0, 255, 255, 255); // LED clear display (all) with 0,0,0 color
b.sendMsg("/CAN0", 0x200, 4, 0, 0, 0, 0);

//write letters
b.sendMsg("/CAN0", 0x280, 8, (300 >> 8) & 0xFF, 300 & 0xFF, 0, 255, 255, 255, 1, "a".ascii[0]);


//scroll
b.sendMsg("/CAN0", 0x380, 8, 4, 3, 255, 255, 255, 40, 1, 0);
//adrr, length, command, startY, R, G, B, speed, font, phrase


///////////////////
//OSC sound
b.sendMsg("/CAN0", 0x100, 3, 0, (0 >> 8) & 0xFF, 0 & 0xFF);
b.sendMsg("/CAN0", 0x100, 3, 0, (1000 >> 8) & 0xFF, 1500 & 0xFF);
//  (volume << 8) & 0xFF  pour byte 1 volume & 0xFF pour byte 2

// send NoteOn via OSC CANserial bridge
var freq, amp, len, attack, release;
freq = 200;
amp = 80;
len = 200;
attack = 200;
release = 200;
b.sendMsg("/CAN0", 0x184, 7, (freq >> 8) & 0xFF, freq & 0xFF, amp, (len >> 8) & 0xFF, len & 0xFF, attack, release);
b.sendMsg("/CAN0", 0x180, 7, (freq >> 8) & 0xFF, freq & 0xFF, amp, (len >> 8) & 0xFF, len & 0xFF, attack, release);


(
r = Routine({
	var freq, amp, len, attack, release;
freq = 200;
amp = 80;
len = 200;
attack = 200;
release = 200;
	102.do{|i|
		i.postln;
		freq = freq + 1.5.rand;
		b.sendMsg("/CAN0", 0x180+i+1, 7, (freq >> 8) & 0xFF, freq & 0xFF, amp, (len >> 8) & 0xFF, len & 0xFF, attack, release);
		rrand(0.01, 0.1).wait;
	};
}).play;
)



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


// [VOLUME fadeIn] 0x100+nodeID cmd=1
// len 3  bytes 0[cmd] 1-2[mS 16-bit]

fork{ p.putAll("t100301"++2000.asHexString(4)++"\r");}.play  // VOLUME fadeIn (all) 2000 = 2sec

// [VOLUME fadeOut] 0x100+nodeID cmd=2
// len 3  bytes 0[cmd] 1-2[mS 16-bit]

fork{ p.putAll("t100302"++5000.asHexString(4)++"\r");}.play  // VOLUME fadeOut (all) 5000 = 5sec

// [SOUND NoteON] 0x100+nodeID cmd=3
// len 6  bytes 0[cmd] 1[freq] 2[len] 3[amplitude] 4[attack] 5[release]

fork{ p.putAll("t100603"
	++175.asHexString(2) // freq
	++200.asHexString(2) // length
	++255.asHexString(2) // amplitude
	++50.asHexString(2) // attack
	++200.asHexString(2) // release
	++"\r");}.play


// ==========================================
// 200h(+nodeID) LED
// ==========================================

// ------------------------------------------
// [LED clear display] 0x200+nodeID cmd=0
// len 4  bytes 0[cmd] 1[R] 2[G] 3[B]
// ------------------------------------------

fork{ p.putAll("t200400"++"000000"++"\r");}.play // LED clear display (all) with 0,0,0 color
fork{ q.putAll("t200400"++"402080"++"\r");}.play // LED clear display (all) with 0x40,0x20,0x80 color

fork{ p.putAll("t2"++40.asHexString(2)++"400"++"000000"++"\r");}.play // LED clear display (all) with 0x40,0x20,0x80 color


// ------------------------------------------
// [LED brightness] 0x200+nodeID cmd=1
// len 2  bytes 0[cmd] 1[brightness
// ------------------------------------------

fork{ q.putAll("t200201"++0.asHexString(2)++"\r");}.play // LED brightness (all) 0 (off)
fork{ q.putAll("t200201"++200.asHexString(2)++"\r");}.play // LED brightness (all) 255 (max)
fork{ p.putAll("t200201"++20.asHexString(2)++"\r");}.play // LED brightness (all) 20


// ------------------------------------------
// [LED draw character] 0x280+nodeID cmd=2
// len 8  bytes 0[cmd] [X] 2[Y] 3[R] 4[G] 5[B] 6[font0-3] 7[char]
// ------------------------------------------
// GLOBAL coordinates used
fork{ p.putAll("t280802C824FF00FF03"++"A".ascii[0].asHexString(2)++"\r");}.play // LED char (all) 0xFF,0x00,0xFF- global coordinates X= 0xC0 (192) Y=0x24 (36) + font (3)
fork{ p.putAll("t280802C22400FFFF01"++"b".ascii[0].asHexString(2)++"\r");}.play // LED char (all) 0x00,0xFF,0xFF - global coordinates X= 0xC2 (194) Y=0x24 (36) + font (1)

fork{p.putAll("t2808"++200.asHexString(4)++33.asHexString(2)++"FFFFFF01"++"d".ascii[0].asHexString(2)++"\r");}.play;
fork{p.putAll("t2808"++0.asHexString(4)++0.asHexString(2)++"FFFFFF00"++"d".ascii[0].asHexString(2)++"\r");}.play;

fork{p.putAll("t2808"++400.asHexString(4)++30.asHexString(2)++"FFFFFF"++01.asHexString(2)++"d".ascii[0].asHexString(2)++"\r");}.play

// LOCAL coordinates used - repeated on all displays if addr 0x280 - else use 0x280+nodeID
fork{ p.putAll("t28080208184F40FF10"++"D".ascii[0].asHexString(2)++"\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0)
fork{ p.putAll("t28080210184F408F31"++"E".ascii[0].asHexString(2)++"\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0) - transparent
fork{ p.putAll("t28080218184F404F11"++"J".ascii[0].asHexString(2)++"\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0)



// ------------------------------------------
// [LED phrase] 0x200+nodeID cmd=3
// ------------------------------------------
// len 8  bytes 0[cmd] 1[X] 2[Y] 3[R] 4[G] 5[B] 6[font0..1] 7 [phrase index]
// byte 6 - add 0x10 (bit4) to enable local coordinates for X & Y instead of default global coordinates when this bit is 0
// byte 6 - add 0x20 (bit5) to set TRANSPARENCY flag - not yet working in SmartMatrix lib

// GLOBAL coordinates used
fork{ p.putAll("t200803C024FFFFFF0000\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x00 - global coordinates X= 0xC0 (192) Y=0x24 (36) + font (0)
fork{ p.putAll("t200803C224FFFFFF0100\r");}.play // LED phrase #0 (all) 0x00,0xFF,0xFF with font 0x01 = global coordinates X= 0xC2 (194) Y=0x24 (36) + font (1)

// LOCAL coordinates used
fork{ p.putAll("t2008030410FFFFFF1000\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0)
fork{ p.putAll("t2008030410FFFFFF3000\r");}.play // LED phrase #0 (all) 0 0xFF,0x00,0xFF with font 0x10 = local coordinates(1) + font (0) - transparent

fork{ p.putAll("t2008030207FFFFFF1102\r",);}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x01
fork{ p.putAll("t200803020700FFFF3102\r",);}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x01 - transparent

fork{ p.putAll("t200803020200FFFF1102\r");}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x11 = local coordinates(1) + font (1)
fork{ p.putAll("t200803020200FFFF3102\r");}.play // LED phrase #2 (all) 0x00,0xFF,0xFF with font 0x11 = local coordinates(1) + font (1) - transparent



// ------------------------------------------
// test random clean displays with colors
// ------------------------------------------

p.putAll("t200400"++"000000"++"\r"); // LED clear display (all) with 0,0,0 color

(
r = Routine({
	var byte, str, val, node, color_rgb;
	1024.do{|i|
		node = 103.rand;
		color_rgb = 0xFFFFFF.rand;

		i.post;
		" node=".post; node.post;
		" color=".post; color_rgb.asHexString(6).postln;

		p.putAll("t2"++node.asHexString(2)++"400"++color_rgb.asHexString(6)++"\r");

		0.1.wait;
	};
}).play;
)

(
r = Routine({
	var byte, str, val, node, white;
	1024.do{|i|
		node = 103.rand;
		white = 0xFF.rand;

		i.post;
		" node=".post; node.post;
		" color=".post; white.asHexString(2).postln;

		p.putAll("t2"++node.asHexString(2)++"400"++white.asHexString(2)++white.asHexString(2)++white.asHexString(2)++"\r");

		0.1.wait;
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
		fork{ p.putAll("t200201"++(255-i).asHexString(2)++"\r");}.play; // LED brightness (all) 255 (max)
		0.01.wait;
	};
}).play;
)


//line-1
~preset = Array.series(13, [1, 48/2], [1,0]);
~preset = [[0, 0],[0, 1], [0, 2], [0,3], [0,4]];

Tdef(\dejaWriter).play;
Tdef(\dejaWriter).stop;

(
Tdef(\dejaWriter, {
	var envir, copy, neighbours, preset, rule, wrap, envirStream, snake, genContext, textItem;
	var cols= 136, rows= 24;
	//real pixl 192 x 544, type 4x2 = 48 x 272, type 4x4 = 48 x 136, type 4x8 = 24 x 136
	var playRate = 2, playRateMax = 2;
	preset;
	//~cols = 136;
	//~rows = 48;


	//x = FileReader.read("FileReaderTest.sc").postcs;

	a = [ "No! In vain hath my soul aspired, with ardent longing,
		All to know,--all in earth and heaven.
		No light illumines the visions, ever thronging
		My brain; no peace is given,
		And I linger, thus sad and weary,
		Without power to sunder the chain
		Binding my soul to life always dreary.
		Nought do I see! Nought do I know!
		Again 'tis light!
		On its westward course flying,
		The somber night vanishes.
		Again the light of a new day!
		O death! when will thy dusky wings
		Above me hover and give me--rest?
		Well, then! Since death thus evades me,
		Why should I not go in search of him?
		Hail, my final day, all hail!
		No fears my heart assail;
		On earth my days I number;
		For this draught immortal slumber
		Will secure me, and care dispel!
		Hence, empty sounds of human joys
		Flee far from me.
		O goblet, which my ancestors
		So many times have filled,
		Why tremblest thou in my grasp?
		But this God, what will he do for me?
		Will he return to me youth, love, and faith?
		Cursed be all of man's vile race!
		Cursed be the chains which bind him in his place!
		Cursed be visions false, deceiving!
		Cursed the folly of believing!
		Cursed be dreams of love or hate!
		Cursed be souls with joy elate.
		Cursed be science, prayer, and faith!
		Cursed my fate in life and death!
		Infernal king, arise!
		Here am I! So, I surprise you?
		Satan, Sir, at your service!
		A sword at my side; on my hat a gay feather;--
		A cloak o'er my shoulder; and altogether,
		Why, gotten up quite in the fashion!
		(Briskly.)
		But come, Doctor Faust, what is your will?
		Behold! Speak! Are you afraid of me?
		Fie! Fie! Is this your politeness!
		But learn, my friend, that with Satan
		One should conduct in a different way.
		I've entered your door with infinite trouble.
		Would you kick me out the very same day?
		Anything in the world! All things. But
		Say first what you would have.
		Abundance of gold?
		No. I would have a treasure
		Which contains all. I wish for youth.
		Oh! I would have pleasure,
		And love, and caresses,
		For youth is the season
		When joy most impresses.
		One round of enjoyment,
		One scene of delight,
		Should be my employment
		From day-dawn till night.
		Oh, I would have pleasure,
		And love, and caresses;
		If youth you restore me,
		My joys I'll renew!
	"];

	wrap= false;                     //if borderless envir

	snake = ContextSnake(a, "a", 3);	// try longer context again
	genContext = snake.asStream.all.join;
	genContext = genContext.asString.removeEvery(",().?/!?;:_"); //.toUpper;
	genContext.size.postln;

	/*-- select rule here --*/
	//rule= #[[], [3]];
	//rule= #[[5, 6, 7, 8], [3, 5, 6, 7, 8]];
	//rule= #[[], [2]];                                             //rule "/2" seeds
	//rule= #[[], [2, 3, 4]];
	//rule= #[[1, 2, 3, 4, 5], [3]];
	//rule= #[[1, 2, 5], [3, 6]];
	//rule= #[[1, 3, 5, 7], [1, 3, 5, 7]];
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
	rows.do{|y| cols.do{|x| envir.put(y, x, 0)}};

	/*-- select preset here --*/
	//preset= #[[0, 0], [1, 0], [0, 1], [1, 1]]+(cols/2); //block
	//preset= #[[0, 0], [1, 0], [2, 0]]+(cols/2); //blinker
	//preset= #[[0, 0], [1, 0], [2, 0], [1, 1], [2, 1], [3, 1]]+(cols/2); //toad
	//preset= #[[1, 0], [0, 1], [0, 2], [1, 2], [2, 2]]+(cols/2); //glider
	//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [0, 1], [4, 1], [0, 2], [1, 3], [4, 3]]+(cols/2); //lwss
	//preset= #[[1, 0], [5, 0], [6, 0], [7, 0], [0, 1], [1, 1], [6, 2]]+(cols/2); //diehard
	//preset= #[[0, 0], [1, 0], [4, 0], [5, 0], [6, 0], [3, 1], [1, 2]]+(cols/2); //acorn
	//preset= #[[12, 0], [13, 0], [11, 1], [15, 1], [10, 2], [16, 2], [24, 2], [0, 3], [1, 3], [10, 3], [14, 3], [16, 3], [17, 3], [22, 3], [24, 3], [0, 4], [1, 4], [10, 4], [16, 4], [20, 4], [21, 4], [11, 5], [15, 5], [20, 5], [21, 5], [34, 5], [35, 5], [12, 6], [13, 6], [20, 6], [21, 6], [34, 6], [35, 6], [22, 7], [24, 7], [24, 8]]+(cols/4); //gosper glider gun, doesent work with little number...
	//preset= #[[0, 0], [2, 0], [2, 1], [4, 2], [4, 3], [6, 3], [4, 4], [6, 4], [7, 4], [6, 5]]+(rows/2); //infinite1
	//preset= #[[0, 0], [2, 0], [4, 0], [1, 1], [2, 1], [4, 1], [3, 2], [4, 2], [0, 3], [0, 4], [1, 4], [2, 4], [4, 4]]+(cols/2); //infinite2
	//preset= #[[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [9, 0], [10, 0], [11, 0], [12, 0], [13, 0], [17, 0], [18, 0], [19, 0], [26, 0], [27, 0], [28, 0], [29, 0], [30, 0], [31, 0], [32, 0], [34, 0], [35, 0], [36, 0], [37, 0], [38, 0]]+(cols/4); //infinite3

	//random
	//preset= Array.fill(cols*rows, {[cols.rand, rows.rand]});

	//schach
	//preset= Array.series((cols*rows/2).rand, [0,0], [2,0]);

	//line
	//preset = Array.series(cols, [0, 0], [1,0]);
	preset = Array.series(cols, [0, rows/2], [1,0]);


	//xess
	//preset = Array.series(cols/2, [1, rows/4], [1,0])++
	//    Array.series(cols/2, [1, rows/4*3], [1,0])++
	//    Array.series(rows/2, [cols/4, 1], [0,1])++
	//Array.series(rows/2, [cols/4*3, 1], [0,1]);

	//rect
	//preset = Array.series(cols/2, [cols/4, rows/4], [1,0])++
	//Array.series(cols/2, [cols/4, rows/4*3], [1,0])++
	//Array.series(rows/2, [cols/4, rows/4], [0,1])++
	//Array.series(rows/2, [cols/4*3-1, rows/4], [0,1]);


	//lines
	/*preset = Array.series(cols, [0, 0], [1,0])++
	Array.series(cols, [0, 2], [1,0])++
	Array.series(cols, [0, 4], [1,0])++
	Array.series(cols, [0, 6], [1,0])++
	Array.series(cols, [0, 8], [1,0])++
	Array.series(cols, [0, 10], [1,0])++
	Array.series(cols, [0, 12], [1,0])++
	Array.series(cols, [0, 14], [1,0])++
	Array.series(cols, [0, 16], [1,0])++
	Array.series(cols, [0, 18], [1,0])++
	Array.series(cols, [0, 20], [1,0])++
	Array.series(cols, [0, 22], [1,0])++
	Array.series(cols, [0, 24], [1,0])++
	Array.series(cols, [0, 26], [1,0])++
	Array.series(cols, [0, 28], [1,0])++
	Array.series(cols, [0, 30], [1,0]);*/


	//lines + seed
	/*preset = (Array.series(cols, [0, 0], [1,0])++
	Array.series(cols, [0, 2], [1,0])++
	Array.series(cols, [0, 4], [1,0])++
	Array.series(cols, [0, 6], [1,0])++
	Array.series(cols, [0, 8], [1,0])++
	Array.series(cols, [0, 10], [1,0])++
	Array.series(cols, [0, 12], [1,0])++
	Array.series(cols, [0, 14], [1,0])++
	Array.series(cols, [0, 16], [1,0])++
	Array.series(cols, [0, 18], [1,0])++
	Array.series(cols, [0, 20], [1,0])++
	Array.series(cols, [0, 22], [1,0])++
	Array.series(cols, [0, 24], [1,0])++
	Array.series(cols, [0, 26], [1,0])++
	Array.series(cols, [0, 28], [1,0])++
	Array.series(cols, [0, 30], [1,0])).put((cols*4).rand, [0,0]);*/


	//lines unstable
	/*preset = (Array.series(cols-2, [1, 0], [1,0])++[[0, 1], [cols-1, 1]]++
	Array.series(cols-2, [1, 2], [1,0])++[[0, 3], [cols-1, 3]]++
	Array.series(cols-2, [1, 4], [1,0])++[[0, 5], [cols-1, 5]]++
	Array.series(cols-2, [1, 6], [1,0])++[[0, 7], [cols-1, 7]]++
	Array.series(cols-2, [1, 8], [1,0])++[[0, 9], [cols-1, 9]]++
	Array.series(cols-2, [1, 10], [1,0])++[[0, 11], [cols-1, 11]]++
	Array.series(cols-2, [1, 12], [1,0])++[[0, 13], [cols-1, 13]]++
	Array.series(cols-2, [1, 14], [1,0])++[[0, 15], [cols-1, 15]]++
	Array.series(cols-2, [1, 16], [1,0])++[[0, 17], [cols-1, 17]]++
	Array.series(cols-2, [1, 18], [1,0])++[[0, 19], [cols-1, 19]]++
	Array.series(cols-2, [1, 20], [1,0])++[[0, 21], [cols-1, 21]]++
	Array.series(cols-2, [1, 22], [1,0])++[[0, 23], [cols-1, 23]]++
	Array.series(cols-2, [1, 24], [1,0])++[[0, 25], [cols-1, 25]]++
	Array.series(cols-2, [1, 26], [1,0])++[[0, 27], [cols-1, 27]]++
	Array.series(cols-2, [1, 28], [1,0])++[[0, 29], [cols-1, 29]]++
	Array.series(cols-2, [1, 30], [1,0])++[[0, 31], [cols-1, 31]]);  //.put((cols*4).rand, [0,0]);*/



	/*//lineblock
	~preset = (Array.series(cols-2, [1, 1], [1,0])++[[0, 1], [cols-1, 1]]++
	Array.series(cols-2, [1, 3], [1,0])++[[0, 3], [cols-1, 3]]++
	Array.series(cols-2, [1, 5], [1,0])++[[0, 5], [cols-1, 5]]++
	Array.series(cols-2, [1, 7], [1,0])++[[0, 7], [cols-1, 7]]++
	Array.series(cols-2, [1, 9], [1,0])++[[0, 9], [cols-1, 9]]++
	Array.series(cols-2, [1, 11], [1,0])++[[0, 11], [cols-1, 11]]++
	Array.series(cols-2, [1, 13], [1,0])++[[0, 13], [cols-1, 13]]++
	Array.series(cols-2, [1, 15], [1,0])++[[0, 15], [cols-1, 15]]++
	Array.series(cols-2, [1, 17], [1,0])++[[0, 17], [cols-1, 17]]++
	Array.series(cols-2, [1, 19], [1,0])++[[0, 19], [cols-1, 19]]++
	Array.series(cols-2, [1, 21], [1,0])++[[0, 21], [cols-1, 21]]++
	Array.series(cols-2, [1, 23], [1,0])++[[0, 23], [cols-1, 23]]++
	Array.series(cols-2, [1, 25], [1,0])++[[0, 25], [cols-1, 25]]++
	Array.series(cols-2, [1, 27], [1,0])++[[0, 27], [cols-1, 27]]++
	Array.series(cols-2, [1, 29], [1,0])++[[0, 29], [cols-1, 29]]++
	Array.series(cols-2, [1, 31], [1,0])++[[0, 31], [cols-1, 31]]);  //.put((cols*4).rand, [0,0]);*/



	/*	//lines + seed stable!!!!!!
	preset = (Array.series(cols-2, [1, 1], [1,0])++[[0, 1], [cols-1, 1]]++
	Array.series(cols-2, [1, 3], [1,0])++[[0, 3], [cols-1, 3]]++
	Array.series(cols-2, [1, 5], [1,0])++[[0, 5], [cols-1, 5]]++
	Array.series(cols-2, [1, 7], [1,0])++[[0, 7], [cols-1, 7]]++
	Array.series(cols-2, [1, 9], [1,0])++[[0, 9], [cols-1, 9]]++
	Array.series(cols-2, [1, 11], [1,0])++[[0, 11], [cols-1, 11]]++
	Array.series(cols-2, [1, 13], [1,0])++[[0, 13], [cols-1, 13]]++
	Array.series(cols-2, [1, 15], [1,0])++[[0, 15], [cols-1, 15]]++
	Array.series(cols-2, [1, 17], [1,0])++[[0, 17], [cols-1, 17]]++
	Array.series(cols-2, [1, 19], [1,0])++[[0, 19], [cols-1, 19]]++
	Array.series(cols-2, [1, 21], [1,0])++[[0, 21], [cols-1, 21]]++
	Array.series(cols-2, [1, 23], [1,0])++[[0, 23], [cols-1, 23]]++
	Array.series(cols-2, [1, 25], [1,0])++[[0, 25], [cols-1, 25]]++
	Array.series(cols-2, [1, 27], [1,0])++[[0, 27], [cols-1, 27]]++
	Array.series(cols-2, [1, 29], [1,0])++[[0, 29], [cols-1, 29]]++
	Array.series(cols-2, [1, 31], [1,0])++[[0, 31], [cols-1, 31]]);  //.put((cols*4).rand, [0,0]);*/



	//preset= Array.series((cols*rows/2).rand, [0,0], [2,0]).put(cols.rand, [0,0]);
	//preset= #[[0, 1], [1, 1], [2, 2], [3, 3], [0, 31], [1, 31], [31, 31]]; //debug
	preset.do{|point| envir.put(point[1], point[0], 1)};

	i= 0;
	j= 0;
	k = 0;
	l = 0;
	c = 0;

	b.sendMsg("/CAN0", 0x200, 4, 0, 0, 0, 0);
	0.02.wait;

	loop {
		i.postln;
		i= i+1;
		j= 0;

		//	if(i>=10, {
		//		~preset.do{|point| envir.put(point[1], point[0], 1)};
		//		i = 0;
		//	});

		//drawing
		rows.do{|y|
			cols.do{|x|
/*				if(l == 3, {
						b.sendMsg("/CAN0", 0x200+x, 4, 0, 0, 0, 0);
					l = 0;
				});*/
				c = 55.rand + 200;
				if(envir.at(y, x)==1, {
					textItem = genContext[j].asString;
					b.sendMsg("/CAN0", 0x280, 8, ((x*4) >> 8) & 0xFF, (x*4) & 0xFF, (y*8), c, c, c, 1, textItem.ascii[0]);
					0.02.wait;
				});
				if(envir.at(y, x)==0, {
				b.sendMsg("/CAN0", 0x280, 8, ((x*4) >> 8) & 0xFF, (x*4) & 0xFF, (y*8), 255, 255, 255, 1, " ".ascii[0]);
				0.02.wait;
				});
				j= j+1;
				if(j>=genContext.size, {j=0;});
			};
		};

		//update

		rows.do{|y|
			cols.do{|x|
				var sum= 0;
				neighbours.do{|point|
					var nX= x+point[1];
					var nY= y+point[0];
					if(wrap, {
						sum= sum+envir.at(nY%rows, nX%cols); //no borders
						}, {
							if((nX>=0)&&(nY>=0)&&(nX<cols)&&(nY<rows), {sum= sum+envir.at(nY, nX)}); //borders
					});
				};
				if(rule[1].includes(sum), {     //borne
					copy.put(y, x, 1);
					}, {
						if(rule[0].includes(sum), {     //lives on
							copy.put(y, x, envir.at(y, x));
							}, {    //dies
								copy.put(y, x, 0);
						});
				});
			};
		};
		envir= copy.deepCopy;
		//0.1.wait;

	};
});
);