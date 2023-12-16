namespace Tests;

[TestClass]
public class HeapTests
{
  [TestMethod]
  public void AddReturnsIndex()
  {
    var a = StringHeap.Add("A");
    var b = StringHeap.Add("BBB");
    Assert.AreNotEqual(a, b);

    Assert.AreEqual(a, StringHeap.Add("A"));
    Assert.AreEqual(b, StringHeap.Add("BBB"));

    // Might be interesting to test WriteHeap() ...but would need to set up test-mocks for C.output file stream
  }
}
