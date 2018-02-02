//
//  Array+AppendElementOperator.swift
//  Gambattye
//
//  Created by Ben10do on 02/02/2018.
//  Copyright © 2018 Ben10do. Licenced under the GPL v2 (see LICENCE).
//

import Foundation

extension Array {

    static func += (array: inout [Element], element: Element) {
        array.append(element)
    }
    
}
