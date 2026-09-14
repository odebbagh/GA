// Purpose: Profile idents allowed to assign, renew, or override staff certifications (Karla 2.d — qm, qs, dc).
// Returns: Collection of Text — qs, qm, dc
// created by 4D/PS [2026-june-02]

#DECLARE->$profiles : Collection

$profiles:=New collection:C1472("qs"; "qm"; "dc")
