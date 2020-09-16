let testPlugin = __nimbus.plugins.testPlugin;
if (testPlugin !== undefined) {
  testPlugin.addOne = (x) => Promise.resolve(x + 1);
  testPlugin.failWith = (message) => Promise.reject(message);
  testPlugin.wait = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));
}

// region nullary parameters

function verifyNullaryResolvingToInt() {
  __nimbus.plugins.testPlugin.nullaryResolvingToInt().then((result) => {
    if (result === 5) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToDouble() {
  __nimbus.plugins.testPlugin.nullaryResolvingToDouble().then((result) => {
    if (result === 10.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToString() {
  __nimbus.plugins.testPlugin.nullaryResolvingToString().then((result) => {
    if (result === 'aString') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStruct() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStruct().then((result) => {
    if (result.string === 'String' &&
      result.integer === 1 &&
      result.double === 2.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToDateWrapper() {
  __nimbus.plugins.testPlugin.nullaryResolvingToDateWrapper().then((result) => {
    let date = new Date(result.date);
    if (date.getFullYear() === 2020 &&
      date.getMonth() === 5 && // month is 0 indexed
      date.getDate() === 4 &&
      date.getHours() === 12 &&
      date.getMinutes() === 24 &&
      date.getSeconds() === 48) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToIntList() {
  __nimbus.plugins.testPlugin.nullaryResolvingToIntList().then((result) => {
    if (result[0] === 1 &&
      result[1] === 2 &&
      result[2] === 3) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToDoubleList() {
  __nimbus.plugins.testPlugin.nullaryResolvingToDoubleList().then((result) => {
    if (result[0] === 4.0 &&
      result[1] === 5.0 &&
      result[2] === 6.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStringList() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringList().then((result) => {
    if (result[0] === '1' &&
      result[1] === '2' &&
      result[2] === '3') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStructList() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStructList().then((result) => {
    if (result[0].string === '1' &&
      result[0].integer === 1 &&
      result[0].double === 1.0 &&
      result[1].string === '2' &&
      result[1].integer === 2 &&
      result[1].double === 2.0 &&
      result[2].string === '3' &&
      result[2].integer === 3 &&
      result[2].double === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToIntArray() {
  __nimbus.plugins.testPlugin.nullaryResolvingToIntArray().then((result) => {
    if (result[0] === 1 &&
      result[1] === 2 &&
      result[2] === 3) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStringStringMap() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringStringMap().then((result) => {
    if (result['key1'] === 'value1' &&
      result['key2'] === 'value2' &&
      result['key3'] === 'value3') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStringIntMap() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringIntMap().then((result) => {
    if (result['key1'] === 1 &&
      result['key2'] === 2 &&
      result['key3'] === 3) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStringDoubleMap() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringDoubleMap().then((result) => {
    if (result['key1'] === 1.0 &&
      result['key2'] === 2.0 &&
      result['key3'] === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNullaryResolvingToStringStructMap() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringStructMap().then((result) => {
    if (result['key1'].string === '1' &&
      result['key1'].integer === 1 &&
      result['key1'].double === 1.0 &&
      result['key2'].string === '2' &&
      result['key2'].integer === 2 &&
      result['key2'].double === 2.0 &&
      result['key3'].string === '3' &&
      result['key3'].integer === 3 &&
      result['key3'].double === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

// endregion

// region unary parameters

function verifyUnaryIntResolvingToInt() {
  __nimbus.plugins.testPlugin.unaryIntResolvingToInt(5).then((result) => {
    if (result === 6) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryDoubleResolvingToDouble() {
  __nimbus.plugins.testPlugin.unaryDoubleResolvingToDouble(5.0).then((result) => {
    if (result === 10.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryStringResolvingToInt() {
  __nimbus.plugins.testPlugin.unaryStringResolvingToInt('some string').then((result) => {
    if (result === 11) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryStructResolvingToJsonString() {
  __nimbus.plugins.testPlugin.unaryStructResolvingToJsonString({
    "string": "some string",
    "integer": 5,
    "double": 10.0
  }).then((result) => {
    let json = JSON.parse(result);
    if (json['string'] === 'some string' &&
      json['integer'] === 5 &&
      json['double'] === 10.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryDateWrapperResolvingToJsonString() {
  __nimbus.plugins.testPlugin.unaryDateWrapperResolvingToJsonString({
    "date": "2020-06-04T03:02:01.000+0000"
  }).then((result) => {
    let json = JSON.parse(result);
    if (json['date'] === '2020-06-05T03:02:01.000+0000') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryStringListResolvingToString() {
  __nimbus.plugins.testPlugin.unaryStringListResolvingToString(['1', '2', '3']).then((result) => {
    if (result === '1, 2, 3') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryIntListResolvingToString() {
  __nimbus.plugins.testPlugin.unaryIntListResolvingToString([4, 5, 6]).then((result) => {
    if (result === '4, 5, 6') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryDoubleListResolvingToString() {
  __nimbus.plugins.testPlugin.unaryDoubleListResolvingToString([7.0, 8.0, 9.0]).then((result) => {
    if (result === '7.0, 8.0, 9.0') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryStructListResolvingToString() {
  __nimbus.plugins.testPlugin.unaryStructListResolvingToString([
    {
      string: "test1",
      integer: 1,
      double: 1.0
    },
    {
      string: "test2",
      integer: 2,
      double: 2.0
    },
    {
      string: "test3",
      integer: 3,
      double: 3.0
    }
  ]).then((result) => {
    if (result === 'test1, 1, 1.0, test2, 2, 2.0, test3, 3, 3.0') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryIntArrayResolvingToString() {
  __nimbus.plugins.testPlugin.unaryIntArrayResolvingToString([4, 5, 6]).then((result) => {
    if (result === '4, 5, 6') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryStringStringMapResolvingToString() {
  __nimbus.plugins.testPlugin.unaryStringStringMapResolvingToString({ "key1": "value1", "key2": "value2", "key3": "value3" }).then((result) => {
    if (result === 'key1, value1, key2, value2, key3, value3') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryStringStructMapResolvingToString() {
  __nimbus.plugins.testPlugin.unaryStringStructMapResolvingToString({
    "key1": {
      string: "string1",
      integer: 1,
      double: 1.0
    },
    "key2": {
      string: "string2",
      integer: 2,
      double: 2.0
    },
    "key3": {
      string: "string3",
      integer: 3,
      double: 3.0
    }
  }).then((result) => {
    if (result === 'key1, string1, 1, 1.0, key2, string2, 2, 2.0, key3, string3, 3, 3.0') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyUnaryCallbackEncodable() {
  __nimbus.plugins.testPlugin.unaryCallbackEncodable((result) => {
    if (result.string === 'String' &&
      result.integer === 1 &&
      result.double === 2.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

// endregion

// region callbacks

function verifyNullaryResolvingToStringCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringCallback((result) => {
    if (result === 'param0') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished()
  }).then(() => { });
}

function verifyNullaryResolvingToIntCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToIntCallback((result) => {
    if (result === 1) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToNullableIntCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToNullableIntCallback((result) => {
    if (result == null) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToLongCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToLongCallback((result) => {
    if (result === 2) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToDoubleCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToDoubleCallback((result) => {
    if (result === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStructCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStructCallback((result) => {
    if (result.string === 'String' &&
      result.integer === 1 &&
      result.double === 2.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToDateWrapperCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToDateWrapperCallback((result) => {
    let date = new Date(result.date);
    if (date.getFullYear() === 2020 &&
      date.getMonth() === 5 && // month is 0 indexed
      date.getDate() === 4 &&
      date.getHours() === 0 &&
      date.getMinutes() === 0 &&
      date.getSeconds() === 0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStringListCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringListCallback((result) => {
    if (result[0] === '1' &&
      result[1] === '2' &&
      result[2] === '3') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToIntListCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToIntListCallback((result) => {
    if (result[0] === 1 &&
      result[1] === 2 &&
      result[2] === 3) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToDoubleListCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToDoubleListCallback((result) => {
    if (result[0] === 1.0 &&
      result[1] === 2.0 &&
      result[2] === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStructListCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStructListCallback((result) => {
    if (result[0].string === '1' &&
      result[0].integer === 1 &&
      result[0].double === 1.0 &&
      result[1].string === '2' &&
      result[1].integer === 2 &&
      result[1].double === 2.0 &&
      result[2].string === '3' &&
      result[2].integer === 3 &&
      result[2].double === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToIntArrayCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToIntArrayCallback((result) => {
    if (result[0] === 1 &&
      result[1] === 2 &&
      result[2] === 3) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStringStringMapCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringStringMapCallback((result) => {
    if (result['key1'] === 'value1' &&
      result['key2'] === 'value2' &&
      result['key3'] === 'value3') {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStringIntMapCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringIntMapCallback((result) => {
    if (result['1'] === 1 &&
      result['2'] === 2 &&
      result['3'] === 3) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStringDoubleMapCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringDoubleMapCallback((result) => {
    if (result['1.0'] === 1.0 &&
      result['2.0'] === 2.0 &&
      result['3.0'] === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStringStructMapCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringStructMapCallback((result) => {
    if (result['1'].string === '1' &&
      result['1'].integer === 1 &&
      result['1'].double === 1.0 &&
      result['2'].string === '2' &&
      result['2'].integer === 2 &&
      result['2'].double === 2.0 &&
      result['3'].string === '3' &&
      result['3'].integer === 3 &&
      result['3'].double === 3.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToStringIntCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStringIntCallback((string, int) => {
    if (string === 'param0' && int === 1) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyNullaryResolvingToIntStructCallback() {
  __nimbus.plugins.testPlugin.nullaryResolvingToIntStructCallback((int, struct) => {
    if (int === 2 && struct.string === 'String' &&
      struct.integer === 1 &&
      struct.double === 2.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyUnaryIntResolvingToIntCallback() {
  __nimbus.plugins.testPlugin.unaryIntResolvingToIntCallback(3, (result) => {
    if (result === 4) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyBinaryIntDoubleResolvingToIntDoubleCallback() {
  __nimbus.plugins.testPlugin.binaryIntDoubleResolvingToIntDoubleCallback(3, 2.0, (int, double) => {
    if (int === 4 && double === 4.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then(() => { });
}

function verifyBinaryIntResolvingIntCallbackReturnsInt() {
  let count = 0;
  const verifyCallbacks = () => {
    count = count + 1;
    if (count === 2) {
      __nimbus.plugins.expectPlugin.pass();
      __nimbus.plugins.expectPlugin.finished();
    }
  }
  __nimbus.plugins.testPlugin.binaryIntResolvingIntCallbackReturnsInt(3, (int) => {
    if (int === 2) {
      verifyCallbacks();
    }
  }).then((result) => {
    if (result === 1) {
      verifyCallbacks();
    }
  });
}

// endregion

// region return value errors

function verifyReturnValueSimpleError() {
  __nimbus.plugins.testPlugin.nullaryResolvingToSimpleError().then(() => {
    __nimbus.plugins.expectPlugin.finished();
  }).catch((error) => {
    if (error === "simpleError") {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyReturnValueStructuredError() {
  __nimbus.plugins.testPlugin.nullaryResolvingToStructuredError().then(() => {
    __nimbus.plugins.expectPlugin.finished();
  }).catch((error) => {
    if (error.stringValue === "Structured error" && error.numberValue === 4.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

// endregion

// region events

var listenerID = "";

function subscribeToStructEvent() {
  __nimbus.plugins.testPlugin.addListener("structEvent", (theStruct) => {
    if (theStruct.theStruct.string === "String"
      && theStruct.theStruct.integer === 1
      && theStruct.theStruct.double === 2.0) {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  }).then((listen) => {
    listenerID = listen;
    __nimbus.plugins.expectPlugin.ready();
  });
}

function unsubscribeFromStructEvent() {
  __nimbus.plugins.testPlugin.removeListener(listenerID);
  __nimbus.plugins.expectPlugin.ready();
}

// endregion

// region exceptions

function verifyPromiseResolvesWithNonEncodableException() {
  __nimbus.plugins.testPlugin.promiseResolvesWithNonEncodableException().then((data) => {

  }).catch((error) => {
    if (error === "This is the exception message") {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyPromiseResolvesWithEncodableException1() {
  __nimbus.plugins.testPlugin.promiseResolvesWithEncodableException(1).then((data) => {

  }).catch((error) => {
    if (error.code === 1 && error.message === "Encodable exception 1") {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyPromiseResolvesWithEncodableException2() {
  __nimbus.plugins.testPlugin.promiseResolvesWithEncodableException(2).then((data) => {

  }).catch((error) => {
    if (error.code === 2 && error.message === "Encodable exception 2") {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

// endregion

// region decoder

function verifyStringDecoderRejectsInt() {
  __nimbus.plugins.testPlugin.takesString(5).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyStringDecoderRejectsBool() {
  __nimbus.plugins.testPlugin.takesString(true).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

// TODO: This function is not tested from native iOS code yet. When a simple JSON notation object
// {aaa:"bbb"} crosses the bridge it is first stringified. The stringified JSON object can't be
// decoded by Swift to generic Dictionary.
function verifyStringDecoderRejectsObject() {
  __nimbus.plugins.testPlugin.takesString({ aaa: "bbb" }).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyStringDecoderRejectsNull() {
  __nimbus.plugins.testPlugin.takesString(null).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyStringDecoderRejectsUndefined() {
  var und;
  __nimbus.plugins.testPlugin.takesString(und).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyStringDecoderResolvesStringNull() {
  __nimbus.plugins.testPlugin.takesString("null").then((result) => {
    if (result === "null") {
      __nimbus.plugins.expectPlugin.pass();
    }
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNumberDecoderRejectsString() {
  __nimbus.plugins.testPlugin.takesNumber("number").catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNumberDecoderRejectsObject() {
  __nimbus.plugins.testPlugin.takesNumber({ aaa: "bbb" }).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNumberDecoderRejectsNull() {
  __nimbus.plugins.testPlugin.takesNumber(null).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyNumberDecoderRejectsUndefined() {
  var und;
  __nimbus.plugins.testPlugin.takesNumber(und).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyBoolDecoderRejectsString() {
  __nimbus.plugins.testPlugin.takesBool("number").catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyBoolDecoderRejectsObject() {
  __nimbus.plugins.testPlugin.takesBool({ aaa: "bbb" }).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyBoolDecoderRejectsNull() {
  __nimbus.plugins.testPlugin.takesBool(null).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyBoolDecoderRejectsUndefined() {
  var und;
  __nimbus.plugins.testPlugin.takesBool(und).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyDictionaryDecoderRejectsString() {
  __nimbus.plugins.testPlugin.takesDictionary("test").catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyDictionaryDecoderRejectsInt() {
  __nimbus.plugins.testPlugin.takesDictionary(5).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyDictionaryDecoderRejectsBool() {
  __nimbus.plugins.testPlugin.takesDictionary(true).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyDictionaryDecoderRejectsNull() {
  __nimbus.plugins.testPlugin.takesDictionary(null).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();

    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyDictionaryDecoderRejectsUndefined() {
  var und;
  __nimbus.plugins.testPlugin.takesDictionary(und).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyTestStructDecoderRejectsString() {
  __nimbus.plugins.testPlugin.takesTestStruct("test").catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyTestStructDecoderRejectsInt() {
  __nimbus.plugins.testPlugin.takesTestStruct(5).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyTestStructDecoderRejectsBool() {
  __nimbus.plugins.testPlugin.takesTestStruct(true).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyTestStructDecoderRejectsNull() {
  __nimbus.plugins.testPlugin.takesTestStruct(null).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();

    __nimbus.plugins.expectPlugin.finished();
  });
}

function verifyTestStructDecoderRejectsUndefined() {
  var und;
  __nimbus.plugins.testPlugin.takesTestStruct(und).catch((error) => {
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  });
}

// endregion

// region headless JS global

function verifyTestSetTimeout() {
  setTimeout(()=>{
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  }, 1000);
}

function verifyTestClearTimeout() {
  let timeoutFuncCalled = false;
  const timeoutId = setTimeout(()=>{
    timeoutFuncCalled = true
  }, 2000);
  clearTimeout(timeoutId);
  testPlugin.wait(3000).then(()=>{
    if (!timeoutFuncCalled) {
      __nimbus.plugins.expectPlugin.pass();
      __nimbus.plugins.expectPlugin.finished();
    }
  });
}

function verifyTestClearTimeoutFailsWithRandomId() {
  let timeoutFuncCalled = false;
  setTimeout(()=>{
    __nimbus.plugins.expectPlugin.pass();
    __nimbus.plugins.expectPlugin.finished();
  }, 2000);
  clearTimeout("random id");
}

function verifySetIntervalAndClearInterval() {
  let called = 0
  const timeoutId = setInterval(()=>{
    called++
  }, 1000);
  testPlugin.wait(3200).then(()=>{
    clearInterval(timeoutId);
  });
  testPlugin.wait(5000).then(()=>{
    if (called == 3) {
      __nimbus.plugins.expectPlugin.pass();
      __nimbus.plugins.expectPlugin.finished();
    }
  });
}

// endregion
