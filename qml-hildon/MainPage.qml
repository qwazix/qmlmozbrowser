/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.0
import org.hildon.components 1.0
import "constants.js" as Cst

FocusScope {
    property alias navBar: navigationBar

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

    Menu {
        id: mainMenu
        tools: MenuLayout {
            MenuItem{
                text: qsTr("New window")
                onClicked: {
                    qMozContext.newWindow()
                }
            }
        }

    }

    QmlMozContext { id: qMozContext }


//    Flickable{
//        id: swipeManger
//        property bool swipeFromBottomEdge : false
//        onMovementStarted: {
//            if (globalMouseArea.mouseY < 20) flickable.swipeFromBottomEdge = true;
//            else flickable.swipeFromBottomEdge = false;
//            console.log('movementStarted')
//        }
//    }

    Image {
        id: backOverlay
        source: "../icons/backOverlay.svg"
        state: "hidden"
        width: 148
        height: 280
        y: (appWindow.height - height) / 2
        z:20
        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: backOverlay;
                    x: appWindow.width - Cst.swipePadding
                }
            },
            State {
                name: "other"
                PropertyChanges {
                    target: backOverlay;
                }
            }

        ]
        transitions: [
            Transition {
                to: "hidden"
                PropertyAnimation {
                    target: backOverlay;
                    properties: "x";
                    duration: 300
                }
            }
        ]
        MouseArea {
            anchors.fill: parent
            drag {
                axis: Drag.XAxis
                target: viewport.child().canGoBack?backOverlay:null
                minimumX: appWindow.width - backOverlay.width
                maximumX: appWindow.width -Cst.swipePadding
                onActiveChanged: {
                    if (drag.active) {
                        backOverlay.state = "other"
                        viewport.enabled = false;
                    } else {
                        backOverlay.state = "hidden"
                        viewport.enabled = true;
                        if (backOverlay.x < appWindow.width - backOverlay.width*0.8)
                            viewport.child().goBack()
                    }
                }
            }
        }
    }

    Rectangle {
        id: navigationBar
        height: 70 + Cst.swipePadding
        anchors.left: parent.left
        anchors.right: parent.right
        state: "hidden"
        color: "transparent";
        z: 20
        MouseArea{
            anchors.fill: parent
            drag {

                target: navigationBar
                axis: Drag.YAxis
                minimumY: mainScope.height - navigationBar.height
                maximumY: mainScope.height - (navigationBar.height - navigationBarToolBar.height)
                onActiveChanged: {
                    if (drag.active) navigationBar.state = "moving";
                    else {
                        if (navigationBar.y < mainScope.height - navigationBar.height + navigationBarToolBar.height/2) {
                            navigationBar.state = "visible"
                        } else {
                            navigationBar.state = "hidden"
                        }
                    }
                }
            }
        }
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
            }
            height: 7
            width: parent.width / 100 * viewport.child().loadProgress
//                    color: "blue"
            BorderImage {
                anchors.fill: parent
                source: "image://theme/ProgressbarSmall"
                border.left: 1; border.top: 1
                border.right: 1; border.bottom: 1
                horizontalTileMode: BorderImage.Repeat
            }
            visible: viewport.child().loadProgress != 100
        }
        Rectangle {
            id: navigationBarToolBar
            height: 70
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            Image {
                id: background
                anchors.fill: parent
                smooth: true
                fillMode: Image.Stretch
                source: "image://theme/ToolbarPrimaryBackground"
            }
            Row {
                id: controlsRow
    //            spacing: 4
                anchors.left: parent.left
                anchors.right: parent.right
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
                TextField {
                    id: addressLine
                    objectName: "addressLine"
                    width: {
                        var othersWidth = 0
                        for (var i = 0; i < parent.children.length; i++){
                            var ch = parent.children[i]
                            if (ch.objectName !== "addressLine" && !isNaN(ch.width) && ch.visible && ch.width > 0){
                                othersWidth += ch.width
                            }
                        }
                        return parent.width - othersWidth
                    }
                    anchors.top: parent.top;
                    anchors.topMargin: 2
                    clip: true
    //                selectByMouse: true
    //                font {
    //                    pointSize: 18
    //                    family: "Nokia Pure Text"
    //                }
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
                }
                ToolButton {
                    id: showFullScreen
                    iconSource: "../icons/fullscreen.svg"
                    onClicked: {
                        if (windowHelper.isFullScreen()){
                            console.log("fromFullToNot")
                            navigationBar.state = "visible"
                            windowHelper.setFullScreen(false);
                        } else {
                            navigationBar.state = "hidden"
                            windowHelper.setFullScreen(true);
                        }

                    }
                }
            }
        }
        Component.onCompleted: {
            print("QML On Completed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }
        Component.onDestruction: {
            print("QML On Destroyed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }
        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: navigationBar;
                    y: mainScope.height - (navigationBar.height - navigationBarToolBar.height)
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: navigationBar;
                    y: mainScope.height - navigationBar.height
                }
            },
            State {
                name: "moving"
                PropertyChanges {
                    target: navigationBar;
                }
            }
        ]
        transitions: [
                      Transition {
//                          from: "hidden"
                          to: "visible"
                          PropertyAnimation {
                              id:showTr;
                              target: navigationBar;
                              properties: "y";
                              duration: 100
                          }
                      },
                       Transition {
//                           from: "visible"
                           to: "hidden"
                           PropertyAnimation {
                               id:hideTr;
                               target: navigationBar;
                               properties: "y";
                               duration: 100
                           }
                       }
                   ]
    }

    QmlMozView {
        id: webViewport
        visible: true
        parentid: createParentID
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
            bottom: parent.bottom
            bottomMargin: appWindow.height - navigationBar.y - (navigationBar.height - navigationBarToolBar.height)
        }
        Connections {
            target: webViewport.child()
            onViewInitialized: {
                qMozContext.setPref("browser.ui.touch.left", 32);
                qMozContext.setPref("browser.ui.touch.right", 32);
                qMozContext.setPref("browser.ui.touch.top", 48);
                qMozContext.setPref("browser.ui.touch.bottom", 16);
                qMozContext.setPref("browser.ui.touch.weight.visited", 120);
                qMozContext.setPref("browser.download.folderList", 2); // 0 - Desktop, 1 - Downloads, 2 - Custom
                webViewport.child().loadFrameScript("chrome://embedlite/content/embedhelper.js");
                webViewport.child().addMessageListener("embed:alert");
                webViewport.child().addMessageListener("embed:prompt");
                webViewport.child().addMessageListener("embed:confirm");
                webViewport.child().addMessageListener("embed:auth");
                webViewport.child().addMessageListener("chrome:title")
                webViewport.child().addMessageListener("context:info")
                print("QML View Initialized");
                if (startURL.length != 0) {
                    load(startURL);
                } else {
                    load("about:blank")
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
                //todo: change app title??
                console.log(webViewport.child().title)
            }
            onUrlChanged: {
                addressLine.text = webViewport.child().url;
            }
            onRecvAsyncMessage: {
                print("onRecvAsyncMessage:" + message + ", data:" + data);
                if (message == "context:info") {
                    console.log(data.LinkHref)
                    console.log(data.ImageSrc)
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
            onHandleLongTap: {
//                console.log('yay');
                contextMenu.mouseX = point.x
                contextMenu.mouseY = point.y
                contextMenu.open()
                viewport.enabled = false;
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

//    MouseArea {
//        property bool longPressed: false
//        anchors.fill: webViewport
//        onPressAndHold: {
//            longPressed = true
//            contextMenu.x = mouseX
//            contextMenu.y = mouseY
//            contextMenu.open()
//        }
//    }
//    Item {
//        //workaround because hildon components
//        //require a pageStack and we don't have
//        //one for performance reasons
//        id: pageStack
//        property variant currentPage : Item { }
//    }
    Style{
        id: platformStyle
    }

    Popup {
        id: contextMenu
        property string linkHref
        property string imgSrc
        property int mouseX
        property int mouseY

        function __updatePosition() {
            x = Math.min(mouseX, appWindow.width - width);
            y = Math.min(Math.abs(mouseY - height / 2), appWindow.height - height);
        }

        height: ctxLayout.height + platformStyle.paddingNormal * 2;
        width: ctxLayout.width + platformStyle.paddingNormal * 2;

        Column {
            id: ctxLayout
            ContextMenuItem {
                text: "Duplicate window"
                onClicked: qMozContext.newWindow(webViewport.child().url)
            }
            ContextMenuItem {
                text: qsTr("Open in new window")
                visible: contextMenu.linkHref.length
                onClicked: qMozContext.newWindow(contextMenu.linkHref)
            }
            ContextMenuItem {
                text: qsTr("Copy link url")
                visible: contextMenu.linkHref.length
                onClicked: context.setClipboard(contextLinkHref)
            }
            ContextMenuItem {
                visible: contextMenu.imgSrc.length
                text: "Open image in new window"
                onClicked: qMozContext.newWindow(contextMenu.imgSrc)
            }
            ContextMenuItem {
                visible: contextMenu.imgSrc.length
                text: "Copy image url"
                onClicked: context.setClipboard(contextImageSrc)
            }
            anchors {
                top: parent.top
                left: parent.left
                margins: platformStyle.paddingNormal
            }
            z: 1001
        }
        BorderImage {
            anchors.fill: parent
            smooth: true
            border { left: 20; right: 20; top: 20; bottom: 20 }
            source: "image://theme/ContextMenu"
        }
        onOpened: __updatePosition();
        onClosed: viewport.enabled = true
    }


    Keys.onPressed: {
        if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
            console.log("Focus address bar")
            focusAddressBar()
            event.accepted = true
        }
    }
}
