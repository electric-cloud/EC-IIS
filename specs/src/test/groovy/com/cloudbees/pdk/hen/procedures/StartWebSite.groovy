package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class StartWebSite extends Procedure {

    static StartWebSite create(Plugin plugin) {
        return new StartWebSite(procedureName: 'startWebSite', plugin: plugin,)
    }

    StartWebSite flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    StartWebSite withUser(User user) {
        this.contextUser = user
        return this
    }

    StartWebSite clone() {
        StartWebSite cloned = new StartWebSite(procedureName: 'startWebSite', plugin: plugin,)
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    StartWebSite config(String config) {
        this.addParam('config', config)
        return this
    }

    StartWebSite websitename(String websitename) {
        this.addParam('sitename', websitename)
        return this
    }

}