package com.sarah.edu.complete.sarah_edu_complete

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.AdChoicesView

class MainActivity : FlutterActivity() {
  private var nativeAdFactory: GoogleMobileAdsPlugin.NativeAdFactory? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    nativeAdFactory = ListTileNativeAdFactory(layoutInflater)
    GoogleMobileAdsPlugin.registerNativeAdFactory(
      flutterEngine,
      "listTile",
      nativeAdFactory!!
    )
  }

  override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
    GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    nativeAdFactory = null
    super.cleanUpFlutterEngine(flutterEngine)
  }
}

private class ListTileNativeAdFactory(
  private val inflater: LayoutInflater
) : GoogleMobileAdsPlugin.NativeAdFactory {
  override fun createNativeAd(
    nativeAd: NativeAd,
    customOptions: MutableMap<String, Any>?
  ): NativeAdView {
    val adView = inflater.inflate(
      R.layout.native_ad_list_tile,
      null
    ) as NativeAdView

    val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
    val bodyView = adView.findViewById<TextView>(R.id.ad_body)
    val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
    val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
    val adChoicesView = adView.findViewById<AdChoicesView>(R.id.ad_ad_choices)

    adView.headlineView = headlineView
    adView.bodyView = bodyView
    adView.iconView = iconView
    adView.callToActionView = ctaView
    adView.adChoicesView = adChoicesView

    headlineView.text = nativeAd.headline
    bodyView.text = nativeAd.body ?: ""
    bodyView.visibility = if (nativeAd.body == null) View.GONE else View.VISIBLE

    val icon = nativeAd.icon
    if (icon == null) {
      iconView.visibility = View.GONE
    } else {
      iconView.setImageDrawable(icon.drawable)
      iconView.visibility = View.VISIBLE
    }

    ctaView.text = nativeAd.callToAction ?: "Learn more"

    adView.setNativeAd(nativeAd)
    return adView
  }
}
