// Copyright 2015-present 650 Industries. All rights reserved.

package abi5_0_0.host.exp.exponent.modules.external.crypto;

import android.util.Base64;

import abi5_0_0.com.facebook.react.bridge.Arguments;
import abi5_0_0.com.facebook.react.bridge.Promise;
import abi5_0_0.com.facebook.react.bridge.ReactApplicationContext;
import abi5_0_0.com.facebook.react.bridge.ReactContextBaseJavaModule;
import abi5_0_0.com.facebook.react.bridge.ReactMethod;
import abi5_0_0.com.facebook.react.bridge.WritableMap;

import java.security.InvalidKeyException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class CryptoModule extends ReactContextBaseJavaModule {

  public CryptoModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "CryptoModule";
  }

  @ReactMethod
  public void getHmacSHA1(String key, String bytes, final Promise promise) {
    WritableMap result = Arguments.createMap();
    SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(), "HmacSHA1");

    try {
      Mac mac = Mac.getInstance("HmacSHA1");
      mac.init(keySpec);
      byte[] output = mac.doFinal(bytes.getBytes());
      result.putBoolean("success", true);
      result.putString("output", Base64.encodeToString(output, Base64.DEFAULT));
    } catch (InvalidKeyException e) {
      result.putBoolean("success", false);
      result.putString("error", "Invalid key");
    } catch (Exception e) {
      result.putBoolean("success", false);
    }

    promise.resolve(result);
  }
}
