import UIKit

/// A ``ViewportState`` implementation that tracks the location puck (to show a puck, use
/// ``LocationOptions/puckType``)
///
/// Use ``ViewportManager/makeFollowPuckViewportState(options:)`` to create instances of this
/// class.
public final class FollowPuckViewportState {

    /// Configuration options for this state.
    public var options: FollowPuckViewportStateOptions {
        get { optionsSubject.value }
        set { optionsSubject.value = newValue }
    }

    private let impl: CameraViewportState
    private let optionsSubject: CurrentValueSignalSubject<FollowPuckViewportStateOptions>

    internal init(options: FollowPuckViewportStateOptions,
                  mapboxMap: MapboxMapProtocol,
                  onPuckRender: Signal<PuckRenderingData>,
                  safeAreaPadding: Signal<UIEdgeInsets?>) {
        let optionsSubject = CurrentValueSignalSubject(options)
        self.optionsSubject = optionsSubject

        let resultCamera = Signal
            .combineLatest(optionsSubject.signal.skipRepeats(), onPuckRender.map(\.followPuckState).skipRepeats())
            .map { (options, renderingState) in
                CameraOptions(
                    center: renderingState.coordinate,
                    padding: options.padding,
                    zoom: options.zoom,
                    bearing: options.bearing?.evaluate(state: renderingState),
                    pitch: options.pitch)
            }

        self.impl = CameraViewportState(cameraOptions: resultCamera, mapboxMap: mapboxMap, safeAreaPadding: safeAreaPadding)
    }
}

extension FollowPuckViewportState: ViewportState {
    /// :nodoc:
    /// See ``ViewportState/observeDataSource(with:)``.
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        impl.observeDataSource(with: handler)
    }

    /// :nodoc:
    /// See ``ViewportState/startUpdatingCamera()``.
    public func startUpdatingCamera() {
        impl.startUpdatingCamera()
    }

    /// :nodoc:
    /// See ``ViewportState/stopUpdatingCamera()``.
    public func stopUpdatingCamera() {
        impl.stopUpdatingCamera()
    }
}

extension FollowPuckViewportState {
    /// Substate of ``PuckRenderingData`` which contains only data needed for ``FollowPuckViewportState`` rendering.
    /// Allows to use ``Signal.skipRepeats()`` and avoid unnecessary recalculations.
    struct RenderingState: Equatable {
        var coordinate: CLLocationCoordinate2D
        var heading: CLLocationDirection?
        var bearing: CLLocationDirection?
    }
}

extension PuckRenderingData {
    var followPuckState: FollowPuckViewportState.RenderingState {
        FollowPuckViewportState.RenderingState(
            coordinate: location.coordinate,
            heading: heading?.direction,
            bearing: location.bearing
        )
    }
}

extension FollowPuckViewportStateBearing {
    func evaluate(state: FollowPuckViewportState.RenderingState) -> CLLocationDirection? {
        switch self {
        case .constant(let value):
            return value
        case .heading:
            return state.heading
        case .course:
            return state.bearing
        }
    }
}
