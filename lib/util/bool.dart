
import 'package:get/get.dart';

extension BoolExtension on bool {
  /// Returns a `RxBool` with [this] `bool` as initial value.
  String toYesOrNo() => this ? "yes" : "no";
}

extension RxBoolExtension on RxBool {
  /// Returns a `RxBool` with [this] `bool` as initial value.
  String toYesOrNo() => this.value ? "yes" : "no";
}