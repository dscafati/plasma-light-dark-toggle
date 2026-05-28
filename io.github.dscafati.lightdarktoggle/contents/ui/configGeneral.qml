// SPDX-FileCopyrightText: 2026 Diego Scafati <dscafati@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasma5support as Plasma5Support

KCM.SimpleKCM {
    id: configRoot

    property string cfg_lightTheme
    property string cfg_darkTheme
    property string cfg_iconMode
    
    property var colorSchemesList: []
    property bool configLoaded: false

    Component.onCompleted: {
        // Fetch available color schemes on startup
        schemesFetcher.exec("plasma-apply-colorscheme", ["--list-schemes"])
    }

    // DataSource to fetch available color schemes
    Plasma5Support.DataSource {
        id: schemesFetcher
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            const output = data.stdout || ""
            const lines = output.split('\n')
            colorSchemesList = []
            
            // Parse the output to extract scheme names
            for (let line of lines) {
                // Lines look like: " * SchemeName" or " * SchemeName (current color scheme)"
                const match = line.match(/^\s*\*\s+(.+?)(?:\s+\(.*\))?\s*$/)
                if (match && match[1]) {
                    colorSchemesList.push(match[1])
                }
            }
            
            // Ensure our defaults are in the list
            if (!colorSchemesList.includes("BreezeLight")) colorSchemesList.push("BreezeLight")
            if (!colorSchemesList.includes("BreezeDark")) colorSchemesList.push("BreezeDark")
            
            // Sort alphabetically
            colorSchemesList.sort()
            
            // Update combo boxes
            lightSchemeCombo.model = colorSchemesList
            darkSchemeCombo.model = colorSchemesList
            
            // Set current values from config
            const lightIndex = colorSchemesList.indexOf(cfg_lightTheme)
            const darkIndex = colorSchemesList.indexOf(cfg_darkTheme)
            
            lightSchemeCombo.currentIndex = lightIndex >= 0 ? lightIndex : 0
            darkSchemeCombo.currentIndex = darkIndex >= 0 ? darkIndex : 0
            
            configLoaded = true
            
            disconnectSource(source)
        }

        function exec(cmd, args) {
            const fullCommand = args && args.length > 0 ? cmd + " " + args.join(" ") : cmd
            connectSource(fullCommand)
        }
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: lightSchemeCombo
            Kirigami.FormData.label: i18n("Light Color Scheme:")
            model: colorSchemesList
            onActivated: {
                if (configLoaded) {
                    cfg_lightTheme = currentText
                }
            }
        }

        QQC2.ComboBox {
            id: darkSchemeCombo
            Kirigami.FormData.label: i18n("Dark Color Scheme:")
            model: colorSchemesList
            onActivated: {
                if (configLoaded) {
                    cfg_darkTheme = currentText
                }
            }
        }

        QQC2.ComboBox {
            id: iconModeCombo
            Kirigami.FormData.label: i18n("Icon Mode:")
            model: [i18n("Show Current Status"), i18n("Show Target Action")]
            currentIndex: cfg_iconMode === "target" ? 1 : 0
            onActivated: {
                cfg_iconMode = currentIndex === 1 ? "target" : "status"
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("'Show Current Status': Icon shows what is currently active")
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.7
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("'Show Target Action': Icon shows what will happen when you click")
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.7
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Note: Icon colors are automatically applied from your system icon theme")
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.7
        }
    }
}



