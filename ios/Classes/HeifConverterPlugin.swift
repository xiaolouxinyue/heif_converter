import Flutter
import UIKit

public class HeifConverterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "heif_converter", binaryMessenger: registrar.messenger())
    let instance = HeifConverterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
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
      let image: UIImage? = UIImage(named: path)
      if image == nil {
        return nil
      }
      var imageData: Data?
      if (output.hasSuffix(".jpg") || output.hasSuffix(".jpeg")) {
        imageData = image!.jpegData(compressionQuality: 1.0)
      } else if (output.hasSuffix(".png")) {
        imageData = image?.flattenedPngData()
      } else {
        return nil
      }
      FileManager.default.createFile(atPath: output, contents: imageData, attributes: nil)
      return output
  }
}

extension UIImage {
    func flattenedPngData(isOpaque: Bool = true) -> Data? { 
      flattened(isOpaque: isOpaque).pngData()
    }
    
    func flattened(isOpaque: Bool = true) -> UIImage {
        if imageOrientation == .up { return self }
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }
    }
}
