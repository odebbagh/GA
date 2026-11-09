//%attributes = {}

// _wpCaptionRow($row)
// Styles one table row as a section caption - the row that stands in for the caption
// sitting on a 4D group box's border. Bold and a point smaller than the content, which
// is what makes the grid read as a set of boxes rather than as a plain table.

#DECLARE($row : Object)

WP SET ATTRIBUTES($row; wk font bold; True; wk font size; 8)