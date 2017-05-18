using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Lib;

namespace DemoUnitTest
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestAdd()
        {
            Class1 c1 = new Class1();

            Assert.AreEqual(10, c1.Add(4, 6));
        }

        [TestMethod]
        public void TestSubstract()
        {
            Class1 c1 = new Class1();

            Assert.AreEqual(2, c1.Substract(6, 4));
        }
    }
}
