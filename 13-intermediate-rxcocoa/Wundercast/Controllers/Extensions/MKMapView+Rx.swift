/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import MapKit
import RxSwift
import RxCocoa

extension MKMapView: HasDelegate {
  
  public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {

  public weak private(set) var mapview: MKMapView?
  public init(mapview: ParentObject) {
    self.mapview = mapview
    super.init(parentObject: mapview, delegateProxy: RxMKMapViewDelegateProxy.self)
  }
  
  static func registerKnownImplementations() {
    self.register { parent -> RxMKMapViewDelegateProxy in
      return RxMKMapViewDelegateProxy(mapview: parent)
    }
  }

}

extension Reactive where Base: MKMapView {
  
  public var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
    return RxMKMapViewDelegateProxy.proxy(for: base)
  }
  
  public func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
    return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
  }
  
  var overlays: Binder<[MKOverlay]> {
    return Binder(base, binding: { (mapView, overlays) in
      mapView.removeOverlays(mapView.overlays)
      mapView.addOverlays(overlays)
    })
  }
  
  public var regionDidChangeAnimated: ControlEvent<Bool> {
    let source = delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
      .map { params in
        return (params[1] as? Bool) ?? false
      }
    return ControlEvent(events: source)
  }
  
  public var location: Binder<CLLocationCoordinate2D> {
    return Binder.init(base, binding: { (mapView, location) in
      let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
      mapView.region = MKCoordinateRegion(center: location, span: span)
    })
  }
}
