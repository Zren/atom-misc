// ==UserScript==
// @name            Atom: Package Installer
// @description     Install packages from the web.
// @author          Chris H (Zren / Shade)
// @icon            https://atom.io/favicon.ico
// @version         1
// @include         https://atom.io/packages/*
// ==/UserScript==

navigator.registerProtocolHandler('web+apm', 'apm://%s', 'Atom Package Manager');
var packageNameLinkElement = document.querySelector('.package-show .package-name .css-truncate-target a');
var packageName = packageNameLinkElement.text;
var packageNameWrapperElement = document.querySelector('.package-show .package-name');
var installButton = document.createElement('a');
installButton.className = 'meta-right minibutton';
installButton.href = 'apm://install/' + packageName;
installButton.innerHTML = '<span class="octicon octicon-link-external"></span>Install';
packageNameWrapperElement.appendChild(installButton);
