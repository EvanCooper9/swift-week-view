//
//	SwiftDate, Full featured Swift date library for parsing, validating, manipulating, and formatting dates and timezones.
//	Created by:				Daniele Margutti
//	Main contributors:		Jeroen Houtzager
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

//MARK: - Date Extension

public extension Date {
	
	public func string(custom formatString: String) -> String {
		return self.string(format: .custom(formatString), in: nil)
	}
	
	/// Convert a `Date` to a string using ISO8601 format
	///
	/// - parameter opts: options to format ISO8601 output string (if nil `.withInternetDateTime` will be used instead)
	///
	/// - returns: a string representing the date in ISO8601 format according to passed options
	public func iso8601(opts: ISO8601DateTimeFormatter.Options? = nil) -> String {
		return self.string(format: .iso8601(options: opts ?? [.withInternetDateTime]))
	}
	
	/// Convert a `Date` to a string using specified format.
	/// The date itself is expressed in the context of specified `Region`.
	///
	/// - parameter format: format of the output
	/// - parameter region: region in which the date should be evaluated (if nil `defaultRegion` will be used instead)
	///
	/// - returns: the string representation of the date itself
	public func string(format: DateFormat, in region: Region? = nil) -> String {
		let srcRegion = region ?? DateDefaultRegion
		return DateInRegion(absoluteDate: self, in: srcRegion).string(format: format)
	}
	
	/// Get the representation of the absolute time interval between `self` date and a given date
	///
	/// - parameter toDate:    date to compare
	/// - parameter region:    region in which both dates will be expressed in
	/// - parameter dateStyle: style of the date (if not specified `.medium`)
	/// - parameter timeStyle: style of the time (if not specified `.medium`)
	///
	/// - returns: the interval between two dates expressed according to set parameters
	public func intervalString(toDate: Date, in region: Region? = nil, dateStyle: DateIntervalFormatter.Style = .medium, timeStyle: DateIntervalFormatter.Style = .medium) -> String {
		let srcRegion = region ?? DateDefaultRegion
		let srcDate = DateInRegion(absoluteDate: self, in: srcRegion)
		let toDateInRegion = DateInRegion(absoluteDate: toDate, in: srcRegion)
		return srcDate.intervalString(toDate: toDateInRegion, dateStyle: dateStyle, timeStyle: timeStyle)
	}
	
	/// Convert a `Date` into a string with date & time style specific format style
	///
	/// - parameter dateStyle: style of the date (if not specified `.medium`)
	/// - parameter timeStyle: style of the time (if not specified `.medium`)
	/// - parameter region:    region in which both dates will be expressed in
	///
	/// - returns: a string representing date and time in requested format
	public func string(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium, in region: Region? = nil) -> String {
		let srcRegion = region ?? DateDefaultRegion
		return DateInRegion(absoluteDate: self, in: srcRegion).string(dateStyle: dateStyle, timeStyle: timeStyle)
	}
	
	/// This method produces a colloquial representation of time elapsed between this `DateInRegion` (`self`) and
	/// the current date (`Date()`)
	///
	/// - parameter region:    region in which both dates will be expressed in
	/// - parameter max:       max number of the time components to write (nil means no limit)
	/// - parameter zero:      the behaviour to use with zero value components
	/// - parameter separator: separator string between components (default is ',')
	///
	/// - throws: throw an exception is colloquial string cannot be evaluated
	///
	/// - returns: colloquial string representation
	public func colloquialSinceNow(in region: Region? = nil, unitStyle: DateComponentsFormatter.UnitsStyle = .short, max: Int? = nil, zero: DateZeroBehaviour? = nil, separator: String? = nil) throws -> (colloquial: String, time: String?) {
		let srcRegion = region ?? DateDefaultRegion
		return try DateInRegion(absoluteDate: self, in: srcRegion).colloquialSinceNow(style: unitStyle)
	}
	
	/// This method produces a colloquial representation of time elapsed between this `DateInRegion` (`self`) and
	/// another passed date.
	///
	/// - parameter to:        date to compare
	/// - parameter region:    region in which both dates will be expressed in
	/// - parameter max:       max number of the time components to write (nil means no limit)
	/// - parameter zero:      the behaviour to use with zero value components
	/// - parameter separator: separator string between components (default is ',')
	///
	/// - throws: throw an exception is colloquial string cannot be evaluated
	///
	/// - returns: colloquial string representation of the time elapsed between two dates
	public func colloquial(to: Date, in region: Region? = nil, max: Int? = nil, zero: DateZeroBehaviour? = nil, separator: String? = nil) throws -> (colloquial: String, time: String?) {
		let srcRegion = region ?? DateDefaultRegion
		let toDateInRegion = DateInRegion(absoluteDate: to, in: srcRegion)
		return try DateInRegion(absoluteDate: self, in: srcRegion).colloquial(toDate: toDateInRegion)
	}
	
	/// This method produces a string by printing the interval between self and current Date and output a string where each
	/// calendar component is printed.
	///
	/// - parameter options: options to format the output. Keep in mind: `.locale` will be overwritten by self's `region.locale`.
	/// - parameter shared: `true` to use a shared (per thread) instance. Unless specific needs you should not instantiate
	///                     lots of Date Formatters due to the high cost. SwiftDate share a single formatter in each thread
	///                     which cover the most commom scenarios.
	///
	/// - throws: throw an exception if time components cannot be evaluated
	///
	/// - returns: string with each time component
	public func timeComponentsSinceNow(options: ComponentsFormatterOptions? = nil, shared: Bool? = true) throws -> String {
		return try self.timeComponents(to: Date(), options: options, shared: shared)
	}
	
	/// This method produces a string by printing the interval between self and another date and output a string where each
	/// calendar component is printed.
	///
	///
	/// - parameter to:	date to compare
	/// - parameter options: options to format the output. Keep in mind: `.locale` will be overwritten by self's `region.locale`.
	/// - parameter shared: `true` to use a shared (per thread) instance. Unless specific needs you should not instantiate
	///                     lots of Date Formatters due to the high cost. SwiftDate share a single formatter in each thread
	///                     which cover the most commom scenarios.
	///
	/// - throws: throw an exception if time components cannot be evaluated
	///
	/// - returns: string with each time component
	public func timeComponents(to: Date, options: ComponentsFormatterOptions? = nil, shared: Bool? = true) throws -> String {
		return try self.timeIntervalSince(to).string(options: options, shared: shared)
	}
}
