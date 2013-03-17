#include "windowhelper.h"
#include <QDeclarativeView>
#include <QDebug>

WindowHelper::WindowHelper(QObject *parent) :
    QObject(parent)
{


}


WindowHelper::WindowHelper(QDeclarativeView* view){
    this->view = view;
}

void WindowHelper::setFullScreen(bool state){
    qDebug()<<"setFullscreen:" << state;
    if (state){
//        isFullScreen = true;
        view->setWindowState(Qt::WindowFullScreen);
    } else {
//        isFullScreen = false;
        view->setWindowState(Qt::WindowNoState);
    }
}

bool WindowHelper::isFullScreen(){
    bool isFullScreen = this->view->windowState() & Qt::WindowFullScreen;
    qDebug()<< isFullScreen;
    return isFullScreen;
}
