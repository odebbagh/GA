//%attributes = {}
// _wpBlockStart($doc; $caption)
// Opens one of the bordered address blocks - "Issued to:", "Ship to", "Bill to".
// The legacy form used 4D group boxes, where the caption sits on the border line.
// Write Pro has no group box, so the caption is a bold paragraph above a bordered
// region; _wpBlockEnd closes it.

#DECLARE($doc : Object; $caption : Text)

_wpLine($doc; $caption; 9; True:C214)
