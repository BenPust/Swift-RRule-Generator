//
//  RRuleParserTests.swift
//  RRuleParserTests
//
//  Created by Benjamin Pust on 12/19/17.
//  Copyright © 2017 Benjamin Pust. All rights reserved.
//

import XCTest
@testable import RRuleParser

class RRuleParserTests: XCTestCase {
    
    var rruleParser: RRule!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        rruleParser = nil
    }
    
    func testMatchingDate1() {
        // TODO: ONLY TEMPORARY
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 12
        dateComponents.day = 20
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let tempStartEventDate = Calendar.current.date(from: dateComponents)!
        
        rruleParser =  RRule(rrule: "RRULE:FREQ=WEEKLY;BYDAY=WE,TH,FR;INTERVAL=1;UNTIL=20221223T000000Z", tempStartEventDate: tempStartEventDate)
        rruleParser.printProperties()
        let nextDate = rruleParser.nextDate()!
        
        
        var compareDateComponent = DateComponents()
        compareDateComponent.year = 2017
        compareDateComponent.month = 12
        compareDateComponent.day = 22
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let compareDate = Calendar.current.date(from: compareDateComponent)!
        let compareComponents = Calendar.Component.day
        
        print("Next Date \(nextDate); Compare Date \(compareDate)")
        
        XCTAssert(Calendar.current.compare(nextDate, to: compareDate, toGranularity: compareComponents) == .orderedSame)
    }
    
    func testMatchingDate2() {
        // TODO: ONLY TEMPORARY
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 12
        dateComponents.day = 24
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let tempStartEventDate = Calendar.current.date(from: dateComponents)!
        
        rruleParser =  RRule(rrule: "RRULE:FREQ=WEEKLY;BYDAY=WE,TH,FR;INTERVAL=1;UNTIL=20221223T000000Z", tempStartEventDate: tempStartEventDate)
        rruleParser.printProperties()
        let nextDate = rruleParser.nextDate()!
        
        
        var compareDateComponent = DateComponents()
        compareDateComponent.year = 2017
        compareDateComponent.month = 12
        compareDateComponent.day = 27
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let compareDate = Calendar.current.date(from: compareDateComponent)!
        let compareComponents = Calendar.Component.day
        
        print("Next Date \(nextDate); Compare Date \(compareDate)")
        
        XCTAssert(Calendar.current.compare(nextDate, to: compareDate, toGranularity: compareComponents) == .orderedSame)
    }
    
    func testUntilGivesNil() {
        // TODO: ONLY TEMPORARY
        var dateComponents = DateComponents()
        dateComponents.year = 2011
        dateComponents.month = 9
        dateComponents.day = 3
        dateComponents.timeZone = TimeZone(abbreviation: "PST")
        dateComponents.hour = 8
        dateComponents.minute = 34
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let tempStartEventDate = Calendar.current.date(from: dateComponents)!
        
        rruleParser =  RRule(rrule: "RRULE:FREQ=WEEKLY;BYDAY=SU,MO,TH;INTERVAL=1;UNTIL=20171222T000000Z", tempStartEventDate: tempStartEventDate)
        rruleParser.printProperties()
        let nextDate = rruleParser.nextDate()
        
        XCTAssert(nextDate == nil)
    }
    
    func testUntilGivesAValidDate() {
        // TODO: ONLY TEMPORARY
        var dateComponents = DateComponents()
        dateComponents.year = 2011
        dateComponents.month = 9
        dateComponents.day = 3
        dateComponents.timeZone = TimeZone(abbreviation: "PST")
        dateComponents.hour = 8
        dateComponents.minute = 34
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let tempStartEventDate = Calendar.current.date(from: dateComponents)!
        
        // TODO: fix so that the until date is not hard coded
        rruleParser =  RRule(rrule: "RRULE:FREQ=WEEKLY;BYDAY=SU,MO,TH;INTERVAL=1;UNTIL=20221222T000000Z", tempStartEventDate: tempStartEventDate)
        rruleParser.printProperties()
        let nextDate = rruleParser.nextDate()
        
        XCTAssert(nextDate != nil)
    }
    
    func testCountGivesNil() {
        
        // TODO: ONLY TEMPORARY
        var dateComponents = DateComponents()
        dateComponents.day = -29
        
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let tempStartEventDate = Calendar.current.date(byAdding: dateComponents, to: Date())
        
        
        rruleParser =  RRule(rrule: "RRULE:FREQ=WEEKLY;COUNT=2;INTERVAL=2;BYDAY=MO", tempStartEventDate: tempStartEventDate)
        rruleParser.printProperties()
        let nextDate = rruleParser.nextDate()
        
        XCTAssert(nextDate == nil)
    }

    func testYearlyEvent() {
        
        // TODO: ONLY TEMPORARY
        var dateComponents = DateComponents()
        dateComponents.day = -10
        
        // MARK: THIS WILL HAVE TO BE A PARAMETER
        let tempStartEventDate = Calendar.current.date(byAdding: dateComponents, to: Date())
        
        
        rruleParser =  RRule(rrule: "RRULE:FREQ=YEARLY;BYMONTH=11;BYMONTHDAY=5;UNTIL=20181223T080000Z", tempStartEventDate: tempStartEventDate)
        rruleParser.printProperties()
        let nextDate = rruleParser.nextDate()
        print("Date:", nextDate)
        XCTAssert(nextDate != nil)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            rruleParser =  RRule(rrule: "RRULE:FREQ=WEEKLY;UNTIL=20180317T065959Z;INTERVAL=2;BYDAY=MO", tempStartEventDate: Date())
//            rruleParser.printProperties()
//            rruleParser.nextDate()
//        }
//    }
    
}
