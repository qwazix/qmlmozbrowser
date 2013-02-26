CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTest
contains(QT_MAJOR_VERSION, 4) {
  QT += opengl declarative
  SOURCES += main.cpp qmlapplicationviewer.cpp WindowCreator.cpp
  HEADERS += qmlapplicationviewer.h WindowCreator.h
  PKGCONFIG += QJson

} else {
  QT += qml quick widgets
  SOURCES += mainqt5.cpp
}

QML_FILES = qml-hildon/*.qml
RESOURCES += qmlMozEmbedTestHildon.qrc

TEMPLATE = app
CONFIG -= app_bundle

isEmpty(QTEMBED_LIB) {
  PKGCONFIG += qtembedwidget x11
} else {
  LIBS+=$$QTEMBED_LIB
}

isEmpty(DEFAULT_COMPONENT_PATH) {
  DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"/usr/lib/mozembedlite/\\\"\"
} else {
  DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"$$DEFAULT_COMPONENT_PATH\\\"\"
}

PREFIX = /usr

isEmpty(OBJ_DEB_DIR) {
  OBJ_DEB_DIR=obj-$$OBJ_ARCH-dir
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
