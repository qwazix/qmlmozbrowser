// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import org.hildon.components 1.0

Rectangle {
    property Style platformStyle: DialogStyle {}
    color: platformStyle.backgroundColor
    onWidthChanged: console.log(width)
    Column{
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            text: "asdfasdf"
        }
        Button {
            text: "asdfasdf"
        }
        Button {
            text: "asdfasdf"
        }
        Button {
            text: "asdfasdf"
        }
    }
}
