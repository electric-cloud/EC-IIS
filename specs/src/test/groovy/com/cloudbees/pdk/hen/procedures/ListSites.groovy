package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class ListSites extends Procedure {

    static ListSites create(Plugin plugin) {
        return new ListSites(procedureName: 'listSites', plugin: plugin,)
    }

    ListSites flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    ListSites withUser(User user) {
        this.contextUser = user
        return this
    }

    ListSites clone() {
        ListSites cloned = new ListSites(procedureName: 'listSites', plugin: plugin,)
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    ListSites config(String config) {
        this.addParam('config', config)
        return this
    }

    ListSites searchcriteria(String searchcriteria) {
        this.addParam('searchcriteria', searchcriteria)
        return this
    }

    ListSites failOnEmpty(String failOnEmpty) {
        this.addParam('failOnEmpty', failOnEmpty)
        return this
    }

    ListSites propertyName(String propertyName) {
        this.addParam('propertyName', propertyName)
        return this
    }

    ListSites dumpFormat(String dumpFormat) {
        this.addParam('dumpFormat', dumpFormat)
        return this
    }

    ListSites dumpFormat(DumpFormatOptions dumpFormat) {
        this.addParam('dumpFormat', dumpFormat.toString())
        return this
    }

    enum DumpFormatOptions {
        xml("xml"),
        json("json"),
        propertySheet("propertySheet"),
        raw("raw"),

        private String value
        DumpFormatOptions(String value) {
            this.value = value
        }

        String toString() {
            return this.value
        }
    }
}