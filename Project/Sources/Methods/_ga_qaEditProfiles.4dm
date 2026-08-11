// Purpose: Profile idents allowed to edit Quality Assurance records (CAR, RMA, Specs, AML, etc.).
// Certification assign/override uses _ga_qaCertModifyProfiles (qs, qm, dc) instead.
// Returns: Collection of Text — qs, qi, qm
// modified by 4D/PS [2026-june-02]
#DECLARE->$profiles : Collection

$profiles:=New collection:C1472("qs"; "qi"; "qm")
