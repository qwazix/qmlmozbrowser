#include "qmldialog.h"
#include <QApplication>
#include <QDesktopWidget>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDebug>
#include <QGraphicsObject>

qmlDialog::qmlDialog(QWidget *parent) :
    QDialog(parent)
{
}

qmlDialog::qmlDialog(QUrl qmlFile){
    qmlView = new QDeclarativeView(this);
    qmlView->setSource(qmlFile);
    connect(QApplication::desktop(), SIGNAL(resized(int)), this, SLOT(orientationChanged()));
    orientationChanged();
}

void qmlDialog::orientationChanged(){
    QRect screenGeometry = QApplication::desktop()->screenGeometry();
    qmlView->resize(screenGeometry.width(),screenGeometry.height()*0.8);

    QGraphicsObject *object = qmlView->rootObject();

    object->setProperty("width", screenGeometry.width());
    object->setProperty("height", screenGeometry.height()*0.8-30);
}
