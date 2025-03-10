extension Array {
    func appending(_ element: Element) -> Self {
        var array = self
        array.append(element)
        return array
    }

    func filterNot(_ keyPath: KeyPath<Element, Bool>) -> Self {
        filter { element in
            !element[keyPath: keyPath]
        }
    }
}
