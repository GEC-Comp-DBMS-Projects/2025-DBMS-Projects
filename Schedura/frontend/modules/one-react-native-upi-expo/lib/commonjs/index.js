"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _reactNative = require("react-native");
const LINKING_ERROR = `The package 'one-react-native-upi' doesn't seem to be linked. Make sure: \n\n` + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const OneReactNativeUpi = _reactNative.NativeModules.OneReactNativeUpi ? _reactNative.NativeModules.OneReactNativeUpi : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
const OneUpi = {
  initiate(_ref, onSuccess, onFailure) {
    let {
      targetPackage = '',
      chooserText = 'Pay with ',
      ...config
    } = _ref;
    OneReactNativeUpi.initiatePayment({
      targetPackage,
      chooserText,
      ...config
    }, onSuccess, onFailure);
  },
  getInstalledApps() {
    return OneReactNativeUpi.getInstalledUPIApps();
  }
};
var _default = OneUpi;
exports.default = _default;
//# sourceMappingURL=index.js.map