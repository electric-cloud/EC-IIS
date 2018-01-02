import spock.lang.*
import com.electriccloud.spec.*

class AddSSLCertificate extends PluginTestHelper {
    static def projectName = 'EC-IIS Specs AddSSLCertificate'
    static def iisHandler
    static def procName = 'AddSSLCertificate'

    static def certificateP12 = '''
MIIJSQIBAzCCCQ8GCSqGSIb3DQEHAaCCCQAEggj8MIII+DCCA68GCSqGSIb3DQEHBqCCA6AwggOcAgEAMIIDlQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQIRyQvckNStgwCAggAgIIDaINZWLg70XUXtkJ88SHqogERD+okwpbOiOB/WTXKhSJeSDljUOMS5P3axl1WEOPM+mrHMmJLvwTU30R5+QZPJLIm1sLEXdwl35+67KEbgu6AQCHRIi4x0W1yTNS97lbqfLrIrX4fbbZkLd1E/pZEG9elQmobLYEUSrWkJ1xvsuTEA81ShJrbuJZn6w0kEwaPaAkqStE9oPCW2sYK1r2GZerlJnlPvLK3l0hjwqAW97PqfXoVc4OA+v1pCf31jb9Lq58prJHM1QePcBXNs+35Hgj0ix5iKECUHW7x1arXzlPtwqVyJFxdOAE0R5vOywwPcdntHxYFoKpl4wpAA3u09nF8owuf+h5nXAs+xLvEwIFyXU6+dlvl2ag74vY/kBJWyXSUuOtc8zerWPOqBxEzI9mPXwgOuB/wYVJaHTUjK5sSYPGKXpLRdire20pMZoacLKYLhpTGcelVL/WUmNPWi5SLS71fqC5WYO4JYb8yDWWRKgWfEpPu4C9bIcZ3OwOjXFxqVsqCPVK/bBm2IYLPhyRoadEllNAG5j9rlDJla0kgUKxa962RzjAVwOirueU46MvlK98A24mBNziK9Mw2nySQzCz8CWwcLpokbnlFWEyD5gLOLb63W0/O8VhBL6NHHdAC4ktRySkPOIglT9omHnugt/IbgAEfR36hx0XFOFbg9zzATGKsUbppIy0kfNBsJTK9ps0e3wWuejp4Jk8NYL5dp3uixIeY6RirxgeVWC4BpP25RLUIozsON9CyLcrwNPxFELxr/c4EdA4hRBVolVIwweyBn5wVrU4STd4oVotuAIdTFMdxz/tVu6fXnj7MMilHjxkQSuQJA+Yi1TRAqdAWbcATgXxEdcDDlYCeoo9QZ3iRDIy6coZAUh1qsPs4dwu8cv6TjBeI658AIYWgyAgnLx8wKX+t5osczv6Pm92+HoWZp7uT+4QHANNMDjYE5CeN4PY8yCRcZfF7Cb67NROHhiGMBz9lSNMKSTY0WVptQZD8fF+1tCRAdiXAGJUemt/Hi/AlBgNBmrWbTAgaBLI7Eqqkfn4JLkZ4cJ5Xj2WWoBzj/88GJJTgraSaj75mXUHWXMqQL62FoEuLK7Hl8Rwjo/rJVJ1lciV9SK4ArqlDAGE2Qsrx3Hz9MHrAJjIr1ILoVL0yClDmMIIFQQYJKoZIhvcNAQcBoIIFMgSCBS4wggUqMIIFJgYLKoZIhvcNAQwKAQKgggTuMIIE6jAcBgoqhkiG9w0BDAEDMA4ECA5NYiE8ysiLAgIIAASCBMgBZUISbTK5fLm2+LQr/NKzWERUPmfx0FyWvx+7NwjJTuep/PGtZXnm8FzH5jq4TXYaGxsNNphMnU7hmBUll8FLGKtArbm359oDtAznBLw01iZwSJc5Y1G6zdW2XH05nyV7tkKRzpKlHaZulGoJhlQmMnzCnNJTp8Vjhkn+0mxgOd1Qz+LN2/rc24fef6tVOnr2WhV9CajqvsNj7WCW+rIwyS9odakH2OW7SGfsgUil7CvkW38hn96eATVjrRIs/JAeJ8uhtojY3Pe2BbrEYJrnyHHTUSc9R2vjhjsugnAMZsjg4NQW0dRLdjvX2njIbgQDHkTrbSrFAkD5p9hffkEqc6qsErKJcntsQjHkv4SXGQU+nlgmLNHAdjFvH7q8TKdZ1JsbMiuqL5a7PCbjCv6x1HJPar4m6of8zsOgstS6sN3S3mEyfL36xy70I9tSAvTGrewhM+9qzPaBkXWdgVnOUdZt3sgHvebwidsYKzriy9VrXWGdFxLaJBePYX7Dogj4fCV4UbROMaXlqXiSUiu/vR2xVM6J9A7+YhwMbuYQ37VvVfWG2D8ebIAyu6kyCBEJEK9LBjX4yU9h5rQ9fA4auiV5WM0F7csZTYLK/aY2Lyk5tmxMqLEHuiL9oculROl7JRUIqGVzQhRCg/NBf9dTUrL1p48pDzEon039F0XHezl35KOjgMw8ZaY4JtoJ8r19Ve9yUjco7ODFUZApklacjG7eNk8L1nt3O7F3eROTxaobSsYiDO1ZnUEuVVbu7S2CURJEyRJ4j7w7Q6bTcG0NzSdWQGM1GpdccnwV2OQn8udBe/l2Vsd6dYIrVgZS8WEnOlXDH2+zaP9YlmadfF8DYgv/5MWOFFiDXDBaB0vBO4Nd9bS4c2pq/7w9+QSHDks6EOWEYiBQiznaofGoOPWHeqbhDFOV/O2VswuPEeMDrXC9gVJjcCGxHEcW7D9y4NPFkWLOaZpVfNYV9yEDIA9EWrZ9IvV4kUXfOYlcCVyTTm4cDrYAx44k+SqyvUzVGTwWRcFd5od2l3VD+cLXSVm3K995ijl2GWCjzEakB1nTVAP67GUJank3J0iWqVFQVbTzf+WUbPP1mFOgeIUCxbNRVuGphhvHyZyUAJ4Q3kPvmolO8bqU2Wt9omicnVPDclm5rUVvg92XsQlvvvxC92ebyZsYyT7+3wmbjThThbFfWjxDAc6M6NF60ncfKbF/PuqYEbq0R5+3EDxmv2WXrXcqhplNxaUT2FgV79VdUeXhUMSwr7mj7OJKAxV82KXK3+gl/NGwaakF57iB5awFZC239aP0t6dMf8HY3rzGK4ayge2tUKtS2W+3ySER3hnkKYMMswiz8fFt67cKfzjsi0WjsBAaj3q/Q4KvhcAvFDlH/+H6ecJpjWqKT5Jhk4X/tWMBh7JgjAPaHe/MLcZ6W7ak3zMv8SOpifE+CKZ70zheg9WIn3d7P7KNrqklN67JnCqflJEGXv7GbL23Okj8ErvyMKb1qOKNi7qPhPW+Bz4duscpN8OZmw6a5pQqwgfiA5Ff69Jjf6nF2/fYsWmhB5M2GHy5p0Nwu3QA0xqJmTlOOfBDN1LJhgIZRjoEJbB0dQNyy/MeBtHGl17n71HMAxMLO49VtdvpWkwxJTAjBgkqhkiG9w0BCRUxFgQUh4uBocqBTxRHEyq/zSN0qUIVR6swMTAhMAkGBSsOAwIaBQAEFFijcjsRCvRlfx+fWhcqtay7OppFBAirjsz9eBqypgICCAA=
'''

    static def certHash = '‎87 8b 81 a1 ca 81 4f 14 47 13 2a bf cd 23 74 a9 42 15 47 ab'

    def doSetupSpec() {
        dsl 'setProperty(propertyName: "/plugins/EC-IIS/project/ec_debug_logToProperty", value: "/myJob/debug_logs")'
        def resName = createIISResource()
        dslFile 'dsl/RunProcedure.dsl', [
            projName: projectName,
            resName: resName,
            procName: procName,
            params: [
                ip: '',
                certHostName: '',
                port: '',
                certStore: '',
                certHash: ''
            ]
        ]
        createHelperProject(resName)
        dsl """
                project '$projectName', {
                    procedure 'Import Certificate', {
                        resourceName = '$resName'
                        formalParameter 'certificate', defaultValue: '', {
                            type = 'textarea'
                        }
                        step 'Save Certificate', {
                            command = '''
                                use strict;
                                use warnings;
                                use ElectricCommander;
                                use MIME::Base64;

                                my \$base_64 = '\$[certificate]';
                                my \$decoded = decode_base64(\$base_64);
                                open my \$fh, '>c:/certificate.p12' or die \$!;
                                binmode \$fh;
                                print \$fh \$decoded;
                                close \$fh;
                            '''
                            shell = 'ec-perl'
                        }

                        step 'Import Certificate', {
                            command = '''
                                certutil -importpfx c:\\\\certificate.p12
                            '''
                        }
                    }
                }
        """

    }

    def doCleanupSpec() {
        // dsl "deleteProject '$projectName'"
    }

    def "add certificate to site"() {
        given:
            def port = '9999'
            def siteName = 'Site With Certificate'
            createSite(siteName, 'c:/tmp/site', port)
            createCertificate()
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        ip: '0.0.0.0',
                        port: '$port',
                        certStore: 'My',
                        certHash: '$certHash'
                    ]
                )
            """
        then:
            assert result.outcome == 'success'
            logger.debug(result.logs)
            assert result.logs =~ /SSL Certificate successfully added/
        cleanup:
            removeSite(siteName)
            runCmd("netsh http delete sslcert ipport=0.0.0.0:$port")
    }

    def "add certificate to hostname"() {
        given:
            def port = '9999'
            def siteName = 'Site With Certificate'
            createSite(siteName, 'c:/tmp/site', port)
            createCertificate()
            def hostname = 'localhost'
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        certHostName: '$hostname',
                        port: '$port',
                        certStore: 'My',
                        certHash: '$certHash'
                    ]
                )
            """
        then:
            assert result.outcome == 'success'
            logger.debug(result.logs)
            assert result.logs =~ /SSL Certificate successfully added/
            def certificates = showCertificates()
            assert certificates =~ /Hostname:port\s*:\s*localhost:9999/
        cleanup:
            removeSite(siteName)
            runCmd("netsh http delete sslcert hostnameport=$hostname:$port")
    }

    def "update certificate"() {
        given:
            def port = '9999'
            def siteName = 'Site With Certificate'
            createSite(siteName, 'c:/tmp/site', port)
            createCertificate()
            def res = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        ip: '0.0.0.0',
                        port: '$port',
                        certStore: 'My',
                        certHash: '$certHash'
                    ]
                )
            """
            assert res.outcome == 'success'
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        ip: '0.0.0.0',
                        port: '$port',
                        certStore: 'My',
                        certHash: '$certHash'
                    ]
                )
            """

        then:
            assert result.outcome == 'success'
            logger.debug(result.logs)
            assert result.logs =~ /SSL Certificate successfully updated/
        cleanup:
            removeSite(siteName)
            runCmd("netsh http delete sslcert ipport=0.0.0.0:$port")

    }

    def "negative: wrong cert hash"() {
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        certHostName: 'localhost',
                        port: '99',
                        certStore: 'My',
                        certHash: 'wrong'
                    ]
                )
            """
        then:
            assert result.outcome == 'error'
            logger.debug(result.logs)

    }

    def "negative: wrong store name"() {
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        certHostName: 'localhost',
                        port: '99',
                        certStore: 'some store',
                        certHash: '$certHash'
                    ]
                )
            """
        then:
            assert result.outcome == 'error'
            logger.debug(result.logs)

    }


    def createCertificate() {
        def result = runProcedureDsl """
            runProcedure(
                projectName: '$projectName',
                procedureName: 'Import Certificate',
                actualParameter: [
                    certificate: '''$certificateP12'''
                ]
            )
        """
        assert result.outcome == 'success'
    }


    def showCertificates() {
        def res = runCmd("netsh http show sslcert")
        return res
    }
}
