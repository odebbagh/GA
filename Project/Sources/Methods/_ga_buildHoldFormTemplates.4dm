//%attributes = {}

/*
Method Name : _ga_buildHoldFormTemplates
Purpose     : Writes the seeds of the two hold forms printed from the NCMN / ISSNF windows:
                Resources/4DWriteProPrintTemplates/GAF-1014.4wp  Non-Conforming Material Notice
                Resources/4DWriteProPrintTemplates/GAF-1514.4wp  Internal Start/Stop Notification
              drawn like the paper forms: Project/Data/GAF/gaf-1014-rev 08.pdf and
              gaf-1514-rev 00.pdf.

READ THIS FIRST
  Run _ga_installHoldFormModels: it calls this method, then loads both files into Document
  Management > Models as GAF-1014 and GAF-1514. From then on the layout is edited there, in the
  Write Pro editor: LotHoldForm_print reads the model, not these files.

HOW IT IS DRAWN
  Every element of the paper form is an anchored text box placed where the PDF has it: the
  coordinates below are the PDF's own (points, 612 x 792 page), read from its content stream,
  with the y axis turned to count from the top of the paper. Labels are placed by their
  baseline, the frame bars and the lines to write on are black boxes, the tick boxes bordered
  boxes. Fonts are the PDF's: Times New Roman, Arial, Palatino Linotype.

  The values are {{tokens}}, each in its own box sitting on the line it fills, replaced at print
  time by _wpFill (LotHoldForm_printContext lists them). A tick box holds {{box...}}: "X" or
  nothing. A token typed in the editor without a key there stays visible on the print, on
  purpose. A value longer than its line is cut, as it would be on paper.
*/

var $doc : Object
var $folder : 4D:C1709.Folder
var $times : Object
var $timesBold : Object
var $value : Object
var $small : Object
var $item : Collection
var $top : Real

$folder:=Folder(fk resources folder).folder("4DWriteProPrintTemplates")
If (Not($folder.exists))
	$folder.create()
End if

// ============================================================
// GAF-1014  NON-CONFORMING MATERIAL NOTICE (NMN), Rev. 08
// ============================================================

$doc:=_wpHoldFormNewDoc

_wpGafPicture($doc; "image/modeles/GA_Logo.png"; 47.04; 38.88; 126.96; 38.16)

//---the frame: two verticals and the seven horizontal bars, 1.92pt
_wpGafRect($doc; 43.44; 80.4; 1.92; 649.2)
_wpGafRect($doc; 565.44; 80.4; 1.92; 649.2)
For each ($top; [80.4; 104.64; 124.08; 146.16; 377.04; 603.12; 727.68])
	_wpGafRect($doc; 45.36; $top; 522; 1.92)
End for each

//---the lines to write on, 0.72pt: [x; top; width]
For each ($item; [\
	[461.9; 100.1; 54.8]; \
	[100.3; 192.3; 74.3]; [221.9; 192.3; 69.7]; [336.6; 192.3; 54]; [435.7; 192.3; 45]; \
	[180.6; 215.6; 85.5]; [371.9; 215.6; 60]; \
	[110.88; 251.4; 454.08]; [44.64; 268; 519.6]; [44.64; 283.6; 519.6]; [44.64; 299.2; 519.6]; \
	[44.64; 313.8; 519.6]; [44.64; 330.4; 519.6]; [44.64; 346; 519.6]; [44.64; 361.6; 519.6]; \
	[485.52; 390.4; 65.28]; \
	[45.6; 431.6; 520.3]; [45.6; 447.2; 520.3]; [45.6; 462.8; 520.3]; [45.6; 478.4; 520.3]; \
	[45.6; 494; 520.3]; [45.6; 508.7; 520.3]; [45.6; 525.2; 520.3]; [45.6; 572; 520.3]; [45.6; 587.6; 520.3]; \
	[156; 652.9; 166.08]; [134.64; 673.3; 186.72]; [114; 691.1; 208.08]; [129.12; 711.2; 192.24]; \
	[401.76; 652.9; 64.8]; [402.72; 672.4; 64.56]; [402.72; 691.8; 64.56]; [401.76; 711.2; 64.8]])
	_wpGafRect($doc; $item[0]; $item[1]; $item[2]; 0.72)
End for each

//---the tick boxes: [x; top; width; height; token]
For each ($item; [\
	[86.4; 202.8; 12.72; 11.76; "boxOnHold"]; [277.2; 203.52; 11.76; 11.76; "boxWillHold"]; [449.04; 204.96; 12; 11.04; "boxInfo"]; \
	[87.36; 221.52; 12.48; 11.76; "boxYield"]; [162.96; 223.68; 12.48; 11.04; "boxCount"]; \
	[288.96; 223.68; 11.76; 11.04; "boxMaterial"]; [379.68; 222.24; 13.44; 11.76; "boxOther"]; \
	[343.44; 380.4; 14.16; 11.76; "boxCarNo"]; [405.84; 381.84; 14.16; 11.76; "boxCarYes"]; \
	[50.16; 638.64; 12.72; 14.64; "boxCs"]; [50.16; 658.08; 12.72; 14.64; "boxEng"]; \
	[51.12; 678.24; 12.48; 14.88; "boxQa"]; [51.12; 697.68; 12.48; 14.88; "boxProd"]])
	_wpGafCheck($doc; $item[0]; $item[1]; $item[2]; $item[3]; $item[4])
End for each

//---the printed text: [x; baseline; width; text; style]
$times:={size: 10.08}
$timesBold:={size: 10.08; bold: True}
For each ($item; [\
	[376.8; 74.64; 50; "No."; {font: "Palatino Linotype"; size: 18; bold: True}]; \
	[94.32; 98.64; 330; "NON-CONFORMING MATERIAL NOTICE (NMN)"; {size: 13.92; bold: True}]; \
	[437.9; 98.64; 24; "No."; {size: 13.92; bold: True}]; \
	[46.32; 118.8; 34; "Cust #:"; $times]; [162.6; 118.8; 48; "Traveler #:"; $times]; \
	[243.6; 118.8; 40; "Device #:"; $times]; [375.84; 121.2; 38; "Package:"; $times]; \
	[46.32; 144.48; 36; "Lot Qty:"; $times]; [143.1; 144.48; 64; "Qty. Inspected:"; $times]; \
	[291.6; 144.48; 60; "Qty. Rejected:"; $times]; [437.9; 144.48; 62; "Qty. Accepted:"; $times]; \
	[46.8; 174.48; 220; "PROBLEM DESCRIPTION:"; {size: 13.92; bold: True}]; \
	[46.32; 190.56; 56; "Originator:"; $timesBold]; [192.6; 190.56; 32; "Date:"; $timesBold]; \
	[310.4; 190.56; 32; "Time:"; $timesBold]; [407.2; 190.56; 40; "M/C#:"; $timesBold]; \
	[46.32; 213.84; 36; "Status:"; $times]; [121.3; 213.84; 60; "Lot on hold at"; $times]; \
	[295.4; 213.84; 76; "Lot will be held at"; $times]; [469.4; 213.84; 96; "For information only"; $times]; \
	[46.32; 233.28; 38; "Reason:"; $times]; [122.8; 233.28; 30; "Yield"; $times]; \
	[191.28; 233.28; 90; "Count Discrepancy"; $times]; [311.9; 233.28; 40; "Material"; $times]; \
	[404.2; 233.28; 30; "Other"; $times]; \
	[46.32; 248.88; 90; "Problem in detail:"; $times]; \
	[46.8; 392.88; 120; "DISPOSITION:"; {size: 13.92; bold: True}]; \
	[272.1; 391.2; 24; "CAR:"; $times]; [366.6; 391.2; 16; "No"; $times]; [431.9; 391.2; 64; "Yes,  CAR #:"; $times]; \
	[46.8; 634.56; 100; "APPROVALS:"; {size: 13.92; bold: True}]; \
	[77.9; 651.36; 110; "Customer Service:"; {size: 12; bold: True}]; [77.9; 670.8; 80; "Engineering:"; {size: 12; bold: True}]; \
	[77.9; 690.24; 60; "QA/QC:"; {size: 12; bold: True}]; [77.9; 709.68; 80; "Production:"; {size: 12; bold: True}]; \
	[375.84; 650.4; 26; "Date:"; $times]; [375.84; 669.84; 26; "Date:"; $times]; \
	[375.84; 689.28; 26; "Date:"; $times]; [375.84; 708.72; 26; "Date:"; $times]; \
	[46.32; 755.04; 120; "[Reference:  QA 65014]"; {font: "Arial"; size: 9.12}]; \
	[402.9; 755.04; 110; "GAF-1014, Rev. 08"; {font: "Arial"; size: 9.12}]])
	_wpGafText($doc; $item[0]; $item[1]; $item[2]; $item[3]; $item[4])
End for each

//---the values, each on its line: [x; baseline; width; token; style]
$value:={size: 9}
$small:={size: 8}
For each ($item; [\
	[463; 97.6; 54; "{{ncmnNumber}}"; {size: 11; bold: True}]; \
	[80; 118.8; 82; "{{customer}}"; $small]; [210.5; 118.8; 32; "{{traveler}}"; $small]; \
	[284; 118.8; 90; "{{device}}"; $small]; [414; 121.2; 148; "{{package}}"; $small]; \
	[82; 144.48; 60; "{{lotQty}}"; $small]; [208; 144.48; 82; "{{qtyInspected}}"; $small]; \
	[352; 144.48; 84; "{{qtyRejected}}"; $small]; [502; 144.48; 62; "{{qtyAccepted}}"; $small]; \
	[101; 190.5; 74; "{{originator}}"; $value]; [223; 190.5; 69; "{{date}}"; $value]; \
	[338; 190.5; 52; "{{time}}"; $value]; [437; 190.5; 44; "{{machine}}"; $value]; \
	[181; 213.4; 95; "{{onHoldAt}}"; {size: 7.5}]; [372.5; 213.4; 76; "{{willHoldAt}}"; {size: 7.5}]; \
	[487; 389.2; 63; "{{carNumber}}"; $value]; \
	[176; 651; 146; "{{csName}}"; $value]; [146; 671.4; 175; "{{engName}}"; $value]; \
	[124; 689.2; 198; "{{qaName}}"; $value]; [144; 709.3; 177; "{{prodName}}"; $value]; \
	[404; 651; 62; "{{csDate}}"; $value]; [404; 670.5; 62; "{{engDate}}"; $value]; \
	[404; 689.9; 62; "{{qaDate}}"; $value]; [404; 709.3; 62; "{{prodDate}}"; $value]])
	_wpGafText($doc; $item[0]; $item[1]; $item[2]; $item[3]; $item[4])
End for each

//---the two texts, written on the ruled lines (15.6pt apart)
_wpGafText($doc; 48; 266.8; 514; "{{problemDetail}}"; {size: 10; lineHeight: 15.6; height: 110})
_wpGafText($doc; 48; 430.4; 514; "{{disposition}}"; {size: 10; lineHeight: 15.6; height: 170})

WP EXPORT DOCUMENT($doc; $folder.file("GAF-1014.4wp").platformPath; wk 4wp)

// ============================================================
// GAF-1514  INTERNAL START/STOP NOTIFICATION FORM, Rev. 00
// ============================================================

$doc:=_wpHoldFormNewDoc

_wpGafPicture($doc; "image/modeles/GA_Logo.png"; 58.56; 80.88; 109.92; 52.32)

//---the double frame: outer 1.2pt, inner 0.96pt
_wpGafRect($doc; 76.32; 133.2; 465.84; 1.2)
_wpGafRect($doc; 78.48; 135.12; 461.76; 0.96)
_wpGafRect($doc; 78.48; 721.68; 461.76; 0.96)
_wpGafRect($doc; 76.32; 723.6; 465.84; 1.2)
_wpGafRect($doc; 76.32; 133.2; 1.2; 591.6)
_wpGafRect($doc; 78.48; 135.12; 0.96; 587.52)
_wpGafRect($doc; 539.28; 135.12; 0.96; 587.52)
_wpGafRect($doc; 540.96; 133.2; 1.2; 591.6)

//---the lines to write on: [x; top; width; height]. LOCATION / PROCESS is longer than on paper:
//   a step name does not fit the 93pt of the original line, and nothing is on its right.
For each ($item; [\
	[251.28; 223.44; 92.64; 1.2]; [251.28; 239.04; 92.64; 1.2]; [251.28; 254.64; 92.64; 1.2]; [251.28; 270.24; 285; 1.2]; \
	[422; 222.4; 96; 0.72]; [428; 238.4; 96; 0.72]; [457; 253.8; 60; 0.72]; \
	[145; 705.4; 138; 0.72]; [379; 705.6; 138; 0.72]])
	_wpGafRect($doc; $item[0]; $item[1]; $item[2]; $item[3])
End for each
For each ($top; [315.9; 331.5; 347.1; 362.7; 378.3; 393.9; 409.5; 425.1; 440.7; 456.3; \
	518.7; 534.3; 549.9; 565.5; 581.1; 596.7; 612.3; 627.9; 643.5; 659.1])
	_wpGafRect($doc; 134.2; $top; 354; 0.72)
End for each

$timesBold:={size: 12; bold: True}
For each ($item; [\
	[175; 102.72; 365; "INTERNAL START/STOP NOTIFICATION FORM"; {font: "Arial"; size: 16.08; bold: True}]; \
	[125.6; 150.48; 330; "CONCERN / ISSUE PRO-ACTIVE NOTIFICATION"; {size: 13.92; bold: True}]; \
	[205.7; 169.92; 160; "START / STOP FORM"; {size: 13.92; bold: True}]; \
	[80.16; 220.56; 90; "ORIGINATOR :"; $timesBold]; [80.16; 236.4; 90; "TRAVELER :"; $timesBold]; \
	[80.16; 252; 90; "CUST #:"; $timesBold]; [80.16; 267.6; 140; "LOCATION / PROCESS:"; $timesBold]; \
	[381.8; 220.56; 40; "DATE :"; $timesBold]; [381.8; 236.64; 46; "TIME:"; $timesBold]; \
	[381.8; 252; 76; "INFORM TO:"; $timesBold]; \
	[80.16; 298.56; 160; "Description of Problem"; $timesBold]; \
	[80.16; 501.36; 100; "Disposition"; $timesBold]; \
	[80.16; 704.16; 70; "Approval :"; $timesBold]; [345.84; 704.4; 36; "Date:"; $timesBold]; \
	[79.92; 734.64; 140; "[Reference: QA-65014]"; {font: "Arial"; size: 10.08}]; \
	[449.52; 734.64; 90; "GAF# 1514 Rev. 00"; {font: "Arial"; size: 10.08}]])
	_wpGafText($doc; $item[0]; $item[1]; $item[2]; $item[3]; $item[4])
End for each

$value:={size: 10}
For each ($item; [\
	[253; 221.9; 90; "{{originator}}"; $value]; [253; 237.5; 90; "{{traveler}}"; $value]; \
	[253; 253.1; 90; "{{customer}}"; {size: 8}]; [253; 268.7; 283; "{{location}}"; $value]; \
	[424; 220.9; 94; "{{date}}"; $value]; [430; 236.9; 94; "{{time}}"; $value]; \
	[459; 252.3; 76; "{{informTo}}"; {size: 9}]; \
	[147; 703.9; 136; "{{approvalName}}"; $value]; [381; 704.1; 136; "{{approvalDate}}"; $value]])
	_wpGafText($doc; $item[0]; $item[1]; $item[2]; $item[3]; $item[4])
End for each

_wpGafText($doc; 136; 314.4; 350; "{{problemDetail}}"; {size: 10; lineHeight: 15.6; height: 158})
_wpGafText($doc; 136; 517.2; 350; "{{disposition}}"; {size: 10; lineHeight: 15.6; height: 158})

WP EXPORT DOCUMENT($doc; $folder.file("GAF-1514.4wp").platformPath; wk 4wp)
