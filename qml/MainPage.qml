/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.0
import org.hildon.components 1.0

Page {
    id: mainScope
    objectName: "mainScope"

    anchors.fill: parent
    property alias viewport: webViewport

    signal pageTitleChanged(string title)

//    x: 0; y: 0
//    width: 800; height: 600

    function load(address) {
        addressLine.text = address;
        viewport.child().load(address)
    }

    function focusAddressBar() {
        addressLine.forceActiveFocus()
        addressLine.selectAll()
    }
//    QMozContext { id: qMozContext }
    ToolBar {
        id: navigationBar
        Row {
            id: controlsRow
            spacing: 4
            ToolButton {
                id: backButton
                width: height
                iconSource: "../icons/back.svg"
                visible: webViewport.child().canGoBack
                onClicked: {
                    console.log("going back")
                    viewport.child().goBack()
                }
            }
            ToolButton {
                id: forwardButton
                width: height
                iconSource: "../icons/forward.svg"
                visible: webViewport.child().canGoForward
                onClicked: {
                    console.log("going forward")
                    viewport.child().goForward()
                }
            }
            ToolButton {
                id: reloadButton
                width: height
                iconSource: viewport.child().loading ? "../icons/stop.svg" : "../icons/reload.svg"
                onClicked: {
                    viewport.child();
                    if (viewport.canStop) {
                        console.log("stop loading")
                        viewport.stop()
                    } else {
                        console.log("reloading")
                        viewport.child().reload()
                    }
                }
            }
        }
        Rectangle {
            color: "transparent"
            height: navigationBar.height - 4
            anchors {
                left: controlsRow.right
                right: parent.right
//                margins: 2
                verticalCenter: parent.verticalCenter
            }
            TextField {
                id: addressLine
                clip: true
//                selectByMouse: true
//                font {
//                    pointSize: 18
//                    family: "Nokia Pure Text"
//                }
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: 2
                }

                Keys.onEnterPressed:{
                    console.log("going to: ", addressLine.text)
                    load(addressLine.text);
                }
                Keys.onReturnPressed:{
                    console.log("going to: ", addressLine.text)
                    load(addressLine.text);
                }
                Keys.onPressed: {
                    console.log(event.key)
                    if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
                        focusAddressBar()
                        event.accepted = true
                    }
                }
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                    }
                    height: 7
                    width: parent.width / 100 * viewport.child().loadProgress
//                    color: "blue"
                    BorderImage {
                        anchors.fill: parent
                        source: "image://theme/ProgressbarSmall"
//                        border.left: 1; border.top: 1
//                        border.right: 1; border.bottom: 1
                        horizontalTileMode: BorderImage.Repeat
                    }
                    visible: viewport.child().loadProgress != 100
                }
            }
        }
        Component.onCompleted: {
            print("QML On Completed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }
        Component.onDestruction: {
            print("QML On Destroyed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }
    }

    QDeclarativeMozView {
        id: webViewport
        visible: true
        focus: true
        property bool movingHorizontally : false
        property bool movingVertically : true
        property variant visibleArea : QtObject {
            property real yPosition : 0
            property real xPosition : 0
            property real widthRatio : 0
            property real heightRatio : 0
        }

        function scrollTimeout() {
            webViewport.movingHorizontally = false;
            webViewport.movingVertically = false;
        }
        Timer {
            id: scrollTimer
            interval: 500; running: false; repeat: false;
            onTriggered: webViewport.scrollTimeout()
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: navigationBar.top
        }
        Connections {
            target: webViewport.child()
            onViewInitialized: {
                webViewport.child().addMessageListener("context:info")
                print("QML View Initialized");
                if (startURL.length != 0) {
                    load(startURL);
                }
            }
            onViewAreaChanged: {
                var r = webViewport.child().contentRect;
                var offset = webViewport.child().scrollableOffset;
                var s = webViewport.child().scrollableSize;
                webViewport.visibleArea.widthRatio = r.width / s.width;
                webViewport.visibleArea.heightRatio = r.height / s.height;
                webViewport.visibleArea.xPosition = offset.x * webViewport.visibleArea.widthRatio * webViewport.child().resolution;
                webViewport.visibleArea.yPosition = offset.y * webViewport.visibleArea.heightRatio * webViewport.child().resolution;
                webViewport.movingHorizontally = true;
                webViewport.movingVertically = true;
                scrollTimer.restart();
            }
            onTitleChanged: {
                pageTitleChanged(webViewport.child().title);
            }
            onUrlChanged: {
                addressLine.text = webViewport.child().url;
            }
            onRecvAsyncMessage: {
                print("onRecvAsyncMessage:" + message + ", data:" + data);
                if (message == "context:info") {
                    contextMenu.linkHref = data.LinkHref
                    contextMenu.imgSrc = data.ImageSrc
                }
            }
            onRecvSyncMessage: {
                print("onRecvSyncMessage:" + message + ", data:" + data);
                if (message == "embed:testsyncresponse") {
                    response.message = { "val" : "response", "numval" : 0.04 };
                }
            }
            onAlert: {
                print("onAlert: title:" + data.title + ", msg:" + data.text + " winid:" + data.winid);
                alertDlg.show(data.title, data.text, data.winid);
            }
            onConfirm: {
                print("onConfirm: title:" + data.title + ", data.text:" + data.text);
                confirmDlg.show(data.title, data.text, data.winid);
            }
            onPrompt: {
                print("onPrompt: title:" + data.title + ", msg:" + data.text);
                promptDlg.show(data.title, data.text, data.defaultValue, data.winid);
            }
            onAuthRequired: {
                print("onAuthRequired: title:" + data.title + ", msg:" + data.text + ", winid:" + data.winid);
                authDlg.show(data.title, data.text, data.defaultValue, data.winid);
            }

        }
        AlertDialog {
            id: alertDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("alertresponse", {
                    "winid" : winid,
                    "checkval" : alertDlg.checkval,
                    "accepted" : alertDlg.accepted
                });
            }
        }
        ConfirmDialog {
            id: confirmDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("confirmresponse", {
                    "winid" : winid,
                    "checkval" : confirmDlg.checkval,
                    "accepted" : confirmDlg.accepted
                });
            }
        }
        PromptDialog {
            id: promptDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("promptresponse", {
                    "winid" : winid,
                    "checkval" : promptDlg.checkval,
                    "accepted" : promptDlg.accepted,
                    "promptvalue" : promptDlg.prompttext
                });
            }
        }
        AuthenticationDialog {
            id: authDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("authresponse", {
                    "winid" : winid,
                    "checkval" : authDlg.checkval,
                    "accepted" : authDlg.accepted,
                    "username" : authDlg.username,
                    "password" : authDlg.password
                });
            }
        }
        ScrollIndicator {
            id: scrollIndicator
            flickableItem: webViewport
        }
    }

    MouseArea {
        property bool longPressed: false
        anchors.fill: webViewport
        onPressAndHold: {
            longPressed = true
            contextMenu.x = mouseX
            contextMenu.y = mouseY
            contextMenu.open()
        }
    }

    ContextMenu {
        id: contextMenu
        property string linkHref
        property string imgSrc
        ContextMenuLayout {

            ContextMenuItem {
                text: qsTr("Open in new window")
                onClicked: {
//                    qMozContext.newWindow(linkHref)
                }
            }
        }
    }


    Keys.onPressed: {
        if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
            console.log("Focus address bar")
            focusAddressBar()
            event.accepted = true
        }
    }
}
