// Generic "who is approving this?" component.
//
// One call does the whole sequence: scan window -> barcode or manual user code ->
// resolve the [Staff] record and its [sfw_User] account -> optional profile check ->
// optional password check. Every message is produced here, so a caller never repeats
// the alert table.
//
//   $result:=cs.Util_Authorizer.me.requestApproval(New object(\
//       "profiles"; New collection("BOAPPROVER"); \
//       "profileLabel"; "BO Approver"; \
//       "requirePassword"; True; \
//       "title"; "Approver 1"))
//
//   If ($result.success)   -> $result.staff / $result.user / $result.code / $result.stamp
//   If ($result.cancelled) -> the operator backed out, say nothing
//   otherwise              -> the alert has already been shown
//
// Options (all optional except profiles when a profile is required):
//   profiles            Collection or Text - accepted profile idents, compared
//                       case-insensitively. Empty/absent = no profile requirement.
//   profileLabel        Text  - human name used in the refusal message.
//   requirePassword     Bool  - ask for the account password and verify it.
//   passwordSource      Text  - "login" (default) reads accesses.password.hash.
//                       Kept as an option so a separate approval password can be
//                       added later without touching any caller.
//   allowManualEntry    Bool  - default True. False hides the manual-entry route.
//   allowTemporaryPassword  Bool - default False: an account still on its emailed
//                       temporary password may not approve.
//   excludeStaffUUIDs   Collection - staff already used elsewhere on the record,
//                       e.g. to stop one person filling both approver slots.
//   maxPasswordAttempts Integer - default 3.
//   title               Text  - caption of the credentials window.

shared singleton Class constructor
	//It's a singleton class

	//Mark:-Public

Function requestApproval($options : Object)->$result : Object
	var $opt : Object
	var $identification : Object
	var $resolution : Object
	var $eStaff : cs:C1710.StaffEntity
	var $eUser : cs:C1710.sfw_UserEntity
	var $passwordCheck : Object

	$result:=New object:C1471("success"; False:C215; "cancelled"; False:C215; "failureReason"; "")
	$opt:=This:C1470._normalizeOptions($options)

	//1. who is it: barcode, typed user code, or nothing
	$identification:=This:C1470._identify($opt)
	If ($identification.cancelled)
		$result.cancelled:=True:C214
		return
	End if

	//2. resolve to a Staff record carrying an application account
	$resolution:=This:C1470._resolveStaff($identification)
	If (Not:C34($resolution.success))
		$result.failureReason:=$resolution.failureReason
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	$eStaff:=$resolution.staff
	$eUser:=$eStaff.user

	//3. the account must be usable
	If (Bool:C1537($eUser.isInactive)) || (Bool:C1537($eStaff.inactive)) || (Bool:C1537($eStaff.terminated))
		$result.failureReason:="inactiveAccount"
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	//4. not someone who already signed another slot on this record
	If ($opt.excludeStaffUUIDs.indexOf(String:C10($eStaff.UUID))#-1)
		$result.failureReason:="alreadyUsed"
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	//5. profile membership
	If ($opt.profiles.length>0)
		If (Not:C34(This:C1470.isInAnyProfile($eUser; $opt.profiles)))
			$result.failureReason:="notInProfile"
			This:C1470._alert($result.failureReason; $opt)
			return
		End if
	End if

	//6. password
	If ($opt.requirePassword)
		$passwordCheck:=This:C1470._checkPassword($eUser; $eStaff; $opt)
		If ($passwordCheck.cancelled)
			$result.cancelled:=True:C214
			return
		End if
		If (Not:C34($passwordCheck.success))
			$result.failureReason:=$passwordCheck.failureReason
			This:C1470._alert($result.failureReason; $opt)
			return
		End if
	End if

	$result.success:=True:C214
	$result.staff:=$eStaff
	$result.user:=$eUser
	$result.code:=$eStaff.code
	$result.stamp:=cs:C1710.sfw_stmp.me.now()

Function requestApprovalFromStaff($eStaff : cs:C1710.StaffEntity; $options : Object)->$result : Object
	// Approval by a person who is ALREADY KNOWN - it asks only for their password.
	//
	// requestApproval starts by identifying whoever is standing at the machine (barcode
	// or typed user code) and then asks for their password. That is right when anybody
	// might be signing. It is wrong once the approver has been named on the record: the
	// buy order already says who must sign, so the only question left is "prove you are
	// them", and being asked to scan yourself first is noise.
	//
	// Everything after identification is the same: active account, profile membership,
	// password, same result shape.
	var $opt : Object
	var $eUser : cs:C1710.sfw_UserEntity
	var $passwordCheck : Object

	$result:=New object:C1471("success"; False:C215; "cancelled"; False:C215; "failureReason"; "")
	$opt:=This:C1470._normalizeOptions($options)

	If ($eStaff=Null:C1517)
		$result.failureReason:="codeNotFound"
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	$eUser:=$eStaff.user
	If ($eUser=Null:C1517)
		$result.failureReason:="noUserAccount"
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	//---the account must be usable
	If (Bool:C1537($eUser.isInactive)) || (Bool:C1537($eStaff.inactive)) || (Bool:C1537($eStaff.terminated))
		$result.failureReason:="inactiveAccount"
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	//---not someone who already signed another slot on this record
	If ($opt.excludeStaffUUIDs.indexOf(String:C10($eStaff.UUID))#-1)
		$result.failureReason:="alreadyUsed"
		This:C1470._alert($result.failureReason; $opt)
		return
	End if

	//---profile membership
	If ($opt.profiles.length>0)
		If (Not:C34(This:C1470.isInAnyProfile($eUser; $opt.profiles)))
			$result.failureReason:="notInProfile"
			This:C1470._alert($result.failureReason; $opt)
			return
		End if
	End if

	//---password. _checkPassword names the person in the prompt, so the operator sees
	//   whose password is being asked for.
	If ($opt.requirePassword)
		$passwordCheck:=This:C1470._checkPassword($eUser; $eStaff; $opt)
		If ($passwordCheck.cancelled)
			$result.cancelled:=True:C214
			return
		End if
		If (Not:C34($passwordCheck.success))
			$result.failureReason:=$passwordCheck.failureReason
			This:C1470._alert($result.failureReason; $opt)
			return
		End if
	End if

	$result.success:=True:C214
	$result.staff:=$eStaff
	$result.user:=$eUser
	$result.code:=$eStaff.code
	$result.stamp:=cs:C1710.sfw_stmp.me.now()
Function isInAnyProfile($eUser : cs:C1710.sfw_UserEntity; $profiles : Collection)->$isIn : Boolean
	//Case-insensitive membership test. Call sites in this application spell the same
	//profile "CS", "cs" and "Eng", so both sides are folded before comparing.
	var $userProfiles : Collection
	var $wanted : Text

	$isIn:=False:C215
	If ($eUser=Null:C1517) || ($profiles=Null:C1517) || ($profiles.length=0)
		return
	End if

	//ORDA projects this straight to a collection of idents, as Staff_isInUserProfile does
	$userProfiles:=$eUser.userInscriptions.userProfile.ident
	If ($userProfiles=Null:C1517)
		$userProfiles:=New collection:C1472
	End if
	$userProfiles:=This:C1470._upperCased($userProfiles)

	For each ($wanted; This:C1470._upperCased($profiles))
		If ($userProfiles.indexOf($wanted)#-1)
			$isIn:=True:C214
			return
		End if
	End for each

	//a Designer account passes an "admin" requirement, as Staff_isInUserProfile does
	If (Bool:C1537($eUser.accesses.asDesigner)) && (This:C1470._upperCased($profiles).indexOf("ADMIN")#-1)
		$isIn:=True:C214
	End if

	//Mark:-Steps

Function _normalizeOptions($options : Object)->$opt : Object
	//Fills in every default so the rest of the class never tests for Null
	$opt:=New object:C1471

	If ($options=Null:C1517)
		$options:=New object:C1471
	End if

	Case of
		: ($options.profiles=Null:C1517)
			$opt.profiles:=New collection:C1472
		: (Value type:C1509($options.profiles)=Is text:K8:3)
			$opt.profiles:=New collection:C1472($options.profiles)
		: (Value type:C1509($options.profiles)=Is collection:K8:32)
			$opt.profiles:=$options.profiles
		Else
			$opt.profiles:=New collection:C1472
	End case

	$opt.profileLabel:=String:C10($options.profileLabel)
	If ($opt.profileLabel="") && ($opt.profiles.length>0)
		$opt.profileLabel:=String:C10($opt.profiles[0])
	End if

	$opt.title:=($options.title=Null:C1517) ? "Approval" : String:C10($options.title)
	$opt.requirePassword:=Bool:C1537($options.requirePassword)
	$opt.passwordSource:=($options.passwordSource=Null:C1517) ? "login" : String:C10($options.passwordSource)
	$opt.allowManualEntry:=($options.allowManualEntry=Null:C1517) ? True:C214 : Bool:C1537($options.allowManualEntry)
	$opt.allowTemporaryPassword:=Bool:C1537($options.allowTemporaryPassword)
	$opt.excludeStaffUUIDs:=($options.excludeStaffUUIDs=Null:C1517) ? New collection:C1472 : $options.excludeStaffUUIDs
	$opt.maxPasswordAttempts:=(Num:C11($options.maxPasswordAttempts)>0) ? Num:C11($options.maxPasswordAttempts) : 3

Function _identify($opt : Object)->$identification : Object
	//Scan window first. "Manual entry" there reopens as a typed-code dialog.
	var $scan : Object
	var $credentials : Object

	$identification:=New object:C1471("cancelled"; False:C215; "barcodeData"; ""; "code"; "")

	$scan:=This:C1470._openScanWindow($opt)
	If ($scan.cancelled)
		$identification.cancelled:=True:C214
		return
	End if

	If (Not:C34($scan.manualEntry))
		$identification.barcodeData:=$scan.barcodeData
		return
	End if

	If (Not:C34($opt.allowManualEntry))
		$identification.cancelled:=True:C214
		return
	End if

	$credentials:=This:C1470._openCredentialsWindow("code"; $opt; "")
	If ($credentials.cancelled) || ($credentials.userCode="")
		$identification.cancelled:=True:C214
		return
	End if
	$identification.code:=$credentials.userCode

Function _resolveStaff($identification : Object)->$resolution : Object
	//Barcode hits Staff.moreData.barcodeData, a typed code hits Staff.code.
	//Exactly one match is required, and it must carry an application account.
	var $esStaff : cs:C1710.StaffSelection
	var $eStaff : cs:C1710.StaffEntity
	var $byBarcode : Boolean

	$resolution:=New object:C1471("success"; False:C215; "failureReason"; "")
	$byBarcode:=($identification.code="")

	If ($byBarcode)
		If ($identification.barcodeData="")
			$resolution.failureReason:="barcodeNotFound"
			return
		End if
		$esStaff:=ds:C1482.Staff.query("moreData.barcodeData = :1"; $identification.barcodeData)
	Else
		$esStaff:=ds:C1482.Staff.query("code = :1"; $identification.code)
	End if

	Case of
		: ($esStaff.length=0)
			$resolution.failureReason:=$byBarcode ? "barcodeNotFound" : "codeNotFound"
			return
		: ($esStaff.length>1)
			$resolution.failureReason:="ambiguous"
			return
	End case

	$eStaff:=$esStaff.first()
	If ($eStaff.user=Null:C1517)
		$resolution.failureReason:="noUserAccount"
		return
	End if

	$resolution.success:=True:C214
	$resolution.staff:=$eStaff

Function _checkPassword($eUser : cs:C1710.sfw_UserEntity; $eStaff : cs:C1710.StaffEntity; $opt : Object)->$check : Object
	//Verifies the account password, the same bcrypt hash the login form checks.
	var $hash : Text
	var $credentials : Object
	var $attempts : Integer

	$check:=New object:C1471("success"; False:C215; "cancelled"; False:C215; "failureReason"; "")

	$hash:=This:C1470._passwordHash($eUser; $opt)
	If ($hash="")
		$check.failureReason:="noPassword"
		return
	End if

	If (Not:C34($opt.allowTemporaryPassword)) && (Bool:C1537($eUser.accesses.password.temporary))
		$check.failureReason:="temporaryPassword"
		return
	End if

	$attempts:=0
	While ($attempts<$opt.maxPasswordAttempts)
		$attempts:=$attempts+1

		$credentials:=This:C1470._openCredentialsWindow("password"; $opt; $eStaff.fullName)
		If ($credentials.cancelled)
			$check.cancelled:=True:C214
			return
		End if

		If (Verify password hash:C1534($credentials.password; $hash))
			$check.success:=True:C214
			return
		End if

		If ($attempts<$opt.maxPasswordAttempts)
			cs:C1710.sfw_dialog.me.alert("Incorrect password. "+String:C10($opt.maxPasswordAttempts-$attempts)+" attempt(s) left.")
		End if
	End while

	$check.failureReason:="wrongPassword"

Function _passwordHash($eUser : cs:C1710.sfw_UserEntity; $opt : Object)->$hash : Text
	//Single place that knows where the hash lives, so a dedicated approval password
	//can be introduced later by adding one branch here.
	$hash:=""
	If ($eUser.accesses=Null:C1517)
		return
	End if

	Case of
		: ($opt.passwordSource="approval")
			If ($eUser.accesses.approvalPassword#Null:C1517)
				$hash:=String:C10($eUser.accesses.approvalPassword.hash)
			End if
		Else
			If ($eUser.accesses.password#Null:C1517)
				$hash:=String:C10($eUser.accesses.password.hash)
			End if
	End case

	//Mark:-Windows

Function _openScanWindow($opt : Object)->$scan : Object
	//Reuses the existing _ga_scanInterface dialog: it already holds the keyboard-wedge
	//capture, which accepts a buffer only when it arrives faster than a human types.
	var $form : Object
	var $winRef : Time

	$scan:=New object:C1471("cancelled"; False:C215; "manualEntry"; False:C215; "barcodeData"; "")

	$winRef:=Open form window:C675("_ga_scanInterface"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)

	$form:=New object:C1471
	$form.barcodeData:=""
	$form.manualEntry:=False:C215
	$form.winRef:=$winRef
	SET WINDOW TITLE:C213($opt.title+" - scan the bar code"; $winRef)
	DIALOG:C40("_ga_scanInterface"; $form)
	CLOSE WINDOW:C154($winRef)

	If (OK=1)
		If ($form.manualEntry)
			$scan.manualEntry:=True:C214
		Else
			$scan.barcodeData:=$form.barcodeData
		End if
	Else
		$scan.cancelled:=True:C214
	End if

Function _openCredentialsWindow($mode : Text; $opt : Object; $whoName : Text)->$credentials : Object
	//$mode: "code" asks for the user code, "password" asks for the account password.
	var $form : Object
	var $winRef : Time

	$credentials:=New object:C1471("cancelled"; False:C215; "userCode"; ""; "password"; "")

	$form:=New object:C1471
	$form.mode:=$mode
	$form.title:=$opt.title
	$form.whoName:=$whoName
	$form.userCode:=""
	$form.password:=""

	If (Is Windows:C1573)
		$winRef:=Open form window:C675("_ga_approvalCredentials"; Modal form dialog box:K39:7)
	Else
		$winRef:=Open form window:C675("_ga_approvalCredentials"; Sheet form window:K39:12)
	End if
	SET WINDOW TITLE:C213($opt.title; $winRef)
	DIALOG:C40("_ga_approvalCredentials"; $form)
	CLOSE WINDOW:C154($winRef)

	If (OK=1)
		$credentials.userCode:=String:C10($form.userCode)
		$credentials.password:=String:C10($form.password)
	Else
		$credentials.cancelled:=True:C214
	End if

Function credentialsFormRefresh()
	//Called by _ga_approvalCredentials: OK stays disabled until the visible input
	//actually holds something, so an empty Enter cannot be read as a failed attempt.
	var $filled : Boolean

	If (Form:C1466.mode="password")
		$filled:=(String:C10(Form:C1466.password)#"")
	Else
		$filled:=(String:C10(Form:C1466.userCode)#"")
	End if

	OBJECT SET ENABLED:C1123(*; "bOk"; $filled)

	//Mark:-Messages

Function _alert($failureReason : Text; $opt : Object)
	cs:C1710.sfw_dialog.me.alert(This:C1470.message($failureReason; $opt.profileLabel))

Function message($failureReason : Text; $profileLabel : Text)->$message : Text
	//The single message table. Exposed so a caller can reuse the wording if it wants
	//to report a failure somewhere other than an alert.
	Case of
		: ($failureReason="codeNotFound")
			$message:="The user code entered does not correspond to any existing user."
		: ($failureReason="barcodeNotFound")
			$message:="The scanned barcode does not correspond to any existing user."
		: ($failureReason="ambiguous")
			$message:="Several employees share that code or barcode. Ask an administrator to correct it."
		: ($failureReason="noUserAccount")
			$message:="This employee does not have an application user account."
		: ($failureReason="inactiveAccount")
			$message:="This account is inactive or the employee has been terminated."
		: ($failureReason="alreadyUsed")
			$message:="This person has already signed this record."
		: ($failureReason="notInProfile")
			$message:="This user is not part of the "+(($profileLabel="") ? "required" : $profileLabel)+" profile and cannot sign."
		: ($failureReason="noPassword")
			$message:="This account has no password set and cannot be used to approve."
		: ($failureReason="temporaryPassword")
			$message:="This account is still using its temporary password. It must be changed before approving."
		: ($failureReason="wrongPassword")
			$message:="Incorrect password. The approval was not recorded."
		Else
			$message:="Unable to identify the user."
	End case

	//Mark:-Internal

Function _upperCased($values : Collection)->$upper : Collection
	var $value : Text

	$upper:=New collection:C1472
	If ($values=Null:C1517)
		return
	End if
	For each ($value; $values)
		$upper.push(Uppercase:C13(String:C10($value)))
	End for each
