#!/bin/bash

download() {
 if [[ ! -f "ogg-master.zip" ]]; then
  wget --output-document=ogg-master.zip https://github.com/xiph/ogg/archive/master.zip
  rm -rf ./ogg-master;
  unzip ogg-master.zip
 fi

 if [[ ! -f "vorbis-master.zip" ]]; then
  wget --output-document=vorbis-master.zip https://github.com/xiph/vorbis/archive/master.zip
  rm -rf ./vorbis-master;
  unzip vorbis-master.zip
 fi

 if [[ ! -f "opus-master.zip" ]]; then
  wget --output-document=opus-master.zip https://github.com/xiph/opus/archive/master.zip
  rm -rf ./opus-master;
  unzip opus-master.zip
  if [[ ! -f "./opus-master/package_version" ]]; then
   echo 'PACKAGE_VERSION="1.3.1"'>./opus-master/package_version
  fi
 fi

 if [[ ! -f "flac-master.zip" ]]; then
  wget --output-document=flac-master.zip https://github.com/xiph/flac/archive/1.3.3.zip
  rm -rf ./flac-master;
  unzip flac-master.zip
  mv flac-1.3.3 flac-master
 fi

 if [[ ! -f "libsndfile-master.zip" ]]; then
  wget --output-document=libsndfile-master.zip https://github.com/libsndfile/libsndfile/archive/master.zip
  rm -rf ./libsndfile-master;
  unzip libsndfile-master.zip
 fi
 echo "Download complite"
}

export CFLAGS="$CFLAGS -fPIC -static-libgcc -static-libstdc++ -O3"
export CPPFLAGS="$CPPFLAGS -fPIC -static-libgcc -static-libstdc++ -O3"

export PKG_CONFIG_PATH=$(pwd)/lib/pkgconfig

export OGG_LIBS="-L$(pwd)/lib -logg -Wl,-logg"
export VORBIS_LIBS="-L$(pwd)/lib -lvorbis -Wl,-lvorbis"
export VORBISENC_LIBS="-L$(pwd)/lib -lvorbisenc -Wl,-lvorbisenc"
export FLAC_LIBS="-L$(pwd)/lib -lFLAC -Wl,-lFLAC"
export OPUS_LIBS="-L$(pwd)/lib -lopus -Wl,-lopus"

to_make() {
 pr_path=$(pwd)
 cd $1

 if [[ ! -f "configure" ]]; then
  ./autogen.sh
 fi
 
 if [[ _$host_make == _ ]]; then
  ./configure --prefix=$pr_path --with-gnu-ld ${@:2}
 else
  ./configure --prefix=$pr_path --host=$host_make --with-gnu-ld ${@:2}
 fi

 echo "Press enter to continue"
 read _

 make install

 cd $pr_path
}


to_clean() {
 pr_path=$(pwd)
 cd $1

 make clean

 cd $pr_path
}

to_clean_all() {
 to_clean ogg-master 
 to_clean vorbis-master 
 to_clean opus-master  
 to_clean flac-master 
 to_clean libsndfile-master
}

strip_obj() {
 for f in $(find $(pwd) -name '*.a'); do
  echo $f
  mingw-objcopy --strip-unneeded $f $f
 done
 strip -s $(pwd)/bin/*
}

host_make=""

select_host() {
 echo "Select host:"
 select yn in "exit" "" "i686-w64-mingw32" "x86_64-w64-mingw32" "i686-linux" "x86_64-linux"; do

  if [[ _$yn == "_exit" ]]; then
   break;
  fi

  host_make=$yn
  break;
 done
}

while true; do
 echo "Host:"$host_make 
 echo "Select action:"
 select yn in "Exit" "download" "select_host" "ogg_make" "vorbis_make" "opus_make" "flac_make" "sndfile_make" "strip_obj" "clean_all"; do
  case _$yn in
   _Exit          ) exit 0 ;;
   _download      ) download ;;
   _select_host   ) select_host ;;
   _ogg_make      ) to_make ogg-master --disable-shared --enable-static ;;
   _vorbis_make   ) to_make vorbis-master --disable-shared --enable-static ;;
   _opus_make     ) to_make opus-master --disable-shared --enable-static ;; 
   _flac_make     ) to_make flac-master --disable-shared --enable-static ;;
   _sndfile_make  ) to_make libsndfile-master --enable-shared --enable-static;;
   _strip_obj     ) strip_obj ;;
   _clean_all     ) to_clean_all ;;
  esac
  break;
 done
done




