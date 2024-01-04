using System.Text;

namespace Tests;


[TestClass]
public class MetadataTests {
  [TestMethod]
  public void AddReturnsIndex() {
    var A = Encoding.GetEncoding("UTF-8").GetBytes("A");
    var B = Encoding.GetEncoding("UTF-8").GetBytes("B");

    var row = new MetaRow();

    var a = row.Add(A);
    Assert.AreEqual(1, row.GetCount());

    var b = row.Add(B);
    Assert.AreEqual(2, row.GetCount());
    Assert.AreNotEqual(a, b);

    // TODO cache not implemented yet
    // Assert.AreEqual(a, row.Add(A));
    // Assert.AreEqual(b, row.Add(B));
  }
}
