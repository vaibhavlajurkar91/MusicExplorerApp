// Deliberately broken file used to verify Amalgm's CI failure reporting.
//
// `flutter analyze` should flag the return below: a String cannot be returned
// where an int is declared. Delete this file once the check-logs panel has
// been verified.

class CiFailureDemo {
  int brokenValue() {
    const String text = 'this is not a number';
    return text;
  }
}
