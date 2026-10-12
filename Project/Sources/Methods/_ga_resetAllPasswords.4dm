//%attributes = {}

/*
Method Name : _ga_resetAllPasswords
Purpose     : TEST DATABASES ONLY. Gives every application account ([sfw_User]) the same
              password, typed when the method runs - nothing is stored in this code.

WHAT IT WRITES, per account
  accesses.password.hash        bcrypt hash of the new password, made with the same
                                sfw_passwordManager options the login form verifies
                                against - and Util_Authorizer checks the same hash when
                                an approver signs, so both work with the new password
  accesses.password.temporary   False: a temporary password would make the login ask for
                                a change and Util_Authorizer refuse to sign. This also
                                clears the deliberate "temporary password" refusal case
                                on boapp4 (_create_testData_boApprovers).
  accesses.approvalPassword     given the same hash, only on accounts that already have
                                one (Util_Authorizer's passwordSource "approval")
  Every other key in accesses (designer access and so on) is left as it was.
*/

var $users : cs:C1710.sfw_UserSelection
var $eUser : cs:C1710.sfw_UserEntity
var $accesses : Object
var $result : Object
var $password; $confirmation; $hash : Text
var $updated; $failed : Integer
var $failures : Collection

$users:=ds:C1482.sfw_User.all()

If (Not:C34(cs:C1710.sfw_dialog.me.confirm("This gives ALL "+String:C10($users.length)+" application accounts the same password."+Char:C90(Carriage return:K15:38)\
	+"Use it on a test database only. Continue?"; "Continue"; "CANCEL")))
	return
End if

$password:=Request:C163("New password for every account:")
If (OK=0) | ($password="")
	return
End if
$confirmation:=Request:C163("Type the same password again:")
If (OK=0)
	return
End if
If ($confirmation#$password)
	cs:C1710.sfw_dialog.me.alert("The two passwords are different. Nothing was changed.")
	return
End if

$hash:=Generate password hash:C1533($password; cs:C1710.sfw_passwordManager.me.hashOptions)

$updated:=0
$failed:=0
$failures:=New collection:C1472

For each ($eUser; $users)
	$accesses:=($eUser.accesses=Null:C1517) ? New object:C1471 : $eUser.accesses

	$accesses.password:=New object:C1471(\
		"hash"; $hash; \
		"temporary"; False:C215; \
		"lastChange"; cs:C1710.sfw_stmp.me.now())

	If ($accesses.approvalPassword#Null:C1517)
		$accesses.approvalPassword.hash:=$hash
	End if

	//---reassigned so the entity is marked as modified
	$eUser.accesses:=$accesses

	$result:=$eUser.save()
	If ($result.success)
		$updated:=$updated+1
	Else
		$failed:=$failed+1
		$failures.push(String:C10($eUser.login)+": "+String:C10($result.statusText))
	End if
End for each

cs:C1710.sfw_dialog.me.info("Passwords updated: "+String:C10($updated)+" | failed: "+String:C10($failed)\
	+(($failures.length>0) ? (Char:C90(Carriage return:K15:38)+$failures.join(Char:C90(Carriage return:K15:38))) : ""))
