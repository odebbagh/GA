# sfw_string

The `sfw_string` class is a shared singleton that provides various string manipulation functions. This class ensures that all components of an application can access consistent and efficient string operations without needing to instantiate multiple instances.

### Summary

| |
| -------- |
|[.stringCapitalize(text : Text) : Text](#-stringcapitalize-) <br> Capitalizes the first letter of each word in the given text, taking into account specific particles that should remain lowercase.|
|[.stringIsAnEmptyUUID(uuid : Text) : Boolean](#-stringisanemptyuuid-) <br> Checks if the given UUID is empty or invalid. |
|[.trimSpace(stringToTrim : Text) : Text](#-trimspace-) <br> Trims extra spaces from the given text. |

<!--   stringCapitalize() *********************   -->
## .stringCapitalize()

### .stringCapitalize(text : Text) : Text

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| text  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The input text to be capitalized |
| result  | Text  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | The capitalized text |

#### Description

The `.stringCapitalize()` function capitalizes the first letter of each word in the given text, taking into account specific particles that should remain lowercase. This function is useful for formatting names and titles in a consistent manner.

#### Example
```4d
$text:="mc donald"
$result:=cs.sfw_string.me.stringCapitalize($text) // "Mc Donald"
```

<!--   stringIsAnEmptyUUID() *********************   -->
## .stringIsAnEmptyUUID()

### .stringIsAnEmptyUUID(uuid : Text) : Boolean

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| uuid  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The UUID to be checked |
| result  | Boolean  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | `True` if the UUID is empty or invalid, `False` otherwise |

#### Description

The `.stringIsAnEmptyUUID()` function checks if the given UUID is empty or invalid. This function is useful for validating UUIDs before performing operations that require a valid UUID.

#### Example
```4d
$uuid:="00000000000000000000000000000000"
$isEmpty:=cs.sfw_string.me.stringIsAnEmptyUUID($uuid) // True
```

<!--   trimSpace() *********************   -->
## .trimSpace()

### .trimSpace(stringToTrim : Text) : Text

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stringToTrim  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The input text from which spaces need to be trimmed |
| result  | Text  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | The trimmed text |

#### Description

The `.trimSpace()` function trims extra spaces from the given text. This function is useful for cleaning up user input or formatting text for display.

#### Example
```4d
$stringToTrim:="  Hello   World  "
$stringTrimmed:=cs.sfw_string.me.trimSpace($stringToTrim) // "Hello World"
```