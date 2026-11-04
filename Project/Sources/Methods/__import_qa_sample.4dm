//%attributes = {"executedOnServer":true}

// Purpose: Seed a small coherent QA test set from the DataJson pack already on this machine.
// Run after __import_data_facilities. Does not rebuild Staff, Team, certifications, or assignments already imported.
// Run manually on the server. Do not call from Staff/CAR/RMA entry UI.
// created by 4D/PS [2026-october-09]
// modified by 4D/PS [2026-november-04]

cs:C1710.qa_sampleData.me.run()
