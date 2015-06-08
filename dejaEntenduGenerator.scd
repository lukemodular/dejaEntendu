/////////////
//messages

"t200803020700FFFF0102"
"t"++2.asHexString(3)++8++2.asHexString(2)++255.asHexString(2)++255.asHexString(2)++1.asHexString(2)++2.asHexString(2)

///////////////////////////
//game of life /redFrik
//with letters


////////
//some calculations
/*
102 panels x 1024 pixels = 104448
height:
6 panels x 32 pixels = 192
32 letter rows (6px high)
width
17 panels x 32 pixels = 544
136 letter cols (4px wide)

to do:
-Interpreter has crashed or stopped forcefully. [Exit code: -1073741819]??

-Interface: Playrate, Seed, SeedTrigger

-spacefiller!!!!
-stable grid!!!

-text content
-noten content


4*181
256 * 1447
sqrt(370432)

*/


//line-1
~preset = Array.series(13, [1, 48/2], [1,0]);
~preset = [[0, 0],[0, 1], [0, 2], [0,3], [0,4]];



(
var w, u, width= 544, height= 192, cols= 136,rows= 48, cellWidth, cellHeight, textItem;
//real pixl 192 x 544, type 4x2 = 48 x 272, type 4x4 = 48 x 136, type 4x8 = 24 x 136
var envir, copy, neighbours, preset, rule, wrap, fontRect, snake, genContext;
var textArray, font, corpus;
var playRate = 2, playRateMax = 2;
~preset;
~cols = 136;
~rows = 48;


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



w= Window("ca - 2 pen", Rect(-5, 150, width, height), false);
u= UserView(w, w.view.bounds);
//u.background= Color.white;
u.background= Color.black;
cellWidth= width/cols;
cellHeight= height/rows;
wrap= false;                     //if borderless envir


font = Font("Arial", 4);
//Font.availableFonts;

snake = ContextSnake(a, "a", 3);	// try longer context again
genContext = snake.asStream.all.join;
genContext = genContext.asString.removeEvery(",().?/!?;:_").toUpper;
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
//preset = Array.series(cols, [0, rows/2], [1,0]);


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



//lineblock
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
Array.series(cols-2, [1, 31], [1,0])++[[0, 31], [cols-1, 31]]);  //.put((cols*4).rand, [0,0]);



//lines + seed stable!!!!!!
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
Array.series(cols-2, [1, 31], [1,0])++[[0, 31], [cols-1, 31]]);  //.put((cols*4).rand, [0,0]);



//preset= Array.series((cols*rows/2).rand, [0,0], [2,0]).put(cols.rand, [0,0]);
//preset= #[[0, 1], [1, 1], [2, 2], [3, 3], [0, 31], [1, 31], [31, 31]]; //debug
~preset.do{|point| envir.put(point[1], point[0], 1)};

i= 0;
j= 0;
k = 0;


//"debug!!".postln;

u.drawFunc= {

	if(i>=10, {
		~preset.do{|point| envir.put(point[1], point[0], 1)};
		i = 0;
	});

	i= i+1;
	j= 0;
	Pen.fillColor= Color.red;

	//drawing
	rows.do{|y|
		cols.do{|x|
			if(envir.at(y, x)==1, {
				textItem = genContext[j].asString;
				//{SinOsc.ar(200*rrand(1, 5), rrand(-1.0, 1.0), EnvGen.kr(Env([0, 0.01, 0.0], [0.001, 0.4]), doneAction: 2)) ! 2}.play;
				//Pen.addRect(Rect(x*cellWidth, height-(y*cellHeight), cellWidth, cellHeight));
				Pen.stringAtPoint(textItem, Point(x*cellWidth, y*cellHeight), font, Color.rand(0.8, 1.0));
			});
			j= j+1;
			if(j>=genContext.size, {j= 0});
		};
	};

	Pen.fill;

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
	//playRate = playRateMax.rand;
};
Routine({while{w.isClosed.not} {w.refresh; i.postln; (playRate).wait}}).play(AppClock);
w.front;

)





c = ContextSnake(a, "a", 3);	// try longer context again
c.asStream.all.join;



//rule= #[[], [3]];
//rule= #[[5, 6, 7, 8], [3, 5, 6, 7, 8]];
//rule= #[[], [2]];                                             //rule "/2" seeds
//rule= #[[], [2, 3, 4]];
//rule= #[[1, 2, 3, 4, 5], [3]];
//rule= #[[1, 2, 5], [3, 6]];
//rule= #[[1, 3, 5, 7], [1, 3, 5, 7]];
//rule= #[[1, 3, 5, 8], [3, 5, 7]];
rule= #[[2, 3], [3]];                                           //rule "23/3" conway's life
rule= #[[2, 3], [3, 6]];                                      //rule "23/36" highlife
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


//??
//a = a.collect(_.split($ ));




//////////
//Annex




(
var width= 640, height= 480;
var win= Window("text", Rect(10, 10, width, height), false);
var usr= UserView(win, Rect(0, 0, width, height));
CmdPeriod.doOnce({win.close});
win.front;
usr.drawFunc= {
        Pen.rotate(pi, width*0.5, height*0.5);
        Pen.stringAtPoint("rotated text", Point(20, 20));
        Pen.rotate(-pi, width*0.5, height*0.5);//rotate back
        Pen.stringAtPoint("text", Point(20, 20));
};
)


///
//dynamic Text

(
f = Font("7 SEGMENTAL DIGITAL DISPLAY", 44);
w = Window.new.front;
w.view.background = Color.black;
a = Array.fill(20, {StaticText(w, Rect(w.bounds.extent.x.rand, w.bounds.extent.y.rand, 160, 20))
	.string_("aaaaaaabcdeeeeeefghiiiiiijklmnooooopqrstuuuuvwxyz".choose)
	.align_(\center)
	.stringColor_(Color.black)
	.background_(Color.white)
	.font_(f)
});

r = {inf.do{|i|
	thisThread.randSeed_(1284);
	a.do{|item|
		// setting GUI values is asynchronous, so you must use .defer
		{item.bounds = Rect(5+w.bounds.extent.x.rand * (cos(i*0.01)).abs,
			w.bounds.extent.y.rand * sin(i*0.01),
			20, 37)}.defer;
	};
	0.15.wait;
}}.fork;
CmdPeriod.doOnce({w.close});
w.onClose_({r.stop});
)



//Font.availableFonts;

/*
(
w = Window.new.front;
t = StaticText(w, w.view.bounds).align_(\center);
t.font = Font("7 SEGMENTAL DIGITAL DISPLAY", 34);
t.string=" 7 SEGMENTAL DIGITAL DISPLAY";
)
*/



////////////////////////////
/*cellular automata /redFrik*/
(
var w, u, width= 400, height= 300, cellWidth= 1, cellHeight= 1;
w= Window("ca - 1", Rect(128, 64, width, height), false);
u= UserView(w, Rect(0, 0, width, height));
u.background= Color.white;
u.drawFunc= {
var pat, dict, rule, ruleRand, y= 0;

/*
rule30= 30.asBinaryDigits;              // [0, 0, 0, 1, 1, 1, 1, 0];
rule90= 90.asBinaryDigits;              // [0, 1, 0, 1, 1, 0, 1, 0];
rule110= 110.asBinaryDigits;            // [0, 1, 1, 0, 1, 1, 1, 0];
rule250= 250.asBinaryDigits;            // [1, 1, 1, 1, 1, 0, 1, 0];
rule254= 254.asBinaryDigits;            // [1, 1, 1, 1, 1, 1, 1, 0];
*/
/*-- select rule here --*/
//rule= 256.rand.postln;
//rule= 90;
rule= 30;

pat= 0.dup((width/cellWidth).round);
pat.put((pat.size/2).round, 1);
dict= ();
8.do{|i| dict.put(i.asBinaryDigits(3).join.asSymbol, rule.asBinaryDigits[7-i])};

//--render
Pen.fillColor= Color.black;
while({y*cellHeight<height}, {
pat.do{|c, x|
if(c==1, {
Pen.addRect(Rect(x*cellWidth, y*cellHeight, cellWidth, cellHeight));
});
};
pat= [0]++pat.slide(3, 1).clump(3).collect{|c|
dict.at(c.join.asSymbol);
}++[0];
y= y+1;
});
Pen.fill;
};
w.front;
)


//////////////////////////////////////////////////////////////////


//game of life /redFrik
(
        var envir, copy, neighbours, preset, rule, wrap;
        var w, u, width= 200, height= 200, rows= 50, cols= 50, cellWidth, cellHeight;
        w= Window("ca - 2 pen", Rect(128, 64, width, height), false);
        u= UserView(w, Rect(0, 0, width, height));
        u.background= Color.white;
        cellWidth= width/cols;
        cellHeight= height/rows;
        wrap= true;                     //if borderless envir
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
        preset= Array.fill(cols*rows, {[cols.rand, rows.rand]});
        //preset= #[[0, 1], [1, 1], [2, 2], [3, 3], [0, 31], [1, 31], [31, 31]];
        preset.do{|point| envir.put(point[0], point[1], 1)};
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
        };
        Routine({while{w.isClosed.not} {u.refresh; i.postln; (1/20).wait}}).play(AppClock);
        w.front;
)





*/


