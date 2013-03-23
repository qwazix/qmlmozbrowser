CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTest
contains(QT_MAJOR_VERSION, 4) {
  SOURCES += main.cpp qmlapplicationviewer.cpp WindowCreator.cpp
  HEADERS += qmlapplicationviewer.h WindowCreator.h
} else {
  SOURCES += mainqt5.cpp
}

contains(QT_MAJOR_VERSION, 4) {
  QT += opengl declarative
  PKGCONFIG += QJson
} else {
  QT += qml quick widgets
  QT += opengl declarative
}

QML_FILES = qml/*.qml
RESOURCES = qmlMozEmbedTest.qrc

PREFIX = /usr

maemo5 {
    QML_FILES = qml-hildon/*.qml
    RESOURCES = qmlMozEmbedTestHildon.qrc
    splash.path = /opt/qmlMozEmbedTest/splash
    splash.files = icons-hildon/splash.html \
                   icons-hildon/splash.png
    INSTALLS += splash
    icon.path = /usr/share/icons/hicolor/96x96/apps
    icon.files = icons-hildon/alopex.png
    INSTALLS += icon
    desktop.path = /usr/share/applications/hildon
    desktop.files = icons-hildon/alopex.desktop
    INSTALLS += desktop
    symlink.path = /usr/bin
    symlink.files = icons-hildon/qmlMozEmbedTest
    INSTALLS += symlink

    PREFIX = /opt/usr
}

TEMPLATE = app
CONFIG -= app_bundle

isEmpty(QTEMBED_LIB) {
  PKGCONFIG += qtembedwidget x11
} else {
  LIBS+=$$QTEMBED_LIB -lX11
}

isEmpty(DEFAULT_COMPONENT_PATH) {
  DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"/usr/lib/mozembedlite/\\\"\"
} else {
  DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"$$DEFAULT_COMPONENT_PATH\\\"\"
}


isEmpty(OBJ_DEB_DIR) {
  OBJ_DEB_DIR=$$OBJ_BUILD_PATH
}

OBJECTS_DIR += ./$$OBJ_DEB_DIR
DESTDIR = ./$$OBJ_DEB_DIR
MOC_DIR += ./$$OBJ_DEB_DIR/tmp/moc/release_static
RCC_DIR += ./$$OBJ_DEB_DIR/tmp/rcc/release_static

target.path = $$PREFIX/bin
INSTALLS += target

contains(CONFIG,qdeclarative-boostable):contains(MEEGO_EDITION,harmattan) {
    DEFINES += HARMATTAN_BOOSTER
}

OTHER_FILES += \
    qml-hildon/Stack.qml \
    qml-hildon/ScrollIndicator.qml \
    qml-hildon/MainPage.qml \
    qml-hildon/main.qml \
    qml-hildon/dialogs/PromptDialog.qml \
    qml-hildon/dialogs/DialogLineInput.qml \
    qml-hildon/dialogs/DialogButton.qml \
    qml-hildon/dialogs/Dialog.qml \
    qml-hildon/dialogs/ConfirmDialog.qml \
    qml-hildon/dialogs/AuthenticationDialog.qml \
    qml-hildon/dialogs/AlertDialog.qml \
    qml-hildon/constants.js \

HEADERS += \
    windowhelper.h

SOURCES += \
    windowhelper.cpp
