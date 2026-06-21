package com.example.owasptoprisks

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
        /// OWASP M2 - Inadequate Supply Chain Security
        ///
        /// Flutter automatically registers plugins during application startup.
        /// By removing all registered plugins we can demonstrate how much the
        /// application depends on third party libraries and platform integrations.
        ///
        /// Packages such as secure storage, camera, location, notifications,
        /// and many others rely on native plugin registration.
        ///
        /// This code is intentionally used for demonstration purposes only.
        /// In a real application removing all plugins would break any feature
        /// that depends on Flutter plugins and result in MissingPluginException.

        /// override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        /// flutterEngine?.plugins?.removeAll()
        /// }
}
