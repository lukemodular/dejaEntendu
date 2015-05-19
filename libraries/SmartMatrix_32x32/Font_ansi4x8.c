// Created from bdf2c Version 3, (c) 2009, 2010 by Lutz Sammer
//	License AGPLv3: GNU Affero General Public License version 3

#include "MatrixFontCommon.h"


	/// character bitmap for each encoding
static const unsigned char __ansi4x8_bitmap__[] = {
//  32 $20 'C040'
//	width 4, bbx 0, bby 0, bbw 0, bbh 0
	________,
	________,
	________,
	________,
	________,
	________,
	________,
	________,
//  33 $21 'C041'
//	width 4, bbx 1, bby 2, bbw 1, bbh 7
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	________,
	_X______,
	________,
//  34 $22 'C042'
//	width 4, bbx 0, bby 6, bbw 3, bbh 3
	X_X_____,
	X_X_____,
	X_X_____,
	________,
	________,
	________,
	________,
	________,
//  35 $23 'C043'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	X_X_____,
	XXX_____,
	X_X_____,
	XXX_____,
	X_X_____,
	________,
	________,
	________,
//  36 $24 'C044'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	XXX_____,
	X_______,
	_X______,
	__X_____,
	XXX_____,
	_X______,
	________,
//  37 $25 'C045'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	__X_____,
	_X______,
	_X______,
	_X______,
	X_______,
	X_X_____,
	________,
//  38 $26 'C046'
//	width 4, bbx 0, bby 2, bbw 4, bbh 7
	_X______,
	X_X_____,
	X_X_____,
	_X______,
	_X_X____,
	X_X_____,
	XXX_____,
	________,
//  39 $27 'C047'
//	width 4, bbx 1, bby 6, bbw 2, bbh 3
	_XX_____,
	__X_____,
	_X______,
	________,
	________,
	________,
	________,
	________,
//  40 $28 'C050'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	_X______,
	X_______,
	X_______,
	X_______,
	_X______,
	__X_____,
	________,
//  41 $29 'C051'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	_X______,
	__X_____,
	__X_____,
	__X_____,
	_X______,
	X_______,
	________,
//  42 $2a 'C052'
//	width 4, bbx 0, bby 3, bbw 3, bbh 5
	X_X_____,
	_X______,
	XXX_____,
	_X______,
	X_X_____,
	________,
	________,
	________,
//  43 $2b 'C053'
//	width 4, bbx 0, bby 3, bbw 3, bbh 5
	_X______,
	_X______,
	XXX_____,
	_X______,
	_X______,
	________,
	________,
	________,
//  44 $2c 'C054'
//	width 4, bbx 0, bby 1, bbw 2, bbh 3
	_X______,
	_X______,
	X_______,
	________,
	________,
	________,
	________,
	________,
//  45 $2d 'C055'
//	width 4, bbx 0, bby 5, bbw 3, bbh 1
	XXX_____,
	________,
	________,
	________,
	________,
	________,
	________,
	________,
//  46 $2e 'C056'
//	width 4, bbx 1, bby 2, bbw 1, bbh 2
	_X______,
	_X______,
	________,
	________,
	________,
	________,
	________,
	________,
//  47 $2f 'C057'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	__X_____,
	_X______,
	_X______,
	_X______,
	X_______,
	X_______,
	________,
//  48 $30 'C060'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	XXX_____,
	XXX_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
//  49 $31 'C061'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	XX______,
	_X______,
	_X______,
	_X______,
	_X______,
	XXX_____,
	________,
//  50 $32 'C062'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	__X_____,
	_X______,
	_X______,
	X_______,
	XXX_____,
	________,
//  51 $33 'C063'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	__X_____,
	_X______,
	__X_____,
	X_X_____,
	_X______,
	________,
//  52 $34 'C064'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	X_X_____,
	X_X_____,
	XXX_____,
	__X_____,
	__X_____,
	__X_____,
	________,
//  53 $35 'C065'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	X_______,
	XX______,
	__X_____,
	__X_____,
	X_X_____,
	_X______,
	________,
//  54 $36 'C066'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_______,
	XX______,
	X_X_____,
	X_X_____,
	_X______,
	________,
//  55 $37 'C067'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	__X_____,
	__X_____,
	_X______,
	_X______,
	X_______,
	X_______,
	________,
//  56 $38 'C070'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_X_____,
	_X______,
	X_X_____,
	X_X_____,
	_X______,
	________,
//  57 $39 'C071'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
	X_X_____,
	_X______,
	________,
//  58 $3a 'C072'
//	width 4, bbx 1, bby 2, bbw 1, bbh 5
	_X______,
	_X______,
	________,
	_X______,
	_X______,
	________,
	________,
	________,
//  59 $3b 'C073'
//	width 4, bbx 0, bby 1, bbw 2, bbh 6
	_X______,
	_X______,
	________,
	_X______,
	_X______,
	X_______,
	________,
	________,
//  60 $3c 'C074'
//	width 4, bbx 0, bby 2, bbw 4, bbh 7
	___X____,
	__X_____,
	_X______,
	X_______,
	_X______,
	__X_____,
	___X____,
	________,
//  61 $3d 'C075'
//	width 4, bbx 0, bby 4, bbw 3, bbh 3
	XXX_____,
	________,
	XXX_____,
	________,
	________,
	________,
	________,
	________,
//  62 $3e 'C076'
//	width 4, bbx 0, bby 2, bbw 4, bbh 7
	X_______,
	_X______,
	__X_____,
	___X____,
	__X_____,
	_X______,
	X_______,
	________,
//  63 $3f 'C077'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	__X_____,
	_X______,
	_X______,
	________,
	_X______,
	________,
//  64 $40 'C100'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
//  65 $41 'C101'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
//  66 $42 'C102'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	________,
//  67 $43 'C103'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_______,
	X_______,
	X_______,
	X_X_____,
	_X______,
	________,
//  68 $44 'C104'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	XX______,
	________,
//  69 $45 'C105'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	X_______,
	X_______,
	XX______,
	X_______,
	X_______,
	XXX_____,
	________,
//  70 $46 'C106'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	X_______,
	X_______,
	XX______,
	X_______,
	X_______,
	X_______,
	________,
//  71 $47 'C107'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_______,
	XXX_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
//  72 $48 'C110'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	X_X_____,
	XXX_____,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
//  73 $49 'C111'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	XXX_____,
	________,
//  74 $4a 'C112'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	__X_____,
	__X_____,
	__X_____,
	__X_____,
	X_X_____,
	_X______,
	________,
//  75 $4b 'C113'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	XX______,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
//  76 $4c 'C114'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	X_______,
	X_______,
	X_______,
	X_______,
	X_______,
	XXX_____,
	________,
//  77 $4d 'C115'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	XXX_____,
	XXX_____,
	XXX_____,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
//  78 $4e 'C116'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	X_X_____,
	XXX_____,
	XXX_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
//  79 $4f 'C117'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
//  80 $50 'C120'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	X_______,
	X_______,
	X_______,
	________,
//  81 $51 'C121'
//	width 4, bbx 0, bby 1, bbw 3, bbh 8
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	__X_____,
//  82 $52 'C122'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
//  83 $53 'C123'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_______,
	_X______,
	__X_____,
	X_X_____,
	_X______,
	________,
//  84 $54 'C124'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	________,
//  85 $55 'C125'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
//  86 $56 'C126'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	_X______,
	________,
//  87 $57 'C127'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	XXX_____,
	XXX_____,
	X_X_____,
	________,
//  88 $58 'C130'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	XXX_____,
	_X______,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
//  89 $59 'C131'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	_X______,
	_X______,
	_X______,
	________,
//  90 $5a 'C132'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	__X_____,
	_X______,
	_X______,
	_X______,
	X_______,
	XXX_____,
	________,
//  91 $5b 'C133'
//	width 4, bbx 1, bby 2, bbw 2, bbh 7
	_XX_____,
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	_XX_____,
	________,
//  92 $5c 'C134'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	X_______,
	_X______,
	_X______,
	_X______,
	__X_____,
	__X_____,
	________,
//  93 $5d 'C135'
//	width 4, bbx 0, bby 2, bbw 2, bbh 7
	XX______,
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	XX______,
	________,
//  94 $5e 'C136'
//	width 4, bbx 0, bby 6, bbw 3, bbh 3
	_X______,
	XXX_____,
	X_X_____,
	________,
	________,
	________,
	________,
	________,
//  95 $5f 'C137'
//	width 4, bbx 0, bby 1, bbw 4, bbh 1
	________,
	________,
	________,
	________,
	________,
	________,
	________,
	XXXX____,
//  96 $60 'C140'
//	width 4, bbx 0, bby 6, bbw 2, bbh 3
	XX______,
	X_______,
	_X______,
	________,
	________,
	________,
	________,
	________,
//  97 $61 'C141'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	XX______,
	__X_____,
	_XX_____,
	X_X_____,
	_XX_____,
	________,

//  98 $62 'C142'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	X_______,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	XX______,
	________,
//  99 $63 'C143'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	_X______,
	X_X_____,
	X_______,
	X_X_____,
	_X______,
	________,
// 100 $64 'C144'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	__X_____,
	_XX_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 101 $65 'C145'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	_X______,
	X_X_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
// 102 $66 'C146'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	_X______,
	_X______,
	XXX_____,
	_X______,
	_X______,
	_X______,
	________,
// 103 $67 'C147'
//	width 4, bbx 0, bby 1, bbw 3, bbh 6
	________,
	________,
	_XX_____,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
	XX______,

// 104 $68 'C150'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	X_______,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
// 105 $69 'C151'
//	width 4, bbx 0, bby 2, bbw 2, bbh 7
	_X______,
	________,
	XX______,
	_X______,
	_X______,
	_X______,
	_X______,
	________,
// 106 $6a 'C152'
//	width 4, bbx 0, bby 1, bbw 3, bbh 8
	__X_____,
	________,
	__X_____,
	__X_____,
	__X_____,
	__X_____,
	X_X_____,
	_X______,
// 107 $6b 'C153'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	X_______,
	X_X_____,
	X_X_____,
	XX______,
	X_X_____,
	X_X_____,
	________,
// 108 $6c 'C154'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XX______,
	_X______,
	_X______,
	_X______,
	_X______,
	_X______,
	XXX_____,
	________,
// 109 $6d 'C155'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	X_X_____,
	XXX_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
// 110 $6e 'C156'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
// 111 $6f 'C157'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 112 $70 'C160'
//	width 4, bbx 0, bby 1, bbw 3, bbh 6
	________,
	________,
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	X_______,
	X_______,
// 113 $71 'C161'
//	width 4, bbx 0, bby 1, bbw 4, bbh 6
	________,
	________,
	_XX_____,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
	__XX____,
// 114 $72 'C162'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	XX______,
	X_X_____,
	X_______,
	X_______,
	X_______,
	________,
// 115 $73 'C163'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	_XX_____,
	X_______,
	_X______,
	__X_____,
	XX______,
	________,
// 116 $74 'C164'
//	width 4, bbx 0, bby 2, bbw 3, bbh 6
	________,
	________,
	_X______,
	XXX_____,
	_X______,
	_X______,
	_X______,
	________,
// 117 $75 'C165'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 118 $76 'C166'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	_X______,
	________,
// 119 $77 'C167'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	X_X_____,
	X_X_____,
	XXX_____,
	XXX_____,
	X_X_____,
	________,
// 120 $78 'C170'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	X_X_____,
	X_X_____,
	_X______,
	X_X_____,
	X_X_____,
	________,
// 121 $79 'C171'
//	width 4, bbx 0, bby 1, bbw 3, bbh 6
	________,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
	XX______,
// 122 $7a 'C172'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	XXX_____,
	__X_____,
	_X______,
	X_______,
	XXX_____,
	________,
// 123 $7b 'C173'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	_X______,
	_X______,
	X_______,
	_X______,
	_X______,
	__X_____,
	________,
// 124 $7c 'C174'
//	width 4, bbx 1, bby 2, bbw 1, bbh 7
	_X______,
	_X______,
	_X______,
	________,
	_X______,
	_X______,
	_X______,
	________,
// 125 $7d 'C175'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	_X______,
	_X______,
	__X_____,
	_X______,
	_X______,
	X_______,
	________,
// 126 $7e 'C176'
//	width 4, bbx 0, bby 7, bbw 4, bbh 2
	_X_X____,
	X_X_____,
	________,
	________,
	________,
	________,
	________,
	________,
// 127 $7f 'C177'
//	width 4, bbx 0, bby 2, bbw 3, bbh 5
	________,
	________,
	_X______,
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
// 128 $80 'C200'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_______,
	XXX_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
// 129 $81 'C201'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 130 $82 'C202'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	_X______,
	_X______,
	X_X_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
// 131 $83 'C203'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	XX______,
	__X_____,
	_XX_____,
	X_X_____,
	_XX_____,
	________,
// 132 $84 'C204'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	________,
	XX______,
	__X_____,
	_XX_____,
	X_X_____,
	_XX_____,
	________,
// 133 $85 'C205'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	_X______,
	XX______,
	__X_____,
	_XX_____,
	X_X_____,
	_XX_____,
	________,
// 134 $86 'C206'
//	width 4, bbx 0, bby 2, bbw 3, bbh 6
	________,
	XXX_____,
	XX______,
	__X_____,
	_XX_____,
	X_X_____,
	_XX_____,
	________,
// 135 $87 'C207'
//	width 4, bbx 0, bby 1, bbw 3, bbh 6
	_XX_____,
	X_______,
	X_______,
	XXX_____,
	_X______,
	XX______,
	________,
	________,
// 136 $88 'C210'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	_X______,
	X_X_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
// 137 $89 'C211'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	________,
	_X______,
	X_X_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
// 138 $8a 'C212'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	_X______,
	_X______,
	X_X_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
// 139 $8b 'C213'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	________,
	________,
	XX______,
	_X______,
	_X______,
	_X______,
	________,
// 140 $8c 'C214'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	________,
	XX______,
	_X______,
	_X______,
	_X______,
	________,
// 141 $8d 'C215'
//	width 4, bbx 0, bby 2, bbw 2, bbh 7
	X_______,
	_X______,
	________,
	XX______,
	_X______,
	_X______,
	_X______,
	________,
// 142 $8e 'C216'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
// 143 $8f 'C217'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	XXX_____,
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
// 144 $90 'C220'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	__X_____,
	_X______,
	XXX_____,
	X_______,
	XXX_____,
	X_______,
	XXX_____,
	________,
// 145 $91 'C221'
//	width 4, bbx 0, bby 2, bbw 3, bbh 6
	X_______,
	_XX_____,
	_XX_____,
	XX______,
	XX______,
	__X_____,
	________,
	________,
// 146 $92 'C222'
//	width 4, bbx 0, bby 2, bbw 4, bbh 7
	_XXX____,
	X_X_____,
	X_X_____,
	XXXX____,
	X_X_____,
	X_X_____,
	X_XX____,
	________,
// 147 $93 'C223'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 148 $94 'C224'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	________,
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 149 $95 'C225'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	_X______,
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 150 $96 'C226'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 151 $97 'C227'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_______,
	_X______,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 152 $98 'C230'
//	width 4, bbx 0, bby 1, bbw 3, bbh 8
	X_X_____,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
	XX______,
// 153 $99 'C231'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 154 $9a 'C232'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 155 $9b 'C233'
//	width 4, bbx 0, bby 1, bbw 3, bbh 8
	_X______,
	_X______,
	X_X_____,
	X_______,
	X_______,
	X_X_____,
	_X______,
	_X______,
// 156 $9c 'C234'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	_X______,
	X_X_____,
	X_______,
	XX______,
	X_______,
	X_______,
	XXX_____,
	________,
// 157 $9d 'C235'
//	width 4, bbx 0, bby 2, bbw 3, bbh 7
	X_X_____,
	X_X_____,
	_X______,
	XXX_____,
	_X______,
	XXX_____,
	_X______,
	________,
// 158 $9e 'C236'
//	width 4, bbx 0, bby 2, bbw 4, bbh 7
	XX______,
	X_X_____,
	XX______,
	X_X_____,
	XXXX____,
	X_X_____,
	X__X____,
	________,
// 159 $9f 'C237'
//	width 4, bbx 0, bby 2, bbw 4, bbh 7
	__X_____,
	_X_X____,
	_X______,
	XXX_____,
	_X______,
	_X______,
	X_______,
	________,
};

	/// character width for each encoding
static const unsigned char __font_widths__[] = {
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
	4,
};

	/// character encoding for each index entry
static const unsigned short __ansi4x8_index__[] = {
	32,
	33,
	34,
	35,
	36,
	37,
	38,
	39,
	40,
	41,
	42,
	43,
	44,
	45,
	46,
	47,
	48,
	49,
	50,
	51,
	52,
	53,
	54,
	55,
	56,
	57,
	58,
	59,
	60,
	61,
	62,
	63,
	64,
	65,
	66,
	67,
	68,
	69,
	70,
	71,
	72,
	73,
	74,
	75,
	76,
	77,
	78,
	79,
	80,
	81,
	82,
	83,
	84,
	85,
	86,
	87,
	88,
	89,
	90,
	91,
	92,
	93,
	94,
	95,
	96,
	97,
	98,
	99,
	100,
	101,
	102,
	103,
	104,
	105,
	106,
	107,
	108,
	109,
	110,
	111,
	112,
	113,
	114,
	115,
	116,
	117,
	118,
	119,
	120,
	121,
	122,
	123,
	124,
	125,
	126,
	127,
	128,
	129,
	130,
	131,
	132,
	133,
	134,
	135,
	136,
	137,
	138,
	139,
	140,
	141,
	142,
	143,
	144,
	145,
	146,
	147,
	148,
	149,
	150,
	151,
	152,
	153,
	154,
	155,
	156,
	157,
	158,
	159,
};

	/// bitmap font structure
const struct bitmap_font ansi4x8 = {
	.Width = 4, .Height = 8,
	.Chars = 128,
	.Widths = 0,
	.Index = __ansi4x8_index__,
	.Bitmap = __ansi4x8_bitmap__,
};