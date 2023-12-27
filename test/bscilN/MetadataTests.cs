using System.Text;

namespace Tests;

// TODO rewrite to ilasm source code
class Metarow {
  // ulong mask;
  List<byte[]> data;
  Dictionary<string, int> cache;

  public Metarow() {
    // mask = 1ul << i;
    data = new List<byte[]>();
    cache = new Dictionary<string, int>();
  }

  public int Add(byte[] val) {
    string key = Convert.ToBase64String(val);
    if (cache.ContainsKey(key)) {
      return cache[key];
    }
    int index = data.Count;
    cache[key] = index;
    data.Add(val);
    return index;
  }

  public int GetCount() => data.Count;

  public void WriteHeap(System.IO.Stream stream) {
    foreach (var val in data) {
      stream.Write(val);
    }
  }
}

static class SrcTildeStream {

}

[TestClass]
public class MetadataTests {
  [TestMethod]
  public void AddReturnsIndex() {
    var A = Encoding.GetEncoding("UTF-8").GetBytes("A");
    var B = Encoding.GetEncoding("UTF-8").GetBytes("B");

    var row = new Metarow();

    var a = row.Add(A);
    Assert.AreEqual(1, row.GetCount());

    var b = row.Add(B);
    Assert.AreEqual(2, row.GetCount());
    Assert.AreNotEqual(a, b);

    Assert.AreEqual(a, row.Add(A));
    Assert.AreEqual(b, row.Add(B));
  }
}
