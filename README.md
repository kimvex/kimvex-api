# Kimvex

Api para servicio kimvex

## Installation

[http://mongoc.org/libmongoc/current/installing.html](http://mongoc.org/libmongoc/current/installing.html)

Instalacion de driver de base de datos para mongodb
$ wget https://github.com/mongodb/mongo-c-driver/releases/download/1.14.0/mongo-c-driver-1.14.0.tar.gz
$ tar -zxvf mongo-c-driver-1.14.0.tar.gz && cd mongo-c-driver-1.14.0/
$ mkdir cmake-build
$ cd cmake-build
\$ cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF ..

$ make
$ sudo make install

## Usage

Para prueba se ejecuta

## Development

crystal run src/init.cr --error-trace
