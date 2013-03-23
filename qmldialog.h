#ifndef QMLDIALOG_H
#define QMLDIALOG_H

#include <QDialog>
#include <QUrl>
#include <QDeclarativeView>

class qmlDialog : public QDialog
{
    Q_OBJECT
//    Q_PROPERTY(int width READ width NOTIFY widthChanged)
public:
    explicit qmlDialog(QWidget *parent = 0);
    qmlDialog(QUrl qmlFile);
    
signals:
    
public slots:
    void orientationChanged();
private:
    QDeclarativeView *qmlView;
};

#endif // QMLDIALOG_H
