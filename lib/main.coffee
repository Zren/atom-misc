

#--- Module
module.exports =
  activate: ->
    process.nextTick =>
      @onWindowLoad()

  deactivate: ->

  onWindowLoad: ->
    @sortPackagesMenu()

  sortPackagesMenu: ->
    packagesMenu = atom.menu.template[5]
    packagesMenu.submenu.sort (a, b) ->
      if a.label then a.label.localeCompare(b.label) else -1
    atom.menu.update()
