namespace Tests;

[TestClass]
public class SignatureTests {
  [TestMethod]
  public void ElementType() {
    Assert.AreEqual(0x08, Signature.ElementType("int32"));
    Assert.AreEqual(0x0E, Signature.ElementType("string"));
  }

  [TestMethod]
  public void MethodDefSig() {
    var expected = new byte[] { 0x00, 0x01, 0x01, 0x0E};
    CollectionAssert.AreEqual(expected, Signature.MethodSig("void", new [] {"string"}));
  }

  [TestMethod]
  public void DecompressUnsignedTest() {
    AssertDecompressUnsigned(0x03, "03");
    AssertDecompressUnsigned(0x7F, "7F");
    AssertDecompressUnsigned(0x80, "8080");
    AssertDecompressUnsigned(0x2E57, "AE57");
    AssertDecompressUnsigned(0x3FFF, "BFFF");
    AssertDecompressUnsigned(0x4000, "C0004000");
    AssertDecompressUnsigned(0x1FFFFFFF, "DFFFFFFF");
  }

  static void AssertDecompressUnsigned(uint actual, string expected) {
    var actualBytes = Signature.CompressUnsigned(actual);
    Assert.AreEqual(expected, string.Concat(actualBytes.Select(b => b.ToString("X2"))));
  }
}
