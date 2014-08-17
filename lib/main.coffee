{$} = require atom.packages.resourcePath + '/src/space-pen-extensions'
_ = require atom.packages.resourcePath + '/node_modules/underscore-plus'
CSONParser = null



#--- Module
module.exports =
  activate: ->
    @bindEvents()
    @bindCommands()
    process.nextTick =>
      @onWindowLoad()

  deactivate: ->
    atom.workspaceView.off 'misc:open-active-editor-grammar-config'

  bindCommands: ->
    atom.workspaceView.command 'misc:open-active-editor-grammar-config', @openActiveEditorGrammarConfig.bind(@)


  bindEvents: ->
    # Dropping files on the window will open in the current window rather than spawning a new one.
    $(document).off 'drop'
    $(document).on 'drop', (e) ->
      e.preventDefault()
      e.stopPropagation()
      pathsToOpen = _.pluck(e.originalEvent.dataTransfer.files, 'path')
      _.each pathsToOpen, (pathToOpen) ->
        try
          atom.workspace.open(pathToOpen)
        catch error
          # Path is probably a directory
          # For now, just ignore it.



  onWindowLoad: ->
    @sortPackagesMenu()
    @deleteWindowMenu()
    @deleteFileMenuYourCommands()
    @insertConfigMenu()
    atom.menu.update()

  sortPackagesMenu: ->
    packagesMenu =  _.findWhere(atom.menu.template, {label:'Packages'}) or _.findWhere(atom.menu.template, {label:'&Packages'})
    packagesMenu.submenu.sort (a, b) ->
      if a.label then a.label.localeCompare(b.label) else -1

  deleteWindowMenu: ->
    for menu, index in atom.menu.template
      if menu?.label is 'Window' or menu?.label is '&Window'
        atom.menu.template.splice(index, 1)
        break

  deleteFileMenuYourCommands: ->
    yourCommands = [
      'application:open-your-config'
      'application:open-your-init-script'
      'application:open-your-keymap'
      'application:open-your-snippets'
      'application:open-your-stylesheet'
    ]
    fileMenu =  _.findWhere(atom.menu.template, {label:'Atom'}) or _.findWhere(atom.menu.template, {label:'&File'})
    for yourCommand in yourCommands
      for item, index in fileMenu.submenu
        if item?.command is yourCommand
          fileMenu.submenu.splice(index, 1)
          break

  newConfigMenu: ->
    menu = {
      label: 'Config'
      submenu: [
        {
          label: 'User'
          submenu: [
            { label: 'Config', command: 'application:open-your-config' }
            { label: 'Init Script', command: 'application:open-your-init-script' }
            { label: 'Keymap', command: 'application:open-your-keymap' }
            { label: 'Snippets', command: 'application:open-your-snippets' }
            { label: 'Stylesheet', command: 'application:open-your-stylesheet' }
          ]
        }
        { label: 'Config – Syntax', command: 'misc:open-active-editor-grammar-config' }
      ]
    }

  insertConfigMenu: ->
    for menu, index in atom.menu.template
      if menu?.label is 'Config'
        # Replace
        atom.menu.template[index] = @newConfigMenu()
        break
      else if menu?.label is 'Help' or menu?.label is '&Help'
        # Insert before
        atom.menu.template.splice(index, 0, @newConfigMenu())
        break

  getGrammarConfig: (scopeName) ->
    return _.valueForKeyPath(atom.config.settings, 'syntax-settings.' + scopeName)


  defaultGrammarConfig: {
    editorSettings:
      softTabs: true
      softWrap: true
      tabLength: 2
    editorViewSettings:
      fontFamily: 'Consolas'
      fontSize: 12
      invisibles: {}
      placeholderText: ''
      showIndentGuide: true
      showInvisibles: true
      softWrap: false
    gutterViewSettings:
      showLineNumbers: true
  }

  grammarConfigCson: (grammarConfig) ->
    text = ''

    renderObject = (obj, depth) ->
      for defaultCategoryKey, defaultCategoryValue of obj
        console.log defaultCategoryKey, defaultCategoryValue
        userCategoryValue = grammarConfig[defaultCategoryKey]
        useDefaultCategory = userCategoryValue is null or _.isUndefined userCategoryValue
        text += Array(depth+1).join('  ')
        text += '# ' if useDefaultCategory
        text += '\'' + defaultCategoryKey + '\':\n'

        for defaultSettingKey, defaultSettingValue of defaultCategoryValue
          console.log defaultSettingKey, defaultSettingValue
          userSettingValue = userCategoryValue?[defaultSettingKey]
          useDefaultSetting = userSettingValue is null or _.isUndefined userSettingValue
          text += Array(depth+2).join('  ')
          text += '# ' if useDefaultSetting
          text += '\'' + defaultSettingKey + '\': '
          value = if useDefaultSetting then defaultSettingValue else userSettingValue
          if _.isString value
            text += '\'' + value + '\''
          else
            text += value
          text += '\n'
      console.log text

    renderObject(@defaultGrammarConfig, 0)

    return text

  openActiveEditorGrammarConfig: ->
    grammar = atom.workspace.getActiveEditor()?.getGrammar()
    scopeName = grammar?.scopeName
    console.log {scopeName}
    return unless scopeName

    atom.workspace.open().then (editor) =>
      editor.getIconName = -> 'tools'
      editor.getTitle = -> scopeName
      editor.emit 'title-changed'
      editor.emit 'path-changed'

      coffeeGrammar = atom.syntax.grammarsByScopeName['source.coffee']
      editor.setGrammar(coffeeGrammar) if coffeeGrammar

      grammarConfig = @getGrammarConfig(scopeName)
      console.log {grammarConfig}
      if grammarConfig
        text = @grammarConfigCson(grammarConfig)
        editor.setText(text)

      editor.getUri = -> true
      editor.save = ->
        try
          CSONParser ?= require 'cson-safe'
          newGrammarConfig = null
          try
            newGrammarConfig = CSONParser.parse(editor.getText())
          catch err
            if err.message is "Syntax error on line 1, column 1: One top level value expected"
              newGrammarConfig = {}
            else
              throw err
          console.log 'CSON: ', newGrammarConfig
          atom.config.set('syntax-settings.' + scopeName, newGrammarConfig)
          syntaxSettings = atom.packages.getActivePackage('syntax-settings').mainModule
          syntaxSettings.reloadSettings()
        catch err
          alert err.message
