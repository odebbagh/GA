# sfw_dialog

The `sfw_dialog` class is designed to manage various dialog boxes within an application. This class provides functionalities for displaying different types of dialogs such as save/cancel/continue, create/renounce/continue, info, alert, confirm, and request dialogs.

### Summary

| |
| -------- |
|[.alert(message : Text; buttonOkLabel : Text)](#-alert-) <br> Displays an alert dialog with the specified message and OK button label. |
|[.confirm(message : Text; buttonOkLabel : Text; buttonCancelLabel : Text)](#-confirm-) <br> Displays a confirm dialog with the specified message, OK button label, and Cancel button label, and returns a boolean indicating the user's choice. |
|[.createRenounceContinue(formData : Object)](#-createrenouncecontinue-) <br> Displays a create/renounce/continue dialog with the specified form data. |
|[.info(message : Text; buttonOkLabel : Text)](#-info-) <br> Displays an info dialog with the specified message and OK button label. |
|[.request(message : Text; default : Text; buttonOkLabel : Text; buttonCancelLabel : Text; ... : Text)](#-request-) <br> Displays a request dialog with the specified message, default value, OK button label, and Cancel button label, and returns the user's input. |
|[.saveCancelContinue(formData : Object)](#-savecancelcontinue-) <br> Displays a save/cancel/continue dialog with the specified form data. |

<!--   alert() *********************   -->
## .alert()

### .alert(message : Text; buttonOkLabel : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The message to be displayed in the alert dialog |
| buttonOkLabel  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the OK button |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Displays an alert dialog with the specified message and OK button label |

#### Description

The `.alert()` function displays an alert dialog with the specified message and OK button label.

#### Example
```4d
cs.sfw_dialog.alert("This is an alert message"; "OK")
```

<!--   confirm() *********************   -->
## .confirm()

### .confirm(message : Text; buttonOkLabel : Text; buttonCancelLabel : Text) -> ok : Boolean

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The message to be displayed in the confirm dialog |
| buttonOkLabel  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the OK button |
| buttonCancelLabel  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the Cancel button |
| ok  | Boolean  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Returns a boolean indicating the user's choice |

#### Description

The `.confirm()` function displays a confirm dialog with the specified message, OK button label, and Cancel button label, and returns a boolean indicating the user's choice.

#### Example
```4d
$ok:=cs.sfw_dialog.confirm("Are you sure you want to proceed?"; "Yes"; "No")
If ($ok)
    // User clicked OK
Else 
    // User clicked Cancel
End if
```

<!--   createRenounceContinue() *********************   -->
## .createRenounceContinue()

### .createRenounceContinue(formData : Object)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| formData  | Object  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The form data to be passed to the dialog |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Displays a create/renounce/continue dialog with the specified form data |

#### Description

The `.createRenounceContinue()` function displays a create/renounce/continue dialog with the specified form data.

#### Example
```4d
$formData:=New object("message"; "Do you want to create, renounce, or continue?")
cs.sfw_dialog.createRenounceContinue($formData)
```

<!--   info() *********************   -->
## .info()

### .info(message : Text; buttonOkLabel : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The message to be displayed in the info dialog |
| buttonOkLabel  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the OK button |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Displays an info dialog with the specified message and OK button label |

#### Description

The `.info()` function displays an info dialog with the specified message and OK button label.

#### Example
```4d
cs.sfw_dialog.info("This is an informational message"; "OK")
```

<!--   request() *********************   -->
## .request()

### .request(message : Text; default : Text; buttonOkLabel : Text; buttonCancelLabel : Text; ... : Text) -> answer : Object

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The message to be displayed in the request dialog |
| default  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The default value for the input field |
| buttonOkLabel  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the OK button |
| buttonCancelLabel  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the Cancel button |
| ...  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Optional parameters for the request dialog |
| answer  | Object  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Returns the user's input as an object with properties `answer` and `ok` |

#### Description

The `.request()` function displays a request dialog with the specified message, default value, OK button label, and Cancel button label, and returns the user's input.

#### Example
```4d
$answer:=cs.sfw_dialog.request("Please enter your name"; ""; "OK"; "Cancel")
If ($answer.ok)
    ALERT("You entered: "+$answer.answer)
Else 
    ALERT("No input provided")
End if
```

<!--   saveCancelContinue() *********************   -->
## .saveCancelContinue()

### .saveCancelContinue(formData : Object)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| formData  | Object  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The form data to be passed to the dialog |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Displays a save/cancel/continue dialog with the specified form data |

#### Description

The `.saveCancelContinue()` function displays a save/cancel/continue dialog with the specified form data.

#### Example
```4d
$formData:=New object("message"; "Do you want to save, cancel, or continue?")
cs.sfw_dialog.saveCancelContinue($formData)
```

### Usage Example

This class allows you to manage various dialog boxes with different functionalities. Here is an example of how to use this class:

```4d
// Display an alert dialog
cs.sfw_dialog.alert("This is an alert message"; "OK")

// Display a confirm dialog
$ok:=cs.sfw_dialog.confirm("Are you sure you want to proceed?"; "Yes"; "No")
If ($ok)
    // User clicked OK
Else 
    // User clicked Cancel
End if

// Display an info dialog
cs.sfw_dialog.info("This is an informational message"; "OK")

// Display a request dialog
$answer:=cs.sfw_dialog.request("Please enter your name"; ""; "OK"; "Cancel")
If ($answer.ok)
    ALERT("You entered: "+$answer.answer)
Else 
    ALERT("No input provided")
End if
```