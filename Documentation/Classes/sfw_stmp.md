<!-- Type your summary here -->
# stmp

The ``stmp`` class is a shared singleton that provides functionality for obtaining the current timestamp, date, and time. 
This class ensures that all components of an application can access a consistent and accurate representation of time without needing to instantiate multiple instances.

### Summary

| |
| -------- |
|[.build(date : Date; time : Time) : Integer](#-build-) <br> generates a timestamp based on the specified date and time.|
|[.getDate(stmp : Integer) : Date](#-getdate-) <br> retrieves the date corresponding to the providedtimestamp. |
|[.getFullRelative(stmp : Integer) : Text](#-getfullrelative-) <br> returns a text string that represents the timestamp in a human-readable format, making it easier for users to interpret. |
|[.getNbMinutes(stmp : Integer) : Integer](#-getnbminutes-) <br> converts a timestamp to the equivalent number of whole minutes. |
|[.getRelativeDate(stmp : Integer) : Text](#-getrelativedate-) <br> convert a given timestamp into a human-readable text representation of its relative date. |
|[.getRelativeDay(date : Date) : Text](#-getrelativeday-) <br> returns a string that describes the date in relation to the current date. |
|[.getRelativeDuration(duration : Integer; nbSegments : Integer) : Text](#-getrelativeduration-) <br> returns a textual representation of the duration, formatted in a human-readable form . |
|[.getTime(stmp : Integer) : Time](#-gettime-) <br>  retrieves the time corresponding to the provided timestamp.|
|[.getTimeInSec(stmp : Integer) : Integer](#-gettimeinsec-) <br> converts a given timestamp in seconds into the total equivalent seconds. |
|[.getStmpTruncMin(stmp : Integer) : Integer](#-getstmptruncmin-) <br> represents the truncated timestamp in seconds, rounded down to the nearest minute . |
|[.now() : Integer](#-now-) <br> creates a timestamp from the current date and time. |



<!--   build() *********************   -->
## .build()

### .build(date : Date; time : Time) : Integer

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| date  | Date  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Date value |
| time  | Time  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Time value |
| result  | Integer  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Integer timestamp value |


#### Description

The ``.build()`` function generates a timestamp as an ``integer`` based on the specified **date** and **time**. This function allows you to create a specific timestamp rather than relying solely on the current date and time. The resulting timestamp represents the number of seconds since a defined origin date, facilitating easy calculations and comparisons with other timestamp.


#### Exemple
```4d
$date:=Date("28/10/2024")
$time:=?17:02:00?
$stmp:=cs.stmp.me.build($date; $time) // 688755720
```

```4d
$stmp:=cs.stmp.me.build(Date("28/10/2024"); ?17:02:00?)    //  688755720
$newStmp:=$stmp-100000000                                    //  588755720

$date:=cs.stmp.me.getDate($newStmp)                           // 28/08/21
$time:=cs.stmp.me.getTime($newStmp)                           // 07:15:20
```
##### See also

[getDate()](#-getdate-)<br>
[getTime()](#-gettime-)<br>

<!--   getDate() *********************   -->
## .getDate()

### .getDate(stmp : Integer) : Date

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Date  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Date specified by timestamp |

#### Description


The `.getDate()` function takes an integer (`stmp`) as input and returns the corresponding date. 
This method is useful for converting a stmp into a human-readable date format. 
It returns the date represented by the given timestamp as a `Date`, making it easier to manipulate or display dates within the application.

#### Exemple
```4d
$stmp:=688755720
$date:=cs.stmp.me.getDate($stmp)   // 28/10/24
```
<!--   .getFullRelative($stmp : Integer)->$answer : Text *********************   -->

## .getFullRelative()

### .getFullRelative(stmp : Integer) : Text

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Text  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> |  text string that represents the timestamp in a human-readable format |

#### Description

The `getFullRelative` function is designed to generate a user-friendly, relative description of a given timestamp, `$stmp`, in relation to the current time.
It determines whether the timestamp represents a recent time within the last 24 hours or an earlier date and returns an appropriate description accordingly.

This function is especially useful for applications where timestamps need to be displayed in a manner that is meaningful to users.
 #### Exemple
```4d
$stmp:=688755720
$fullRelative:=cs.sfw_stmp.me.getFullRelative($stmp)         // "lun. 28 oct. 2024"

$stmp:=cs.sfw_stmp.me.now()                                //   690290614
$time:=cs.sfw_stmp.me.getFullRelative($stmp)              //    "0 sec"
```
##### See also
[.getRelativeDuration()](#-getrelativeduration-)<br>
[.getRelativeDate()](#-getrelativedate-)

<!--   .getNbMinutes($stmp : Integer)->$nbMinutes : Integer *********************   -->

## .getNbMinutes()

### .getNbMinutes(stmp : Integer) : Integer

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Time  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Time specified by timestamp |

#### Description

The `getNbMinutes` function takes an integer input, `$stmp`, which represents a timestamp in seconds, and converts it to the equivalent number of whole minutes.
This is done by performing an integer division of the timestamp by 60. 

This function is useful for scenarios where timestamps need to be expressed in minutes for time calculations, scheduling, or reporting purposes.

 #### Exemple
```4d
$stmp:=3678
$minutes:=cs.sfw_stmp.me.getNbMinutes($stmp)    // 61 minutes
```

<!--   .getRelativeDate($stmp : Integer)->$result : Text *********************   -->

## .getRelativeDate()

### .getRelativeDate(stmp : Integer) : Text

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Text  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | returns date format |

#### Description

The **`getRelativeDate`** function is designed to convert a given timestamp, `stmp`, 
into a human-readable text representation of its relative date. 
This function works by translating the timestamp into a date and then calling `getRelativeDay()` function to determine the appropriate relative description.

This function is useful for converting timestamps into human-readable, relative date descriptions, 
enhancing user experience by providing familiar date references in user interfaces or reports.


 #### Exemple
```4d
$stmp:=3678
$relativeDate:=cs.sfw_stmp.me.getRelativeDate($stmp)  mer. 1 janv. 2003
```
##### See also

[getRelativeDay()](#-getrelativeday-) <br>
[getDate()](#-getdate-)

<!--   .getRelativeDay($date : Date)->$result : Text *********************   -->

## .getRelativeDay()

### .getRelativeDay(date : Date) : Text

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| date  | Date  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Integer that sets time duration in seconds |
| result  | Text  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Text that returns a textual representation of the duration |

#### Description
The `getRelativeDay()` function is designed to take a date input, `date`, and return a string that describes 
the date in relation to the current date, such as "today," "yesterday," or a specific day of the week. 

This function helps improve date readability and user experience in applications that display relative date information.
#### Exemple
```4d
$currentDate:=Current date()  //  15/11/24
$date1:=Date("11/11/2024")    //  11/11/24
$date2:=Date("19/11/2024")    //  19/11/24

$relativeDay:=cs.sfw_stmp.me.getRelativeDay($currentDate) //    aujourd'hui
$relativeDay1:=cs.sfw_stmp.me.getRelativeDay($date1)       //   Lundi
$relativeDay2:=cs.sfw_stmp.me.getRelativeDay($date2)       //   Mardi prochain
```

<!--   .getRelativeDuration($duration : Integer; $nbSegments : Integer)->$answer : Text *********************   -->

## .getRelativeDuration()

### .getRelativeDuration(duration : Integer; nbSegments : Integer) : Text

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| duration  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Integer that sets time duration in seconds |
| nbSegments  | Time  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Integer that sets the maximum number of time segments |
| result  | Text  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Text that returns a textual representation of the duration |

#### Description

The **`getRelativeDuration()`** function takes an integer input, `duration`, which represents a time duration in seconds, 
and an optional integer input, `nbSegments`, which specifies the maximum number of time segments (days, hours, minutes, or seconds) to be displayed in the result. 
The function returns a textual representation of the duration, formatted in a human-readable form.

Overall, `getRelativeDuration()` is particularly useful for converting a duration in seconds into a readable format like "45 min 20 sec", 
making it suitable for applications that require time representation in a clear and concise manner.

#### Exemple
```4d
$stmp:=3678
$ralativeDuration:=cs.sfw_stmp.me.getRelativeDuration($stmp; 3)  // 1 h 1 min 18 sec 
```

<!--   getTime() *********************  -->
## .getTime()

### .getTime(stmp : Integer) : Time

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Time  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Time specified by timestamp |

#### Description

The `.getTime()` function takes an integer timestamp (`stmp`) as input and returns the time portion corresponding to that timestamp. 
This method is useful for extracting just the time (hours, minutes, and seconds) from a timestamp. 
It returns the time represented by the provided timestamp as a `Time`, allowing for easy formatting, manipulation, or display of time values within the application.

#### Exemple
```4d
$stmp:=688755720
$time:=cs.stmp.me.getTime($stmp)    // 17:02:00
```

<!--   .getTimeInSec($stmp : Integer)->$nbSecondes : Integer *********************   -->

## .getTimeInSec()

### .getTimeInSec(stmp : Integer) : Integer

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Integer  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Integer representing the initial timestamp in seconds |

#### Description

The ``getTimeInSec`` function takes an integer representing a timestamp and converts it to the equivalent total number of seconds by breaking down the timestamp into hours, minutes, and seconds, and then reassembling it to return the total seconds.

This function helps in handling time conversion tasks where normalized time needs to be expressed entirely in seconds.

#### Exemple
```4d
$stmp:=688755720                             
$time:=cs.sfw_stmp.me.getTimeInSec($stmp)    // 61200
```
<!--   .getStmpTruncMin($stmp : Integer)->$stmpMin : Integer *********************   -->

## .getStmpTruncMin()

### .getStmpTruncMin(stmp : Integer) : Integer

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| stmp  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Timestamp value |
| result  | Integer  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Integer representing the truncated timestamp in seconds, rounded down to the nearest minute |

#### Description

The **`getStmpTruncMin()`** function is designed to take an integer input, `stmp`, 
representing a timestamp in seconds and truncate it to the nearest lower minute by removing any extra seconds. 

This function is particularly useful for applications where timestamps need to be adjusted to whole-minute boundaries, 


#### Exemple

For example, if the input `stmp` is 3678 seconds (equivalent to 1 hour, 1 minute, and 18 seconds):
```4d
$stmp:=3678
$time:=cs.sfw_stmp.me.getStmpTruncMin($stmp) // 3660
```



<!--   now() *********************   -->

## .now()

### .now() : Integer


| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| result  | Integer  | <img src="DocImages\arrowLeft.png"  height="25" align="center" /> | Integer timestamp value |

#### Description

The `.now()` function returns the current timestamp as an integer. 
This method is useful for capturing the exact moment at which it’s called, enabling time-based calculations, event logging, or timestamp generation in the application. 
The returned value can be used with other date and time methods to convert it into readable formats or perform further date manipulations.

#### Exemple
```4d
$stmp:=cs.stmp.me.now()                //  688905959
$date:=cs.stmp.me.getDate($stmp)      //   30/10/24
$time:=cs.stmp.me.getTime($stmp)     //    10:45:59
```

##### See also

[build()](#-build-)<br>
[getDate()](#-getdate-)<br>
[getTime()](#-gettime-)<br>



