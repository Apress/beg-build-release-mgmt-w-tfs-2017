using System;
using System.ServiceModel;
using Microsoft.Xrm.Sdk;

namespace PluginDemo
{

    /// <summary>
    /// PluginEntryPoint plug-in.
    /// This is a generic entry point for a plug-in class. Use the Plug-in Registration tool found in the CRM SDK to register this class, import the assembly into CRM, and then create step associations.
    /// A given plug-in can have any number of steps associated with it. 
    /// </summary>    
    public class DemoEntityOneCreate : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DemoEntityOneCreate"/> class.
        /// </summary>
        /// <param name="unsecure">Contains public (unsecured) configuration information.</param>
        /// <param name="secure">Contains non-public (secured) configuration information. 
        /// When using Microsoft Dynamics CRM for Outlook with Offline Access, 
        /// the secure string is not passed to a plug-in that executes while the client is offline.</param>
        public DemoEntityOneCreate(string unsecure, string secure)
            : base(typeof(DemoEntityOneCreate))
        {

            // TODO: Implement your custom configuration handling.
        }


        /// <summary>
        /// Main entry point for he business logic that the plug-in is to execute.
        /// </summary>
        /// <param name="localContext">The <see cref="LocalPluginContext"/> which contains the
        /// <see cref="IPluginExecutionContext"/>,
        /// <see cref="IOrganizationService"/>
        /// and <see cref="ITracingService"/>
        /// </param>
        /// <remarks>
        /// For improved performance, Microsoft Dynamics CRM caches plug-in instances.
        /// The plug-in's Execute method should be written to be stateless as the constructor
        /// is not called for every invocation of the plug-in. Also, multiple system threads
        /// could execute the plug-in at the same time. All per invocation state information
        /// is stored in the context. This means that you should not use global variables in plug-ins.
        /// </remarks>
        protected override void ExecuteCrmPlugin(LocalPluginContext localContext)
        {
            if (localContext == null)
            {
                throw new ArgumentNullException("localContext");
            }

            // TODO: Implement your custom plug-in business logic.
            if (localContext.PluginExecutionContext.InputParameters.Contains("Target") &&
            localContext.PluginExecutionContext.InputParameters["Target"] is Entity)
            {
                
                // Obtain the target entity from the input parameters.
                Entity entity = (Entity)localContext.PluginExecutionContext.InputParameters["Target"];

                int f1val = (int)entity.Attributes["new_intfeild1"];

                if (entity.Attributes.Contains("new_intfield2"))
                {
                    entity.Attributes["new_intfield2"] = (f1val*2).ToString();

                }
                else
                {
                    entity.Attributes.Add("new_intfield2", (f1val * 2).ToString());

                }
            }

        }
    }
}
