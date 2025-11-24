import { NativeModules } from 'react-native';
const LINKING_ERROR = `The package 'one-react-native-upi' doesn't seem to be linked. Make sure: \n\n` + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const OneReactNativeUpi = NativeModules.OneReactNativeUpi ? NativeModules.OneReactNativeUpi : new Proxy({}, {
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
export default OneUpi;
//# sourceMappingURL=index.js.map