FROM wls-domain 

ENV APP_NAME="sample" \
    APP_PKG_FILE="sample.war" \
    APP_PKG_LOCATION="/u01/oracle"

COPY container-scripts/* /u01/oracle/

RUN wlst /u01/oracle/app-deploy.py
