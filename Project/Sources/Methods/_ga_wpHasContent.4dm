//%attributes = {}
// _ga_wpHasContent($wp) -> True when $wp is a 4D Write Pro document holding text, a table or a picture
// An Object field never null (Quote.optionalPreliminaryTxt_wr) can hold an empty {} instead of a document:
// the Write Pro commands are run inside Try(), so anything that is not a document counts as empty.
// Used by QuoteEntity.snapshot and panel_quote.quoteDocument.
#DECLARE($wp : Variant)->$has : Boolean

If (Value type:C1509($wp)#Is object:K8:27)
	return 
End if
$has:=Bool:C1537(Try((WP Get text:C1575($wp; wk expressions as value)#"") || (WP Get elements:C1550($wp; wk type table).length>0) || (WP Get elements:C1550($wp; wk type image:K81:192).length>0)))
