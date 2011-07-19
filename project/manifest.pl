@files = (
 ['//property[propertyName="ui_forms"]/propertySheet/property[propertyName="IISCreateConfigForm"]/value'  , 'IISCreateConfigForm.xml'],
 ['//property[propertyName="ui_forms"]/propertySheet/property[propertyName="IISEditConfigForm"]/value'  , 'IISEditConfigForm.xml'],
 
 ['//property[propertyName="http_matchers"]/value', 'matchers/httpMatchers.pl'],
 ['//property[propertyName="iisreset_matchers"]/value', 'matchers/iisresetMatchers.pl'],
 ['//property[propertyName="net_matchers"]/value', 'matchers/netMatchers.pl'],
 ['//property[propertyName="sitescript_matchers"]/value', 'matchers/siteScriptMatchers.pl'],
 ['//property[propertyName="IISServer.pm"]/value', 'agent/lib/IISServer.pm'],
 
 
 ['//procedure[procedureName="StartServer"]/step[stepName="StartServer"]/command' , 'server/startServer.pl'],
 ['//procedure[procedureName="StopServer"]/step[stepName="StopServer"]/command' , 'server/stopServer.pl'],
 ['//procedure[procedureName="CreateWebSite"]/step[stepName="CreateWebSite"]/command' , 'server/createWebSite.pl'],
 ['//procedure[procedureName="DeleteWebSite"]/step[stepName="DeleteWebSite"]/command' , 'server/deleteWebSite.pl'],
 ['//procedure[procedureName="PauseWebSite"]/step[stepName="PauseWebSite"]/command' , 'server/pauseWebSite.pl'],
 ['//procedure[procedureName="StartWebSite"]/step[stepName="StartWebSite"]/command' , 'server/startWebSite.pl'],
 ['//procedure[procedureName="StopWebSite"]/step[stepName="StopWebSite"]/command' , 'server/stopWebSite.pl'],
 ['//procedure[procedureName="CreateVirtualDirectory"]/step[stepName="CreateVirtualDirectory"]/command' , 'server/createVirtualDirectory.pl'],
 ['//procedure[procedureName="DeleteVirtualDirectory"]/step[stepName="DeleteVirtualDirectory"]/command' , 'server/deleteVirtualDirectory.pl'],
 ['//procedure[procedureName="ResetServer"]/step[stepName="ResetServer"]/command' , 'server/resetServer.pl'],
 ['//procedure[procedureName="CheckServerStatus"]/step[stepName="CheckServerStatus"]/command' , 'server/checkServerStatus.pl'],
 ['//procedure[procedureName="StartIISServices"]/step[stepName="StartIISServices"]/command' , 'server/startIISService.pl'],
 ['//procedure[procedureName="StopIISServices"]/step[stepName="StopIISServices"]/command' , 'server/stopIISService.pl'],
 ['//procedure[procedureName="DeployCopy"]/step[stepName="Deploy"]/command' , 'server/deployCopy.pl'],
 ['//procedure[procedureName="GetWebSiteIDs"]/step[stepName="GetWebSiteIDs"]/command' , 'server/getWebSiteIDs.pl'],
 ['//procedure[procedureName="GetWebSiteStatus"]/step[stepName="GetStatus"]/command' , 'server/getWebSiteStatus.pl'],
 ['//procedure[procedureName="GetVirtualDirectories"]/step[stepName="GetVirtualDirectories"]/command' , 'server/getVirtualDirs.pl'],
 ['//procedure[procedureName="CreateWebApplication"]/step[stepName="CreateWebApplication"]/command' , 'server/createWebApplication.pl'],

 ['//procedure[procedureName="CreateConfiguration"]/step[stepName="CreateConfiguration"]/command' , 'conf/createcfg.pl'],
 ['//procedure[procedureName="CreateConfiguration"]/step[stepName="CreateAndAttachCredential"]/command' , 'conf/createAndAttachCredential.pl'],
 ['//procedure[procedureName="DeleteConfiguration"]/step[stepName="DeleteConfiguration"]/command' , 'conf/deletecfg.pl'],

 ['//property[propertyName="ec_setup"]/value', 'ec_setup.pl'],
);
