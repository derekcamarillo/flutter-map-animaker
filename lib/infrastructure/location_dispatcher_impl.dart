// Dart imports:
import 'dart:collection';

// Project imports:
import 'package:flutter_animarker/core/i_lat_lng.dart';
import 'package:flutter_animarker/core/i_location_dispatcher.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';

import 'i_location_observable.dart';

class LocationDispatcherImpl extends ILocationObservable implements ILocationDispatcher {
  @override
  final threshold;
  final DoubleLinkedQueue<ILatLng> _locationQueue = DoubleLinkedQueue<ILatLng>();

  LocationDispatcherImpl({this.threshold = 1.5});

  @override
  ILatLng get popLast => _locationQueue.removeLast();

  @override
  ILatLng get next {
    if (_locationQueue.isNotEmpty) {
      var entry = _locationQueue.firstEntry()!;

      return _thresholding(entry).remove();
    }

    return ILatLng.empty();
  }

  @override
  ILatLng get peek {
    if (_locationQueue.isNotEmpty) {
      return _locationQueue.first;
    }

    return ILatLng.empty();
  }

  @override
  ILatLng get last {
    if (_locationQueue.isNotEmpty) {
      return _locationQueue.last;
    }

    return ILatLng.empty();
  }

  /*@override
  ILatLng goTo(int index) {
    var location = _locationQueue.skip(index);
    _locationQueue.clear();
    _locationQueue.addAll(location);
    return location;
  }*/

  DoubleLinkedQueueEntry<ILatLng> _thresholding(DoubleLinkedQueueEntry<ILatLng> entry) {
    var current = entry.element;

    var nextEntry = entry.nextEntry();
    var upcomingEntry = nextEntry?.nextEntry();

    var next = nextEntry?.element ?? ILatLng.empty();
    var upcoming = upcomingEntry?.element ?? ILatLng.empty();

    if (upcoming.isNotEmpty) {
      var currentBearing = SphericalUtil.computeHeading(current, next);

      var upComingBearing = SphericalUtil.computeHeading(next, upcoming);

      var delta = upComingBearing - currentBearing;

      if (delta.abs() < threshold) {
        nextEntry!.remove();
      }
    }

    return entry;
  }

  @override
  void push(ILatLng latLng) {
    _locationQueue.addLast(latLng);
    notifyObservers();
  }

  @override
  void dispose() => _locationQueue.clear();

  @override
  void clear() => _locationQueue.clear();

  @override
  bool get isEmpty => _locationQueue.isEmpty;

  @override
  int get length => _locationQueue.length;

  @override
  bool get isNotEmpty => _locationQueue.isNotEmpty;

  @override
  List<ILatLng> get values => List<ILatLng>.unmodifiable(_locationQueue.toList(growable: true));
}
