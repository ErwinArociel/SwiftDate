import Foundation

public extension TimeInterval {
    struct ComponentsFormatterOptions {
        public var locale: Locale = Locale(identifier: "en_US")
        public var calendar: Calendar = .current
    }

    func toUnits(_ units: Set<Calendar.Component>, options: ComponentsFormatterOptions) -> [Calendar.Component: Int] {
        let referenceDate = Date()
        let endDate = referenceDate.addingTimeInterval(self)
        let components = options.calendar.dateComponents(units, from: referenceDate, to: endDate)

        var result: [Calendar.Component: Int] = [:]
        for component in units {
            if let value = components.value(for: component) {
                result[component] = value
            } else {
                result[component] = 0
            }
        }
        return result
    }

    func toUnit(_ component: Calendar.Component, options: ComponentsFormatterOptions) -> Int {
        return toUnits([component], options: options)[component] ?? 0
    }
}
