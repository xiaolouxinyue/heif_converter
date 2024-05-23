import Cocoa
import FlutterMacOS

public class HeifConverterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "heif_converter", binaryMessenger: registrar.messenger)
        let instance = HeifConverterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
        case "convert":
            let input = call.arguments as! Dictionary<String, Any>
            let path = input["path"] as! String
            var output: String?
            if(!(input["output"] is NSNull)){
                output = input["output"] as! String?
            }
            var format: String?
            if(!(input["format"] is NSNull)){
                format = input["format"] as! String?
            }
            if(output == nil || output!.isEmpty){
                if(format != nil && !format!.isEmpty){
                    output = NSTemporaryDirectory().appendingFormat("%d.%@", Date().timeIntervalSince1970 * 1000, format!)
                } else {
                    result(FlutterError(code: "illegalArgument", message: "Output path and format is blank.", details: nil))
                    break
                }
            }
            result(convert(path: path, output: output!))
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func convert(path: String, output: String) -> String? {
        let bOK = ImageConverter.convertHeif(path: path, output: output)
        return bOK ? output : ""
    }

}

class ImageConverter {
    
    static func convertHeif(path: String, output: String) -> Bool {
        let format = (output.hasSuffix(".jpg") || output.hasSuffix(".jpeg")) ? kUTTypeJPEG : kUTTypePNG
        guard let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: output) as CFURL, format, 1, nil) else { return false }
        guard let image = NSImage(contentsOfFile: path) else { return false }
        let targetSize = image.size
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
        // 先处理一次图片到 targetSize 的尺寸
        guard let cgContext = CGContext(
            data: nil,
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }
        cgContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        guard let newCGImage = cgContext.makeImage() else { return false }
        CGImageDestinationAddImage(dest, newCGImage, nil)
        CGImageDestinationFinalize(dest)
        return true
    }
}
