using Microsoft.VisualStudio.TestTools.UITesting;
using Microsoft.VisualStudio.TestTools.UITesting.HtmlControls;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DemoCodedUI.ObjectModel
{
    public class GoogleHome : HtmlDocument
    {



        public GoogleHome(UITestControl searchLimitContainer) :
                base(searchLimitContainer)
        {
            #region Search Criteria
            this.SearchProperties[HtmlDocument.PropertyNames.Id] = "gsr";
            this.SearchProperties[HtmlDocument.PropertyNames.RedirectingPage] = "False";
            this.SearchProperties[HtmlDocument.PropertyNames.FrameDocument] = "False";
            this.FilterProperties[HtmlDocument.PropertyNames.Title] = "Google";
            this.FilterProperties[HtmlDocument.PropertyNames.AbsolutePath] = "/";
            this.FilterProperties[HtmlDocument.PropertyNames.PageUrl] = "https://www.google.lk/?gfe_rd=cr&ei=MgRlV5_RHIvB8gf4-beQDw&gws_rd=ssl";
            this.WindowTitles.Add("Google");
            #endregion
        }

        #region Properties
        public HtmlInputButton GoogleSearchButton
        {
            get
            {
                if ((this.mUIGoogleSearchButton == null))
                {
                    this.mUIGoogleSearchButton = new HtmlInputButton(this);
                    #region Search Criteria
                    this.mUIGoogleSearchButton.SearchProperties[HtmlButton.PropertyNames.Id] = null;
                    this.mUIGoogleSearchButton.SearchProperties[HtmlButton.PropertyNames.Name] = "btnK";
                    this.mUIGoogleSearchButton.SearchProperties[HtmlButton.PropertyNames.DisplayText] = "Google Search";
                    this.mUIGoogleSearchButton.SearchProperties[HtmlButton.PropertyNames.Type] = "submit";
                    this.mUIGoogleSearchButton.FilterProperties[HtmlButton.PropertyNames.Title] = null;
                    this.mUIGoogleSearchButton.FilterProperties[HtmlButton.PropertyNames.Class] = null;
                    this.mUIGoogleSearchButton.FilterProperties[HtmlButton.PropertyNames.ControlDefinition] = "name=\"btnK\" aria-label=\"Google Search\" t";
                    this.mUIGoogleSearchButton.FilterProperties[HtmlButton.PropertyNames.TagInstance] = "7";
                    this.mUIGoogleSearchButton.WindowTitles.Add("Google");
                    #endregion
                }
                return this.mUIGoogleSearchButton;
            }
        }
        #endregion

        #region Fields
        private HtmlInputButton mUIGoogleSearchButton;
        #endregion
    }

}
