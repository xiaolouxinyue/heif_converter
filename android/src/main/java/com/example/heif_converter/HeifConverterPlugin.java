package com.example.heif_converter;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** HeifConverterPlugin */
public class HeifConverterPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "heif_converter");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("convert")) {
      if (!call.hasArgument("path") || call.argument<String>("path").isNullOrEmpty()) {
        result.error("Input path is null or empty.");
        return;
      }
      if (!call.hasArgument("output") || call.argument<String>("output").isNullOrEmpty()) {
        result.error("Output path is null or empty.");
        return;
      }
      String path = call.argument<String>("path");
      String output = call.argument<String>("output");
      try {
        output = convert(path, output);
        result.success(output);
      } catch (Exception e) {
        result.error(e.getMessage());
      }
    } else {
      result.notImplemented();
    }
  }

  private String convert(String path, String output) throws IOException {
    Bitmap bitmap = BitmapFactory.decodeFile(path);
    File file = new File(output);
    file.createNewFile();
    Bitmap.CompressFormat format = getFormat(output);
    bitmap.compress(format, 100, new FileOutputStream(file));
    return file.getPath();
  }

  private Bitmap.CompressFormat getFormat(String path) {
    if (path.endsWith(".jpg") || path.endsWith(".jpeg"))
      return Bitmap.CompressFormat.JPEG;
    return Bitmap.CompressFormat.PNG;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}