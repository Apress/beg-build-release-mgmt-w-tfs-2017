#Release notes for build $defname  
**Build Number(s)**  : $($build.buildnumber)    
**Source Branch(es)** : $($build.sourceBranch)  

###Associated work items  
@@WILOOP@@  
* **$($widetail.fields.'System.WorkItemType') $($widetail.id)** [$($widetail.fields.'System.State')] [$($widetail.fields.'System.Title')]($($widetail._links.html.href)) [Assigned To: $($widetail.fields.'System.AssignedTo')]
@@WILOOP@@   

###Associated change sets/commits  
@@CSLOOP@@  
* **ID $($csdetail.changesetid)$($csdetail.commitid)** $($csdetail.comment)    
@@CSLOOP@@