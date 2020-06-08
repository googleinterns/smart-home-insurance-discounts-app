library sdk;

import 'package:optional/optional.dart';
import 'package:sdk/services/access_devices.dart';
import 'package:sdk/services/login.dart';
import 'package:sdk/services/resource_picker.dart';

class SDK {
  Login _login;
  ResourcePicker _resourcePicker;
  AccessDevices _accessDevices;

  final Duration interactiveFlowTimeout;
  final Duration nonInteractiveFlowTimout;

  String clientId;
  String clientSecret;
  String enterpriseId;
  String redirectURL;

  SDK(String clientId, String clientSecret, String enterpriseId,
      String redirectURL,
      {this.interactiveFlowTimeout = const Duration(minutes: 5),
      this.nonInteractiveFlowTimout = const Duration(seconds: 1)}) {
    this.clientId = clientId;
    this.clientSecret = clientSecret;
    this.enterpriseId = enterpriseId;
    this.redirectURL = redirectURL;

    _login = new Login(
        interactiveFlowTimeout: interactiveFlowTimeout,
        nonInteractiveFlowTimeout: nonInteractiveFlowTimout);
    _resourcePicker = new ResourcePicker(clientId, clientSecret,
        resourcePickerTimeoutDuration: interactiveFlowTimeout);
  }

  Future<String> login() => _login.login();

  Future<String> logout() => _login.logout();

  Future<Map> getUserDetails() => _login.getUserDetails();

  Future<String> requestDeviceAccess() async {
    String status = await _resourcePicker.askForAuthorization();
    if (status == "authorization successful") {
      _accessDevices = new AccessDevices(
          _resourcePicker.accessToken, this.enterpriseId,
          accessDevicesTimeoutDuration: nonInteractiveFlowTimout);
    }
    return status;
  }

  Future<Optional<String>> getAllDevices() async {
    if (_accessDevices == null) {
      return Optional.empty();
    } else {
      return await _accessDevices.getAllDevices();
    }
  }

  Future<Optional<String>> getAllStructures() async {
    if (_accessDevices == null) {
      return Optional.empty();
    } else {
      return await _accessDevices.getAllStructures();
    }
  }

  Future<Optional<String>> getDeviceStatus(String deviceId) async {
    if (_accessDevices == null) {
      return Optional.empty();
    } else {
      return await _accessDevices.getDeviceStatus(deviceId);
    }
  }
}
