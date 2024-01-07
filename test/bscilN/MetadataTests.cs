using System.Text;

namespace Tests;


[TestClass]
public class MetadataTests {
  [TestMethod]
  public void AddReturnsIndex() {
    var A = Encoding.GetEncoding("UTF-8").GetBytes("A");
    var B = Encoding.GetEncoding("UTF-8").GetBytes("B");

    var table = new MetaTable();

    var a = table.Add(A);
    Assert.AreEqual(1, table.GetCount());

    var b = table.Add(B);
    Assert.AreEqual(2, table.GetCount());
    Assert.AreNotEqual(a, b);

    Assert.AreEqual(a, table.Add(A));
    Assert.AreEqual(b, table.Add(B));
  }

  [TestMethod]
  public void ResolutionScope() {
    Assert.AreEqual(0b11000, CodedIndex.ResolutionScope(new Token(TildeStream.Module, 0b110)));
    Assert.AreEqual(0b11010, CodedIndex.ResolutionScope(new Token(TildeStream.AssemblyRef, 0b110)));
  }
}
