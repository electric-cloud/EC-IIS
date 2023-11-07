package com.cloudbees.pdk.hen

import com.cloudbees.pdk.hen.procedures.CheckServerStatus
import com.cloudbees.pdk.hen.procedures.CreateWebSite
import com.cloudbees.pdk.hen.procedures.DeleteWebSite
import com.cloudbees.pdk.hen.procedures.EditConfiguration
import com.cloudbees.pdk.hen.procedures.IISConfig
import com.cloudbees.pdk.hen.procedures.ListSites
import com.cloudbees.pdk.hen.procedures.StartWebSite
import com.cloudbees.pdk.hen.procedures.StopWebSite
import com.cloudbees.pdk.hen.procedures.TestConfiguration

import static com.cloudbees.pdk.hen.Utils.env

class IIS extends Plugin {

    static IIS create() {
        IIS plugin = new IIS(name: 'EC-IIS', configPath: 'ec_plugin_cfgs', configFieldName: 'config')
        plugin.configurationHandling = ConfigurationHandling.OLD

        plugin.configure(plugin.config)
        return plugin
    }

    static IIS createWithoutConfig() {
        IIS plugin = new IIS(name: 'EC-IIS', configurationHandling: ConfigurationHandling.OLD)
        return plugin
    }

    IISConfig config = IISConfig
            .create(this)
            .iisUrl(env("IIS_IP"))
            .iisPort(env("IIS_PORT"))
            .credential(env("IIS_LOGIN", ""), env("IIS_PASSWORD", ""))

    EditConfiguration editConfig() {
        editConfiguration.addParam(this.configFieldNameCreateConfiguration, this.configName)
        return editConfiguration
    }

    EditConfiguration editConfiguration = EditConfiguration.create(this)

    DeleteConfigurationProcedure deleteConfiguration = DeleteConfigurationProcedure.create(this)

    TestConfiguration testConfiguration = TestConfiguration.create(this)

    CheckServerStatus checkServerStatus = CheckServerStatus.create(this)
    ListSites listSites = ListSites.create(this)
    CreateWebSite createWebSite = CreateWebSite.create(this)
    DeleteWebSite deleteWebSite = DeleteWebSite.create(this)
    StartWebSite startWebSite = StartWebSite.create(this)
    StopWebSite stopWebSite = StopWebSite.create(this)

}