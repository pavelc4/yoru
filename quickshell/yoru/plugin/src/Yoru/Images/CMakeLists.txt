qml_module(yoru-images
    URI Yoru.Images
    SOURCES
        cachingimageprovider.cpp
        imagecacher.cpp
        iutils.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
)
