FROM wls-domain 

ENV APP_NAME="docker" \
    APP_PKG_FILE="docker.war" \
    APP_PKG_LOCATION="/u01/oracle"

COPY container-scripts/* /u01/oracle/

COPY $APP_PKG_FILE $APP_PKG_LOCATION

RUN wlst /u01/oracle/app-deploy.py
