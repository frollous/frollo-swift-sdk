//
// Copyright © 2018 Frollo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

struct PublicKey {
    // Production public key, checked 06/11/18
    internal static let active = Data(bytes: [0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00, 0x30, 0x82, 0x01, 0x0A, 0x02, 0x82, 0x01, 0x01, 0x00, 0xE9, 0xA5, 0x69, 0xF1, 0x6F, 0x28, 0x45, 0x1D, 0x8A, 0x01, 0x46, 0xCB, 0x30, 0x92, 0x34, 0x35, 0x27, 0x5D, 0xF6, 0x5B, 0x6A, 0xC4, 0x3F, 0x5C, 0x76, 0x71, 0x98, 0x98, 0x05, 0x95, 0x14, 0x71, 0x32, 0x52, 0x54, 0xF9, 0xA1, 0xCE, 0x10, 0x0C, 0xC9, 0xB8, 0xCE, 0xE1, 0xF3, 0x0B, 0xC5, 0xCA, 0x45, 0x36, 0xBA, 0xCD, 0x70, 0x5F, 0xD3, 0xC3, 0xED, 0xC9, 0x31, 0xCA, 0xB8, 0x79, 0x26, 0xF3, 0xCB, 0x77, 0x39, 0x29, 0xCF, 0x70, 0xB0, 0xB3, 0xE9, 0x05, 0x38, 0x13, 0x3F, 0xB2, 0xFD, 0x3C, 0x90, 0xFA, 0x4B, 0x58, 0x27, 0x60, 0x40, 0x88, 0x8C, 0xAC, 0x00, 0x5B, 0x1C, 0x5B, 0x13, 0xE5, 0x36, 0xC7, 0xEB, 0xCB, 0x66, 0xE5, 0xA3, 0xC9, 0xB1, 0xCA, 0xD0, 0xD6, 0x66, 0x88, 0x02, 0xA7, 0xCF, 0x22, 0xCF, 0x82, 0xCA, 0xB9, 0x84, 0x70, 0xB1, 0x1E, 0x4F, 0xEB, 0x20, 0x6F, 0x35, 0x7C, 0x93, 0x3C, 0xA7, 0x4E, 0x3E, 0x71, 0xBA, 0xA7, 0xF4, 0xAE, 0x84, 0xCF, 0x01, 0xE6, 0x20, 0x27, 0x33, 0x87, 0x5F, 0x26, 0xD2, 0x36, 0x99, 0x07, 0x82, 0xE3, 0x45, 0x27, 0x90, 0xE9, 0xA7, 0x6A, 0x89, 0xDA, 0x7A, 0xD8, 0x98, 0x61, 0xCC, 0x22, 0x19, 0xE4, 0x4E, 0xF4, 0x85, 0xF8, 0x92, 0x37, 0x17, 0xE1, 0x7E, 0xF6, 0xDB, 0x76, 0xF9, 0xDC, 0x67, 0xC4, 0x48, 0xF3, 0xB6, 0x0F, 0x30, 0xA3, 0x79, 0xD0, 0x1F, 0xC9, 0x3A, 0x9D, 0xE9, 0xE9, 0xD8, 0x83, 0x7C, 0x5E, 0xF3, 0x10, 0xEF, 0x1E, 0x44, 0x89, 0x12, 0x95, 0xCB, 0x52, 0xFC, 0x1B, 0x05, 0x1A, 0xBB, 0x06, 0x0A, 0x19, 0x69, 0xF6, 0x76, 0xFE, 0xEB, 0xA4, 0x35, 0x17, 0xCA, 0x5D, 0x62, 0xF0, 0xB1, 0x2F, 0xB7, 0xEE, 0x9A, 0x60, 0xCB, 0x83, 0xAF, 0xC0, 0x6B, 0xBF, 0xC2, 0x81, 0xBC, 0x60, 0x69, 0x08, 0xB5, 0x25, 0xE7, 0xC3, 0x02, 0x03, 0x01, 0x00, 0x01] as [UInt8], count: 294)
    
    // Production backup public key, checked 10/01/17 - Not in use
    internal static let backup = Data(bytes: [0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00, 0x30, 0x82, 0x01, 0x0A, 0x02, 0x82, 0x01, 0x01, 0x00, 0xA7, 0xED, 0x03, 0x66, 0x82, 0x54, 0x26, 0x64, 0x3A, 0xB1, 0xD8, 0x3F, 0x33, 0x1E, 0x44, 0x75, 0x53, 0xBA, 0x21, 0x24, 0xDF, 0x8C, 0xC2, 0xD3, 0xE4, 0x5D, 0xB1, 0x07, 0xEF, 0xAF, 0xFE, 0x35, 0x98, 0xD4, 0x2E, 0x1A, 0xC9, 0x10, 0xE6, 0xA6, 0x87, 0xCB, 0xD9, 0xE6, 0x43, 0x23, 0x57, 0xD0, 0xCB, 0xD4, 0xE4, 0x95, 0xAF, 0xB3, 0xCC, 0x9C, 0x3A, 0x2E, 0x36, 0xDE, 0xB4, 0xE2, 0x10, 0xB2, 0xD6, 0x08, 0x7F, 0x8B, 0xE1, 0x15, 0xC7, 0x46, 0x71, 0x92, 0x4E, 0xCD, 0xA1, 0xA6, 0x22, 0x9B, 0x6D, 0x74, 0xA1, 0x88, 0xF8, 0x08, 0x56, 0x90, 0xCE, 0x9A, 0xF6, 0xC5, 0xA0, 0x8F, 0xA7, 0x27, 0x49, 0xA3, 0x45, 0x8E, 0x04, 0xE4, 0x86, 0x58, 0x12, 0x44, 0x43, 0x8A, 0xFE, 0x45, 0x8A, 0x67, 0x9C, 0x87, 0x97, 0x93, 0x7D, 0xF7, 0x6C, 0x26, 0xC6, 0xD9, 0xBB, 0x57, 0xD4, 0xB6, 0xAF, 0xCB, 0xA3, 0xC6, 0x2B, 0x8E, 0x35, 0x3E, 0xDA, 0xC7, 0x87, 0x24, 0x06, 0xBA, 0x80, 0xF4, 0x7D, 0x97, 0x98, 0xA3, 0x75, 0x5F, 0x1C, 0x61, 0x71, 0x12, 0x28, 0x9A, 0xD2, 0xB6, 0x82, 0x56, 0xB3, 0x43, 0x54, 0xE6, 0x97, 0xC4, 0x09, 0xEB, 0x74, 0xC2, 0xDF, 0xE9, 0xF2, 0xB3, 0x74, 0xAF, 0x6F, 0xC8, 0x35, 0x44, 0xF6, 0xFE, 0x5E, 0x4C, 0xAC, 0xD0, 0xC6, 0x56, 0xE3, 0xBF, 0x9C, 0xBC, 0xE0, 0x6E, 0x62, 0x5B, 0x1A, 0x35, 0x6A, 0x99, 0xED, 0x6E, 0xBD, 0x5B, 0xDC, 0xA8, 0x6B, 0xD3, 0xAF, 0xA9, 0x1F, 0x9B, 0x75, 0x0C, 0x63, 0x32, 0x0A, 0xB8, 0xE9, 0xBF, 0x60, 0xBE, 0xB8, 0xFB, 0xF5, 0x54, 0xFA, 0xEB, 0xF5, 0xE4, 0x09, 0xA3, 0xC0, 0x60, 0x67, 0xDC, 0x9D, 0xF7, 0xA1, 0x26, 0xF1, 0x5B, 0x3A, 0x00, 0x9E, 0x2E, 0x29, 0xD2, 0xF9, 0x10, 0x04, 0x5A, 0x5C, 0x96, 0x64, 0xB7, 0xDE, 0x15, 0x02, 0x03, 0x01, 0x00, 0x01] as [UInt8], count: 294)
}
