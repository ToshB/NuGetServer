using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;

namespace NuGetServer.Tests.Integration
{
    [TestFixture]
    public class Class1
    {
        [Test]
        public void MethodName_WithCondition_ExpectedOutcome()
        {
            Assert.IsTrue(true);
        }


        [Test]
        public void Method2Name_WithCondition_ExpectedOutcome()
        {
            Assert.IsFalse(false, "Something failed");
        }
    }
}
