//%attributes = {"executedOnServer":true}
/*
_ga_dateRelatedNotifications

*/

var $equipments : cs:C1710.EquipmentSelection

/*
Equipment out of calibration in 30 days Notifications
*/
$equipments:=ds:C1482.Equipment.query("nextCalDate<=:1 & notAtSite=:2"; Current date:C33(*)+30; False:C215)
_ga_notifier(->$equipments; "soonDueCal"; "EquipmentSoonDueCalibration"; "Equipment"; "assignedID")

/*
Due Equipment out of calibration
*/
$equipments:=ds:C1482.Equipment.query("nextCalDate<=:1 & calibrationNotRequired=:2 & notAtSite=:3"; Current date:C33(*); False:C215; False:C215)
_ga_notifier(->$equipments; "dueCal"; "DueEquipmentOutOfCalibration"; "Equipment"; "assignedID")


/*
Equipment out of PM in 30 days
*/
$equipments:=ds:C1482.Equipment.query("nextPMDate<=:1 & nextPMDate#:2 & notAtSite=:3"; Current date:C33(*)+30; !00-00-00!; False:C215)
_ga_notifier(->$equipments; "soonDuePM"; "EquipmentSoonDuePM"; "Equipment"; "assignedID")


/*
Due Equipment out of PM Notification
*/
$equipments:=ds:C1482.Equipment.query("nextPMDate<=:1 & nextPMDate#:2 & notAtSite=:3"; Current date:C33(*); !00-00-00!; False:C215)
_ga_notifier(->$equipments; "duePM"; "DueEquipmentOutOfPM"; "Equipment"; "assignedID")


/*
Employees requiring retraining or certification expiry within the next 30 days — notify linked user only.
Purpose: Uses assignment-based expiry (getCertiExpiredIn) and retrain milestones via Staff.checkRetraining.
modified by 4D/PS [2026-june-12]
*/
ds:C1482.Staff.checkRetraining(30)

/*
Critical suppliers with overdue audits
*/
var $suppliers : cs:C1710.SupplierSelection
$suppliers:=ds:C1482.Supplier.query("nextAuditDate<=:1 & nextAuditDate#:2 & critical=:3"; Current date:C33(*); !00-00-00!; True:C214)
_ga_notifier(->$suppliers; "criticalOverdueAudit"; "CriticalSuppliersWithOverdueAudits"; "Supplier"; "name")


/*
Specs Control Approval
*/
var $specification : cs:C1710.SpecificationSelection
$formula_1:=Formula:C1597((This:C1470.reviewDate+This:C1470.reviewIntervalInDays)<Current date:C33(*))
$specification:=ds:C1482.Specification.query($formula_1)
//ds.Specification.query("reviewDate<=:1 & reviewDate#:2"; Current date(*); !00-00-00!)
_ga_notifier(->$specification; "dueReview"; "SpecReviewOverdue"; "Specification"; "spec")


