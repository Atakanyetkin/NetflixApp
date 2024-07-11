//
//  Extensions.swift
//  NetflixApp
//
//  Created by atakan yetkin on 9.07.2024.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
