using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PkgConsumeDemoApp
{
    class Program
    {
        static void Main(string[] args)
        {
            NugetPackageDemo.DemoPackage demoPkg = new NugetPackageDemo.DemoPackage();

            Console.WriteLine(demoPkg.HelloWorldNugetDemo());

            Console.ReadLine();

        }
    }
}
