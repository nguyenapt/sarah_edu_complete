import UIKit
import google_mobile_ads

final class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable: Any]?
  ) -> GADNativeAdView {
    let adView = GADNativeAdView(frame: .zero)

    // AdChoices overlay (validator yêu cầu)
    let adChoices = GADAdChoicesView()
    adChoices.translatesAutoresizingMaskIntoConstraints = false

    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFit
    iconView.clipsToBounds = true
    iconView.layer.cornerRadius = 8
    iconView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    iconView.heightAnchor.constraint(equalToConstant: 40).isActive = true

    let headline = UILabel()
    headline.translatesAutoresizingMaskIntoConstraints = false
    headline.font = .systemFont(ofSize: 15, weight: .bold)
    headline.numberOfLines = 1

    let body = UILabel()
    body.translatesAutoresizingMaskIntoConstraints = false
    body.font = .systemFont(ofSize: 12, weight: .semibold)
    body.numberOfLines = 2
    body.textColor = UIColor.secondaryLabel

    let cta = UIButton(type: .system)
    cta.translatesAutoresizingMaskIntoConstraints = false
    cta.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
    cta.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    cta.layer.cornerRadius = 12
    cta.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)

    let textStack = UIStackView(arrangedSubviews: [headline, body])
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.axis = .vertical
    textStack.spacing = 4

    let rootStack = UIStackView(arrangedSubviews: [iconView, textStack, cta])
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.axis = .horizontal
    rootStack.alignment = .center
    rootStack.spacing = 12

    adView.addSubview(rootStack)
    adView.addSubview(adChoices)
    NSLayoutConstraint.activate([
      rootStack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
      rootStack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
      rootStack.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
      rootStack.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),

      adChoices.topAnchor.constraint(equalTo: adView.topAnchor, constant: 6),
      adChoices.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -6),
    ])

    adView.iconView = iconView
    adView.headlineView = headline
    adView.bodyView = body
    adView.callToActionView = cta
    adView.adChoicesView = adChoices

    headline.text = nativeAd.headline
    body.text = nativeAd.body
    body.isHidden = nativeAd.body == nil
    if let icon = nativeAd.icon?.image {
      iconView.image = icon
      iconView.isHidden = false
    } else {
      iconView.isHidden = true
    }
    cta.setTitle(nativeAd.callToAction ?? "Learn more", for: .normal)

    adView.nativeAd = nativeAd
    return adView
  }
}

