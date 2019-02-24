#!/bin/bash

if [[ "${BUILD_TYPE}" == "AppImage" ]]; then
    sudo add-apt-repository ppa:beineri/opt-qt562-trusty -y
    sudo apt-get update -qq

    echo "--> Download linuxdeployqt tool"
    wget -c -nv "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
    chmod a+x linuxdeployqt-continuous-x86_64.AppImage
elif [[ "${BUILD_TYPE}" == "deb" ]]; then
    docker pull ubuntu:17.10
    docker run --name build-container -v $(pwd):$(pwd) -w $(pwd) -dit ubuntu:17.10 bash
elif [[ "${BUILD_TYPE}" == "rpm" ]]; then
    docker pull opensuse:42.2
    docker run --name build-container -v $(pwd):$(pwd) -w $(pwd) -dit opensuse:42.2 bash
elif [[ "${BUILD_TYPE}" == "exe" ]]; then
    source ci/scripts/exe/bootstrap_envvars.sh

    echo "--> Download Qt"
    QT_BASE_URL="https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_563/qt.563.win32_msvc2015"
    wget --quiet -O qtbase.7z "$QT_BASE_URL/5.6.3-0-201709190903qtbase-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
    wget --quiet -O qtwinextras.7z "$QT_BASE_URL/5.6.3-0-201709171315qtwinextras-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
    wget --quiet -O qttools.7z "$QT_BASE_URL/5.6.3-0-201708150657qttools-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
    wget --quiet -O qttranslations.7z "$QT_BASE_URL/5.6.3-0-201709171315qttranslations-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
    wget --quiet -O qtsvg.7z "$QT_BASE_URL/5.6.3-0-201709171315qtsvg-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"

    7z x qtbase.7z -o/c/qt
    7z x qtwinextras.7z -o/c/qt
    7z x qttools.7z -o/c/qt
    7z x qttranslations.7z -o/c/qt
    7z x qtsvg.7z -o/c/qt

    # windeployqt fails to find the binaries so we link the binaries where its looking for it
    WINDEPLOYQT_QT_DIR="/c/Users/qt/work"
    mkdir -p $WINDEPLOYQT_QT_DIR
    ln -s $QTDIR $WINDEPLOYQT_QT_DIR/install
fi
