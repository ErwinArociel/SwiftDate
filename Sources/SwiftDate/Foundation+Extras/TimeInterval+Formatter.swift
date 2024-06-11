import Foundation

public extension TimeInterval {
    struct ComponentsFormatterOptions {
        public var allowsFractionalUnits: Bool?
        public var allowedUnits: NSCalendar.Unit?
        public var collapsesLargestUnit: Bool?
        public var maximumUnitCount: Int?
        public var zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior?
        public var unitsStyle: DateComponentsFormatter.UnitsStyle?
        public var locale: Locale = Locale(identifier: "en_US")
        public var calendar: Calendar = .current
    }

    private static let sharedFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        return formatter
    }()

    func toIntervalString(options callback: ((inout ComponentsFormatterOptions) -> Void)? = nil) -> String {
        let formatter = TimeInterval.sharedFormatter
        var options = ComponentsFormatterOptions()
        callback?(&options)
        configureFormatter(formatter, with: options)

        let formattedValue = (formatter.string(from: self) ?? "")
        if options.zeroFormattingBehavior?.contains(.pad) ?? false {
            if let index = formattedValue.firstIndex(of: ":"), index.utf16Offset(in: formattedValue) < 2 {
                return "0\(formattedValue)"
            }
        }
        return formattedValue
    }

    func toString(options: ComponentsFormatterOptions) -> String {
        let formatter = TimeInterval.sharedFormatter
        configureFormatter(formatter, with: options)
        return (formatter.string(from: self) ?? "")
    }

    func toClock(zero: DateComponentsFormatter.ZeroFormattingBehavior = [.pad, .dropLeading]) -> String {
        return toIntervalString {
            $0.collapsesLargestUnit = true
            $0.maximumUnitCount = 0
            $0.unitsStyle = .positional
            $0.zeroFormattingBehavior = zero
        }
    }

    func toUnits(_ units: Set<Calendar.Component>, to refDate: Date? = nil) -> [Calendar.Component: Int] {
        let dateTo = (refDate ?? Date())
        let dateFrom = dateTo.addingTimeInterval(-self)
        var calendarComponents: Set<Calendar.Component> = []
        units.forEach { calendarComponents.insert($0) }
        let components = Calendar.current.dateComponents(calendarComponents, from: dateFrom, to: dateTo)

        // Create a dictionary from the DateComponents object
        var result: [Calendar.Component: Int] = [:]
        for component in calendarComponents {
            if let value = components.value(for: component) {
                result[component] = value
            }
        }
        return result
    }

    func toUnit(_ component: Calendar.Component, to refDate: Date? = nil) -> Int? {
        toUnits([component], to: refDate)[component]
    }

    private func configureFormatter(_ formatter: DateComponentsFormatter, with options: ComponentsFormatterOptions) {
        formatter.calendar = options.calendar
        formatter.allowedUnits = options.allowedUnits ?? []
        formatter.unitsStyle = options.unitsStyle ?? .abbreviated
        formatter.zeroFormattingBehavior = options.zeroFormattingBehavior ?? .default
        formatter.maximumUnitCount = options.maximumUnitCount ?? 0
        formatter.collapsesLargestUnit = options.collapsesLargestUnit ?? false
        formatter.allowsFractionalUnits = options.allowsFractionalUnits ?? false
    }
}
