# sfw_definitionScheduler

The `sfw_definitionScheduler` class is designed to manage the configuration and scheduling of periodic tasks within an application. This class allows for the dynamic setup of schedules based on different periodicities such as hourly, daily, weekly, monthly, and yearly.

### Usage Example

This class allows you to describe a scheduler with various periodicities such as hourly, daily, weekly, monthly, and yearly. Here is an example of how to use this class:

```4d
$scheduler:=cs.sfw_definitionScheduler.new("daily")
$scheduler.setHourToStart(8)
$scheduler.setMinuteToStart(30)
$scheduler.setDayNumbers(1; 3; 5) // Monday, Wednesday, Friday
$scheduler.setHourMinMax(9; 17) // Between 9 AM and 5 PM
```

### Summary

| |
| -------- |
|[.new(typePeriodicity : Text)](#-new-) <br> Creates a new scheduler with the specified periodicity. |
|[.setDayNumber(dayNumber : Integer)](#-setdaynumber-) <br> Sets the specific day number for the schedule. |
|[.setDayNumbers(... : Integer)](#-setdaynumbers-) <br> Sets multiple day numbers for the schedule. |
|[.setHourMinMax(hourMini : Integer; hourMaxi : Integer)](#-sethourminmax-) <br> Sets the minimum and maximum hours for the schedule. |
|[.setHourToStart(hour : Integer)](#-sethourtostart-) <br> Sets the hour to start the schedule. |
|[.setMinuteToStart(minute : Integer)](#-setminutetostart-) <br> Sets the minute to start the schedule. |
|[.setMinutesToStart(minutes : Collection)](#-setminutestostart-) <br> Sets multiple minutes to start the schedule. |

<!--   new() *********************   -->
## .new()

### .new(typePeriodicity : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| typePeriodicity  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The periodicity type for the scheduler |
| result  | Object  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Creates a new scheduler with the specified periodicity |

#### Description

The `.new()` function creates a new scheduler with the specified periodicity. This function initializes the scheduler with default values based on the periodicity type.

#### Possible Values for `typePeriodicity`
- `hourly`: The scheduler will run on an hourly basis.
- `daily`: The scheduler will run on a daily basis.
- `weekly`: The scheduler will run on a weekly basis.
- `monthly`: The scheduler will run on a monthly basis.
- `yearly`: The scheduler will run on a yearly basis.

#### Example
```4d
$scheduler:=cs.sfw_definitionScheduler.new("daily")
```

<!--   setDayNumber() *********************   -->
## .setDayNumber()

### .setDayNumber(dayNumber : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| dayNumber  | Integer  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The specific day number for the schedule |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the specific day number for the schedule |

#### Description

The `.setDayNumber()` function sets the specific day number for the schedule. This function allows for the configuration of a single day number on which the schedule will be executed.

#### Example
```4d
cs.sfw_definitionScheduler.me.setDayNumber(1) // Sets the schedule to run on Monday
```

<!--   setDayNumbers() *********************   -->
## .setDayNumbers()

### .setDayNumbers(... : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| ...  | Integer  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Multiple day numbers for the schedule |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets multiple day numbers for the schedule |

#### Description

The `.setDayNumbers()` function sets multiple day numbers for the schedule. This function allows for the configuration of multiple days on which the schedule will be executed.

#### Example
```4d
cs.sfw_definitionScheduler.me.setDayNumbers(1; 3; 5) // Sets the schedule to run on Monday, Wednesday, and Friday
```

<!--   setHourMinMax() *********************   -->
## .setHourMinMax()

### .setHourMinMax(hourMini : Integer; hourMaxi : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| hourMini  | Integer  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The minimum hour for the schedule |
| hourMaxi  | Integer  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The maximum hour for the schedule |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the minimum and maximum hours for the schedule |

#### Description

The `.setHourMinMax()` function sets the minimum and maximum hours for the schedule. This function allows for the configuration of the time range within which the schedule will be executed.

#### Example
```4d
cs.sfw_definitionScheduler.me.setHourMinMax(9; 17) // Sets the schedule to run between 9 AM and 5 PM
```

<!--   setHourToStart() *********************   -->
## .setHourToStart()

### .setHourToStart(hour : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| hour  | Integer  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The hour to start the schedule |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the hour to start the schedule |

#### Description

The `.setHourToStart()` function sets the hour to start the schedule. This function allows for the configuration of the specific hour at which the schedule will begin.

#### Example
```4d
cs.sfw_definitionScheduler.me.setHourToStart(8) // Sets the schedule to start at 8 AM
```

<!--   setMinuteToStart() *********************   -->
## .setMinuteToStart()

### .setMinuteToStart(minute : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| minute  | Integer  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The minute to start the schedule |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the minute to start the schedule |

#### Description

The `.setMinuteToStart()` function sets the minute to start the schedule. This function allows for the configuration of the specific minute at which the schedule will begin.

#### Example
```4d
cs.sfw_definitionScheduler.me.setMinuteToStart(30) // Sets the schedule to start at the 30th minute of the hour
```

<!--   setMinutesToStart() *********************   -->
## .setMinutesToStart()

### .setMinutesToStart(minutes : Collection)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| minutes  | Collection  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The collection of minutes to start the schedule |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets multiple minutes to start the schedule |

#### Description

The `.setMinutesToStart()` function sets multiple minutes to start the schedule. This function allows for the configuration of specific minutes at which the schedule will begin.

#### Example
```4d
$minutes:=New collection(0; 15; 30; 45)
cs.sfw_definitionScheduler.me.setMinutesToStart($minutes) // Sets the schedule to start at 0, 15, 30, and 45 minutes of the hour
```