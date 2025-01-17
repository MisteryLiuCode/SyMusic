//
//  SyPublic.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    
    func pauseAnimate() {
        let pausedTime: CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    func resumeAnimate() {
        let pausedTime: CFTimeInterval = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause: CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

//截屏
func screenshotsImage() -> UIImage {
    let screenWindow = UIApplication.shared.keyWindow
    UIGraphicsBeginImageContext((screenWindow?.frame.size)!)
    screenWindow?.layer.render(in: UIGraphicsGetCurrentContext()!)
    let viewImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return viewImage
}

//主题色
internal let themeColor = rgbWithHex(rgbValue: 0x121112)//rgbWithValue(r: 241, g: 242, b: 243, alpha: 1.0)

//字典获取value
func dicForValue(dic: NSDictionary, key: String) -> String {
    var valueStr = ""
    let value = dic.object(forKey: key)
    if value != nil && !(value as AnyObject).isEqual(NSNull()) {
        valueStr = String(describing: (value as AnyObject))
    }
    return valueStr
}

func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
        return currentViewController(base: nav.visibleViewController)
    }
    if let tab = base as? SyTabBarController {
        return currentViewController(base: tab.selectedViewController)
    }
    if let presented = base?.presentedViewController {
        return currentViewController(base: presented)
    }
    
    return base
}

//阿拉伯数字转中文
extension Int {
    var CN: String {
        get {
            if self == 0 {
                return strCommon(key: "sy_zero")
            }
            let zhNumbers = [strCommon(key: "sy_zero"),
                             strCommon(key: "sy_one"),
                             strCommon(key: "sy_two"),
                             strCommon(key: "sy_three"),
                             strCommon(key: "sy_four"),
                             strCommon(key: "sy_five"),
                             strCommon(key: "sy_six"),
                             strCommon(key: "sy_seven"),
                             strCommon(key: "sy_eight"),
                             strCommon(key: "sy_nine")]
            let units = ["",
                         strCommon(key: "sy_ten"),
                         strCommon(key: "sy_hundred"),
                         strCommon(key: "sy_thousand"),
                         strCommon(key: "sy_ten_thousand"),
                         strCommon(key: "sy_ten"),
                         strCommon(key: "sy_hundred"),
                         strCommon(key: "sy_thousand"),
                         strCommon(key: "sy_a_hundred_million"),
                         strCommon(key: "sy_ten"),
                         strCommon(key: "sy_hundred"),
                         strCommon(key: "sy_thousand")]
            var cn = ""
            var currentNum = 0
            var beforeNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                if index == 0{
                    if currentNum != 0 {
                        cn = zhNumbers[currentNum]
                        continue
                    }
                } else {
                    beforeNum = self/Int(pow(10.0,Double(index-1)))%10
                }
                if [1,2,3,5,6,7,9,10,11].contains(index) {
                    if currentNum == 1 && [1,5,9].contains(index) && index == intLength { // 处理一开头的含十单位
                        cn = units[index] + cn
                    } else if currentNum != 0 {
                        cn = zhNumbers[currentNum] + units[index] + cn
                    } else if beforeNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                    continue
                }
                if [4,8,12].contains(index) {
                    cn = units[index] + cn
                    if (beforeNum != 0 && currentNum == 0) || currentNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                }
            }
            return cn
        }
    }
}

protocol HashProtocol {
    var message: Array<UInt8> { get }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len: Int) -> Array<UInt8>
}

extension HashProtocol {
    
    func prepare(_ len: Int) -> Array<UInt8> {
        var tmpMessage = message
        
        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0
        
        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }
        
        tmpMessage += Array<UInt8>(repeating: 0, count: counter)
        return tmpMessage
    }
}

func toUInt32Array(_ slice: ArraySlice<UInt8>) -> Array<UInt32> {
    var result = Array<UInt32>()
    result.reserveCapacity(16)
    
    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3
        
        result.append(val)
    }
    return result
}

struct BytesGenerator: IteratorProtocol {
    
    let chunkSize: Int
    let data: [UInt8]
    
    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }
    
    var offset = 0
    
    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset..<offset + end]
        offset += result.count
        return result.count > 0 ? result : nil
    }
}

struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]
    
    func makeIterator() -> BytesGenerator {
        return BytesGenerator(chunkSize: chunkSize, data: data)
    }
}

func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFFFFFF) | (value >> (32 - bits))
}

class MD5: HashProtocol {
    
    static let size = 16 // 128 / 8
    let message: [UInt8]
    
    init (_ message: [UInt8]) {
        self.message = message
    }
    
    /** specifies the per-round shift amounts */
    fileprivate let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                        5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                        4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                        6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]
    
    /** binary integer part of the sines of integers (Radians) */
    fileprivate let sines: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                                       0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                                       0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                                       0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                                       0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                                       0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                                       0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                                       0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                                       0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                                       0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                                       0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                                       0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                                       0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                                       0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                                       0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                                       0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]
    
    fileprivate let hashes: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)
        
        // hash values
        var hh = hashes
        
        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        
        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            let M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")
            
            // Initialize hash value for this chunk:
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]
            
            var dTemp: UInt32 = 0
            
            // Main loop
            for j in 0 ..< sines.count {
                var g = 0
                var F: UInt32 = 0
                
                switch j {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                    break
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                    break
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                    break
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                    break
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ sines[j] &+ M[g]), bits: shifts[j])
                A = dTemp
            }
            
            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)
        
        hh.forEach {
            let itemLE = $0.littleEndian
            result += [UInt8(itemLE & 0xff), UInt8((itemLE >> 8) & 0xff), UInt8((itemLE >> 16) & 0xff), UInt8((itemLE >> 24) & 0xff)]
        }
        return result
    }
}

extension Int {
    /** Array of bytes with optional padding (little-endian) */
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
    
}

extension NSMutableData {
    /** Convenient way to append bytes */
    func appendBytes(_ arrayOfBytes: [UInt8]) {
        append(arrayOfBytes, length: arrayOfBytes.count)
    }
    
}

/** array of bytes, little-endian representation */
func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout.size(ofValue: value) * 8)
    
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
    var bytes = [UInt8](repeating: 0, count: totalBytes)
    for j in 0..<min(MemoryLayout<T>.size, totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
    }
    valuePointer.deallocate()
    return bytes
}
