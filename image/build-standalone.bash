#!/bin/basj
source  ~/.sdkman/bin/sdkman-init.sh 
sdk install java 8.0.402-tem
sdk use java 8.0.402-tem
./gradlew :core:standalone:build
