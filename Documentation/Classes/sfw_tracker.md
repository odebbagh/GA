# sfw_tracker

The `sfw_tracker` class is a shared singleton that provides functionality for tracking and displaying events within an application. This class ensures that all components of an application can log and view events in a consistent and organized manner.

### Summary

| |
| -------- |
|[.internal(message : Text)](#-internal-) <br> Adds an internal action to the tracker list with the specified message. |
|[.internalColor(obj : Object) : Object](#-internalcolor-) <br> Determines the color for internal and mark calls in the tracker list. |
|[.launch()](#-launch-) <br> Launches the tracker window if it is not already open. |
|[.mark(message : Text)](#-mark-) <br> Adds an action to the tracker list with the specified message. |
|[.open()](#-open-) <br> Opens the tracker interface.|
|[._update(message : Text; form : Object)](#-update-) <br> Updates the tracker list with a new event. |

<!--   internal() *********************   -->
## .internal()

### .internal(message : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The internal message to be added to the tracker list |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Adds an internal action to the tracker list with the specified message |

#### Description

The `.internal()` function adds an internal action to the tracker list with the specified message. It retrieves the call chain and updates the tracker list if the tracker window is open.

#### Example
```4d
cs.sfw_tracker.me.internal("Internal action performed")
```

<!--   internalColor() *********************   -->
## .internalColor()

### .internalColor(obj : Object) : Object

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| obj  | Object  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The object containing event details |
| result  | Object  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Determines the color for internal and mark calls in the tracker list |

#### Description

The `.internalColor()` function determines the color for internal and mark calls in the tracker list. It sets different colors for internal calls and mark calls, and alternates the colors for even and odd lines.

#### Example
```4d
$obj:=New object
$obj.from:=New object
$obj.from.internal:=True
$result:=cs.sfw_tracker.me.internalColor($obj) // Returns the color object for internal calls
```

<!--   launch() *********************   -->
## .launch()

### .launch()

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Launches the tracker window if it is not already open |

#### Description

The `.launch()` function launches the tracker window if it is not already open. It sets the window title and displays the tracker list dialog.

#### Example
```4d
cs.sfw_tracker.me.launch()
```

<!--   mark() *********************   -->
## .mark()

### .mark(message : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The message to be added to the tracker list |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Adds an action to the tracker list with the specified message |

#### Description

The `.mark()` function adds an action to the tracker list with the specified message. It retrieves the call chain and updates the tracker list if the tracker window is open.

#### Example
```4d
cs.sfw_tracker.me.mark("Action performed")
```

<!--   open() *********************   -->
## .open()

### .open()

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Opens the tracker interface |

#### Description

The `.open()` function opens the tracker interface by calling a worker that launches the tracker window.

#### Example
```4d
cs.sfw_tracker.me.open()
```

<!--   _update() *********************   -->
## ._update()

### ._update(message : Text; form : Object)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| message  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The message to be added to the tracker list |
| form  | Object  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The form object containing event details |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Updates the tracker list with a new event |

#### Description

The `._update()` function updates the tracker list with a new event. It creates a new event object with the current time, message, and form details, and pushes it to the tracker list.

#### Example
```4d
$form:=New object
$form.code:="Example code"
$form.line:=123
cs.sfw_tracker.me._update("Event message", $form)
```