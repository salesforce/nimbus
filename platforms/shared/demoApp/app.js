function showAlert() {
  DemoAppBridge.showAlert("Hello from javascript!").then(() => {
    console.log("alert shown");
  });
}

function logCurrentTime() {
  DemoAppBridge.currentTime().then(time => {
    console.log(`the time is ${time}`);
  });
}

function doCallback() {
  DemoAppBridge.withCallback(v => {
    console.log(`callback got ${v}`);
  });
}

function initiateNativeCallingJs() {
  DemoAppBridge.initiateNativeCallingJs();
}

function initiateNativeBroadcastMessage() {
  DemoAppBridge.initiateNativeBroadcastMessage();
}

function demoMethodForNativeToJs(
  boolParam,
  intParam,
  optionalIntParam,
  stringParam,
  userDefinedTypeParam
) {
  const boolParamFormatted = boolParam.toString();
  const intParamFormatted = intParam.toString();
  var optionalIntParamFormatted = "null";
  if (optionalIntParam != null) {
    optionalIntParamFormatted = optionalIntParam.toString();
  }
  const userDefinedTypeParamFormatted = userDefinedTypeParam.toString();
  console.log(
    boolParamFormatted,
    intParamFormatted,
    optionalIntParamFormatted,
    stringParam,
    userDefinedTypeParamFormatted
  );
  return (
    boolParamFormatted +
    ", " +
    intParamFormatted +
    ", " +
    optionalIntParamFormatted +
    ", " +
    stringParam +
    ", " +
    userDefinedTypeParamFormatted
  );
}

function systemAlertHandler(color) {
  if (color === "red") {
    console.log("high alert");
  }
}

function removeSystemAlertHandler() {
  SalesforceVeil.unsubscribeMessage("systemAlert", systemAlertHandler);
}

SalesforceVeil.subscribeMessage("systemAlert", systemAlertHandler);
SalesforceVeil.subscribeMessage(
  "removeSystemAlertHandler",
  removeSystemAlertHandler
);
