#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H
#include <QDeclarativeView>

#include <QObject>

class WindowHelper : public QObject
{
    Q_OBJECT
public:
    explicit WindowHelper(QObject *parent = 0);
    WindowHelper(QDeclarativeView*);
    QDeclarativeView* view;
    
signals:
    
public slots:
    void setFullScreen(bool);
    bool isFullScreen();
    
};

#endif // WINDOWHELPER_H
