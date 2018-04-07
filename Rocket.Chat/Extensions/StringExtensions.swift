//
//  StringExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }

    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }

        return ""
    }

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }

        return hexString
    }

    func ranges(of string: String) -> [Range<Index>] {
        var ranges = [Range<Index>]()

        let pCount = string.count
        let strCount = self.count

        if strCount < pCount { return [] }

        for idx in 0...(strCount-pCount) {
            let from = index(self.startIndex, offsetBy: idx)

            if let toIdx = index(from, offsetBy: pCount, limitedBy: self.endIndex) {
                if string == self[from..<toIdx] {
                    ranges.append(from..<toIdx)
                }
            }
        }

        return ranges
    }

    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }

    func removingNewLines() -> String {
        return components(separatedBy: .newlines).joined()
    }

    var removingPercentEncoding: String? {
        return NSString(string: self).removingPercentEncoding
    }

    func commandAndParams() -> (command: String, params: String)? {
        guard self.first == "/" && self.count > 1 else { return nil }

        let components = self.components(separatedBy: " ")
        let command = String(components[0].dropFirst())
        let params = components.dropFirst().joined(separator: " ")
        return (command: command, params: params)
    }

    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}
