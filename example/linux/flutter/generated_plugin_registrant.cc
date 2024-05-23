//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <heif_converter/heif_converter_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) heif_converter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HeifConverterPlugin");
  heif_converter_plugin_register_with_registrar(heif_converter_registrar);
}
