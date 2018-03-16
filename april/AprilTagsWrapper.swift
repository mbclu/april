/* (C) 2013-2015, The Regents of The University of Michigan
 All rights reserved.

 This software may be available under alternative licensing
 terms. Contact Edwin Olson, ebolson@umich.edu, for more information.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 */

import AprilTags
import UIKit
import CoreGraphics

class AprilTagsWrapper {
    var tagFamily: UnsafeMutablePointer<apriltag_family_t>
    var detector: UnsafeMutablePointer<apriltag_detector_t>

    init() {
        self.tagFamily = tag36h11_create()
        self.detector = apriltag_detector_create()
        apriltag_detector_add_family(detector, tagFamily)
    }

    func detect(inImage image: UIImage) {
        let convertedImage = convertImage(image)
        let detections = apriltag_detector_detect(detector, convertedImage)
        if let detections = detections {
            iterateDetections(detections)
        }

        image_u8_destroy(convertedImage)
    }

    private func convertImage(_ image: UIImage) -> UnsafeMutablePointer<image_u8_t> {
        let cgimage = image.cgImage
        let width = cgimage?.width ?? 0
        let height = cgimage?.height ?? 0

        // convert the image to nsdata
        let jpeg = UIImageJPEGRepresentation(image, 1.0)
        let length = (jpeg?.count)! / MemoryLayout<UInt8>.size
//        let png = UIImagePNGRepresentation(image) ?? nil
//        let length = png?.count ?? 0
//        var bytes = [UInt8](repeating: 0, count: length)
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length * MemoryLayout<UInt8>.size)
//        png?.copyBytes(to: bytes, count: length)
        jpeg?.copyBytes(to: bytes, count: length * MemoryLayout<UInt8>.size)
//        bytes.pointee = png.getBytes()
//        let stride = ((((cgimage?.bitsPerPixel)! * width) + 31) / 32) * 4
        // Also provided as cgimage?.bytesPerRow

        return image_u8_create_from_rgb3(Int32(width), Int32(height), bytes, Int32(MemoryLayout.stride(ofValue: bytes)))
    }

    private func iterateDetections(_ detections: UnsafeMutablePointer<zarray_t>) {
        var i: Int32 = 0
        while i < zarray_size(detections) {
            var det: UnsafeMutableRawPointer?
            zarray_get(detections, i, det)
            print(det?.debugDescription ?? "Unable to obtain tag info!")
            i += 1
        }

        apriltag_detections_destroy(detections);
    }

//    func create_image() {
//        // 1.
//
//
//        // 2.
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        let bitsPerComponent = 8
//
//        var pixels: UnsafeMutableRawPointer
//        pixels = calloc(height * width, MemoryLayout<UInt8>.size)
//        //        UnsafeUInt32 * pixels;
//        //        pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
//
//        // 3.
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGImageAlphaInfo.premultipliedLast | CGBitmapInfo.byteOrderBig32)
//        //        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        //        CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//
//        // 4.
//        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
//
//        // 5. Cleanup
//        CGColorSpaceRelease(colorSpace);
//        CGContextRelease(context);
//    }
}
