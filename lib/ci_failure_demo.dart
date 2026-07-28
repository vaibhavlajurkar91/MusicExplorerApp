// File used to verify Amalgm's CI failure reporting path end to end.

class CiFailureDemo {
  int brokenValue() {
    const String text = 'this is not a number';
    return text.length;
  }
}
