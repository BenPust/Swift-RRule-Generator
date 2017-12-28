//
//  RRuleParser.swift
//  RRuleParser
//
//  Created by Benjamin Pust on 12/20/17.
//  Copyright © 2017 Benjamin Pust. All rights reserved.
//

import Foundation


internal struct ByDay {
    var day: rrDays
    var dayModifier: Int?
}

internal enum rrFrequency {
    case SECONDLY
    case MINUTELY
    case HOURLY
    case DAILY
    case WEEKLY
    case MONTHLY
    case YEARLY
    
    init?(str: String) {
        switch str {
        case "SECONDLY":
            self = .SECONDLY
        case "MINUTELY":
            self = .MINUTELY
        case "HOURLY":
            self = .HOURLY
        case "DAILY":
            self = .DAILY
        case "WEEKLY":
            self = .WEEKLY
        case "MONTHLY":
            self = .MONTHLY
        case "YEARLY":
            self = .YEARLY
        default:
            fatalError("Unrecognized frequency \(str)")
        }
    }
}

internal enum rrDays: Int {
    case SU = 1
    case MO
    case TU
    case WE
    case TH
    case FR
    case SA
    
    init?(str: String) {
        switch str {
        case "MO":
            self = .MO
        case "TU":
            self = .TU
        case "WE":
            self = .WE
        case "TH":
            self = .TH
        case "FR":
            self = .FR
        case "SA":
            self = .SA
        case "SU":
            self = .SU
        default:
            fatalError("Unrecognized weekday \(str)")
        }
    }
}

// Example String `RRULE:FREQ=WEEKLY;UNTIL=20180317T065959Z;INTERVAL=2;BYDAY=MO,TU,WE,TH,FR`
public class RRule: NSObject {
    
    // MARK: - Properties
    var freq: rrFrequency!
    
    var until: String?      // type says it's "date" // TODO: what is the type
    var count: Int?
    
    var interval: Int?
    var bySecond: [Int] = [Int]()    // 0-59
    var byMinute: [Int] = [Int]()    // 0-59
    var byHour: [Int] = [Int]()      // 0-23
    
    /**
     TODO: -
     Each BYDAY value can also be preceded by a positive (+n) or negative
     (-n) integer. If present, this indicates the nth occurrence of the
     specific day within the __MONTHLY or YEARLY RRULE___. For example, within
     a MONTHLY rule, +1MO (or simply 1MO) represents the first Monday
     within the month, whereas -1MO represents the last Monday of the
     month. If an integer modifier is not present, it means all days of
     this type within the specified frequency. For example, within a
     MONTHLY rule, MO represents all Mondays within the month.
     */
    var byDay: [ByDay] = [ByDay]()
    
    // For example, -10 represents the tenth to the last day of the month.
    var byMonthDay: [Int] = [Int]()  // 1-31 || -1-(-31)
    
    // For example, -1 represents the last day of the year (December 31st) and -306 represents the 306th to the last day of the year (March 1st).
    var byYearDay: [Int] = [Int]()   // 1-366 || -1-(-366)
    
    /// specifying weeks of the year. Valid values are 1 to 53 or -53 to -1; Week numbering as defined in [ISO 8601]
    /**
     A week is defined as a
     seven day period, starting on the day of the week defined to be the
     week start (see WKST). Week number one of the calendar year is the
     first week which contains at least four (4) days in that calendar
     year. This rule part is only valid for YEARLY rules. For example, 3
     represents the third week of the year.
     
     Note: Assuming a Monday week start, week 53 can only occur when
     Thursday is January 1 or if it is a leap year and Wednesday is
     January 1.
     */
    var byWeekNo: [Int] = [Int]()
    
    var byMonth: [Int] = [Int]()     // 1-12
    var bySetPos: [Int] = [Int]()    // 1 to 366 or -366 to -1
    
    /**
     The __WKST rule__ part specifies the day on which the workweek starts.
     Valid values are MO, TU, WE, TH, FR, SA and SU. This is significant
     when a WEEKLY RRULE has an interval greater than 1, and a BYDAY rule
     part is specified. This is also significant when in a YEARLY RRULE
     when a BYWEEKNO rule part is specified. The default value is MO.
     */
    var wkst: rrDays?
    
    var eventStartDate: Date?
    
    // MARK: - Init
    public init(rrule: String, tempStartEventDate: Date?=nil) {
        super.init()
        
        self.eventStartDate = tempStartEventDate
        splitRrString(rrule: rrule)
    }
    
    // MARK: - Parse Functions
    
    private func splitRrString(rrule: String) {
        let rulesString = rrule.split(separator: ":")
        if rulesString.count > 1 && rulesString[0] == "RRULE" {
            let rruleParameterList = rulesString[1].split(separator: ";")
            //            var dictParameters = [String: String]()
            
            for param in rruleParameterList {
                let splitKeyValue = param.split(separator: "=")
                
                //dictParameters[String.init(splitKeyValue[0])] = String.init(splitKeyValue[1])
                assignDictToProperties(rulesDict: [String.init(splitKeyValue[0]): String.init(splitKeyValue[1])])
            }
        }
    }
    
    private func assignDictToProperties(rulesDict: [String: String]) {
        for (key, value) in rulesDict {
            switch key {
            case "FREQ":
                freq = rrFrequency(str: value)
            case "UNTIL":
                until = value
            case "COUNT":
                count = Int(value)
            case "INTERVAL":
                interval = Int(value)
            case "BYSECOND":
                bySecond = splitCommaListIntoArray(strList: value)
            case "BYMINUTE":
                byMinute = splitCommaListIntoArray(strList: value)
            case "BYHOUR":
                byHour = splitCommaListIntoArray(strList: value)
            case "BYDAY":
                parseAndPopulateByDayArray(strList: value)
            case "BYMONTHDAY":
                byMonthDay = splitCommaListIntoArray(strList: value)
            case "BYYEARDAY":
                byYearDay = splitCommaListIntoArray(strList: value)
            case "BYWEEKNO":
                byWeekNo = splitCommaListIntoArray(strList: value)
            case "BYMONTH":
                byMonth = splitCommaListIntoArray(strList: value)
            case "BYSETPOS":
                bySetPos = splitCommaListIntoArray(strList: value)
            case "WKST":
                wkst = rrDays(str: value)
            default:
                fatalError("Unrecognized rrule value: \(key)")
            }
        }
    }
    
    private func splitCommaListIntoArray(strList: String) -> [Int] {
        let splitList = strList.split(separator: ",")
        var returnArray = [Int]()
        if splitList.count > 0 {
            for strNum in splitList {
                if let num = Int(strNum) {
                    returnArray.append(num)
                } else {
                    fatalError("Could not convert string to int \(strNum)")
                }
            }
        } else { // there was only one number
            if let num = Int(strList) {
                returnArray.append(num)
            } else {
                fatalError("Could not convert string to int \(strList)")
            }
        }
        
        return returnArray
    }
    
    private func parseAndPopulateByDayArray(strList: String) {
        let splitList = strList.split(separator: ",")
        if splitList.count > 0 {
            for strNum in splitList {
                let (day, number) = searchNumberAndWeekday(string: String(strNum))
                print(strNum, ":", day, number)
                byDay.append(ByDay(day: day, dayModifier: number))
            }
        } else { // there was only one number
            let (day, number) = searchNumberAndWeekday(string: String(strList))
            byDay.append(ByDay(day: day, dayModifier: number))
        }
    }
    
    private func searchNumberAndWeekday(string: String) -> (rrDays, Int?) {
        let numArr = matches(for: "[\\-]{0,1}[0-9]{1,3}", in: string)
        let weekdayArr = matches(for: "[A-z]{1,}", in: string)
        
        var weekday: rrDays!
        var number: Int?
        if weekdayArr.count > 0 {
            weekday = rrDays(str: weekdayArr.first!)
        }
        
        if numArr.count > 0 {
            number = Int(numArr.first!)
        }
        
        return (weekday, number)
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Public
    
    public func nextDate() -> Date? {
        switch freq {
        case .DAILY:
            print("")
        case .SECONDLY:
            print("")
        case .MINUTELY:
            print("")
        case .HOURLY:
            print("")
        case .DAILY:
            print("")
        case .WEEKLY:
            return nextDateWeeklyFrequency()
        case .MONTHLY:
            print("")
        case .YEARLY:
            return nextDateYearlyFrequency()
        default:
            return nil
        }
        return nil
    }
    
    // MARK: - Date Calculation
    
    // FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1;          UNTIL=20171223T080000Z
    // FREQ=YEARLY;BYMONTH=1;BYDAY=SU;BYSETPOS=2;   UNTIL=20171223T080000Z -> sencond sunday of January yearly
    private func nextDateYearlyFrequency() -> Date? {
        
        let today = Date()
        var returnDate: Date?
        
        // Make sure there are more events to come
        
        // TODO: THIS IS FOR WEEKLY CHEKCING!!
//        if let count = count {
//            if checkWeeklyCount(count, today: today) == false {
//                return nil
//            }
//        }
//        
//        if let until = until {
//            if checkWeeklyUntil(until, today: today) == false {
//                return nil
//            }
//        }
        
        let todayDateComponents = Calendar.current.dateComponents([.year,.month,.day], from: today)
        let nowMonth = todayDateComponents.month!
        let nowMonthDay = todayDateComponents.day!
        
        if byMonth.count > 0 {
            var monthDifferences = [Int]()
            var smallestMonthDifference = -1
            for compareMonth in byMonth {
                if nowMonth < compareMonth {
                    smallestMonthDifference = compareMonth - nowMonth
                    monthDifferences.append(smallestMonthDifference)
                } else if nowMonth == compareMonth {
                    smallestMonthDifference = 0
                    monthDifferences.append(smallestMonthDifference)
                } else {
                    smallestMonthDifference = (12 - nowMonth) + compareMonth
                    monthDifferences.append(smallestMonthDifference)
                }
            }
            
            // #Case 1 - day of the month specified
            if byMonthDay.count > 0 {
                var smallestDayDifference = -1
                
                var nextMonthDayEvent = -1
                if smallestMonthDifference == 0 {
                    // this month
                    for compareMonthDay in byMonthDay {
                        if nowMonthDay < compareMonthDay {
                            smallestDayDifference = compareMonthDay - nowMonthDay
                        } else if nowMonthDay == compareMonthDay {
                            smallestDayDifference = 0
                        } else {
                            fatalError("Should never get to this point")
                        }
                    }
                    var dateComp = DateComponents()
                    dateComp.day = smallestDayDifference
                    returnDate = Calendar.current.date(byAdding: dateComp, to: today)
                } else {
                    // not this month
                    nextMonthDayEvent = byMonthDay.min()!
                    var dateComp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: today)
                    
                    if (nowMonth + smallestMonthDifference) > 12 {
                        // next year
                        dateComp.year! += 1
                        dateComp.month = nowMonth + smallestMonthDifference - 12
                    }
                    dateComp.day = nextMonthDayEvent
                    returnDate = Calendar.current.date(from: dateComp)
                }
                return returnDate
            }
            
            // #Case 2 - weekday specified
            if byDay.count > 0 {
                if bySetPos.count > 0 {
                    if smallestMonthDifference == 0 {
                        //this month
                        
                        var dateComp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute, .weekOfMonth], from: today)
                        var nowWeekOfTheMonth = dateComp.weekOfMonth!
                        
                        for bySetP in bySetPos {
                            if nowWeekOfTheMonth == bySetP {
                                // this week of the month
                            } else if nowWeekOfTheMonth > bySetP {
                                // already past
                            } else {
                                // coming up
                            }
                            
                        }
                        
                    } else {
                        //not this month
                        
                    }
                }
            }
        }
        
        
        return nil
    }
    
    // TODO: This function is incomplete - does not account for anything except byday parameter excluding +/-1[weekday]
    private func nextDateWeeklyFrequency() -> Date? {
        
        let today = Date()
        
        // Make sure there are more events to come
       
        if let count = count {
            if checkWeeklyCount(count, today: today) == false {
                return nil
            }
        }
        
        if let until = until {
            if checkWeeklyUntil(until, today: today) == false {
                return nil
            }
        }
        
        // If the first event has not yet started
        var dateForNextEventComp = today
        if eventStartDate! > today {
            let dayDiff = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: today, to: eventStartDate!)
            print("DAY:",dayDiff.day)
            dateForNextEventComp = Calendar.current.date(byAdding: dayDiff, to: today)!
        }
        
        // - Beyond this point it is confirmed that there are event in the future
        // - find the next event from today
        let weekdayComponent = Calendar.current.dateComponents([.weekday], from: dateForNextEventComp)
        let todaysWeekday = weekdayComponent.weekday! // TODO: MAKE THIS SAFE
        var smallestDayDifference: Int = -1
        for eventWeekdays in byDay.sorted(by: { (a, b) -> Bool in
            return a.day.rawValue < b.day.rawValue // sort days so they go in order
        }) {
            if eventWeekdays.day.rawValue < todaysWeekday {
                let tempDiff = (7 - todaysWeekday) + eventWeekdays.day.rawValue
                if tempDiff < smallestDayDifference || smallestDayDifference == -1 {
                    smallestDayDifference = tempDiff
                }
            } else if eventWeekdays.day.rawValue == todaysWeekday {
                smallestDayDifference = 0
            } else {
                let tempDiff = eventWeekdays.day.rawValue - todaysWeekday
                if tempDiff < smallestDayDifference || smallestDayDifference == -1 {
                    smallestDayDifference = tempDiff
                }
            }
        }
        
        var dateComp = DateComponents()
        print(smallestDayDifference)
        dateComp.day = smallestDayDifference
        let nextEventDate = Calendar.current.date(byAdding: dateComp, to: dateForNextEventComp)
        
        return nextEventDate
    }
    
    // MARK: Weekly helper functions
    
    private func checkWeeklyCount(_ count: Int, today: Date) -> Bool {
        let DayWeekComponents = Calendar.current.dateComponents([.weekOfYear, .day], from: eventStartDate!, to: today)
        let extraDays = DayWeekComponents.day!
        let weeks = DayWeekComponents.weekOfYear
        let numberOfEventsPerWeek = byDay.count // assuming its not empty
        
        var eventsUpToToday = weeks!*numberOfEventsPerWeek
        
        if let interval = interval {
            eventsUpToToday /= interval
        }
        
        // check if there are any events between in the extra days
        let weekdayComponentForOriginalDate = Calendar.current.dateComponents([.weekday], from: eventStartDate!)
        var startWeekday = weekdayComponentForOriginalDate.weekday! // TODO: MAKE THIS SAFE
        
        for _ in 0..<extraDays {
            startWeekday += 1
            if startWeekday > 7 {
                startWeekday = 1
            }
            
            // check if any events occur on this byday
            if let interval = interval {
                if weeks! % interval == 0 {
                    break
                }
            }
            for byday in byDay {
                if byday.day.rawValue == startWeekday {
                    eventsUpToToday += 1 // one event occured on that day
                }
            }
        }
        
        if eventsUpToToday >= count {
            return false
        }
        
        return true
    }
    
    private func checkWeeklyUntil(_ until: String, today: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        if let untilDate = formatter.date(from: until) {
            if untilDate < today {
                return false
            }
        } else {
            fatalError("Could not parse until date")
        }
        
        return true
    }
    
    // MARK: - Debug Functions
    
    public func printProperties() {
        print("--DEBUG--")
        print("freq",freq)
        print("until",until)
        print("count",count)
        print("interval",interval)
        print("bySecond",bySecond)
        print("byMinute",byMinute)
        print("byHour",byHour)
        print("byDay",byDay.description)
        print("byMonthDay",byMonthDay)
        print("byYearDay",byYearDay)
        print("byWeekNo",byWeekNo)
        print("byMonth",byMonth)
        print("bySetPos",bySetPos)
        print("wkst",wkst)
    }
}
