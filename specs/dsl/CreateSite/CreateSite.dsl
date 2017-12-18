def projName = args.projName
def resName = args.resName

def params = [
  websitename: '',
  websitepath: '',
  bindings: '',
  websiteid: ''
]

project projName, {
    procedure 'Create Site', {
      resourceName = resName

      step 'Create Site', {
        description = ''
        subprocedure = 'CreateWebSite'
        subproject = '/plugins/EC-IIS/project'

        params.each { name, defValue ->
          actualParameter name, '$[' + name + ']'
        }
      }


      params.each {name, defValue ->
        formalParameter name, defaultValue: defValue, {
          type = 'textarea'
        }
      }
  }
}
