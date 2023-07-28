import UIKit
import MapboxMaps

public class TrackingModeExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()

    private var mapView: MapView!
    private lazy var toggleBearingImageButton = UIButton(frame: .zero)
    private lazy var styleToggle = UISegmentedControl(items: Style.allCases.map(\.name))
    private var style: Style = .satelliteStreets {
        didSet {
            mapView.mapboxMap.styleURI = style.uri
        }
    }
    private var showsBearingImage: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }

    private enum Style: Int, CaseIterable {
        var name: String {
            switch self {
            case .light:
                return "Light"
            case .satelliteStreets:
                return "Satellite"
            case .customUri:
                return "Custom"
            }
        }

        var uri: StyleURI {
            switch self {
            case .light:
                return .light
            case .satelliteStreets:
                return .satelliteStreets
            case .customUri:
                let localStyleURL = Bundle.main.url(forResource: "blueprint_style", withExtension: "json")!
                return .init(url: localStyleURL)!
            }
        }

        case light
        case satelliteStreets
        case customUri
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set initial camera settings
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.26301831966747, longitude: -121.97647612483807), zoom: 10)
        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: style.uri)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        addStyleToggle()

        // Setup and create button for toggling show bearing image
        setupToggleShowBearingImageButton()

        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()

        // Update the camera's centerCoordinate when a locationUpdate is received.
        mapView.location.onLocationChange.observe { [weak mapView] newLocation in
            guard let location = newLocation.last, let mapView else { return }
            mapView.camera.ease(
                to: CameraOptions(center: location.coordinate, zoom: 15),
                duration: 1.3)
        }.store(in: &cancelables)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    @objc func showHideBearingImage() {
        showsBearingImage.toggle()
    }

    func syncPuckAndButton() {
        // Update puck config
        let configuration = Puck2DConfiguration.makeDefault(showBearing: showsBearingImage)

        mapView.location.options.puckType = .puck2D(configuration)

        // Update button title
        let title: String = showsBearingImage ? "Hide bearing image" : "Show bearing image"
        toggleBearingImageButton.setTitle(title, for: .normal)
    }

    private func setupToggleShowBearingImageButton() {
        // Styling
        toggleBearingImageButton.backgroundColor = .systemBlue
        toggleBearingImageButton.addTarget(self, action: #selector(showHideBearingImage), for: .touchUpInside)
        toggleBearingImageButton.setTitleColor(.white, for: .normal)
        toggleBearingImageButton.layer.cornerRadius = 4
        toggleBearingImageButton.clipsToBounds = true
        toggleBearingImageButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        toggleBearingImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleBearingImageButton)

        // Constraints
        toggleBearingImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        toggleBearingImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        toggleBearingImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0).isActive = true

        syncPuckAndButton()
    }

    @objc func switchStyle(sender: UISegmentedControl) {
        style = Style(rawValue: sender.selectedSegmentIndex) ?? . satelliteStreets
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        styleToggle.selectedSegmentIndex = style.rawValue
        styleToggle.addTarget(self, action: #selector(switchStyle(sender:)), for: .valueChanged)
        styleToggle.translatesAutoresizingMaskIntoConstraints = false

        // set the segmented control as the title view
        navigationItem.titleView = styleToggle
    }
}
