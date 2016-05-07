FROM klukas/iap
MAINTAINER Dr. Christian Klukas <christian.klukas@gmail.com>
LABEL Description="Multi Channel Classification and Clustering" Version="1.0.0"
RUN rm -rfd IAP/
RUN rm -rf IAPconsole.sh
RUN rm -rf IAPgui.sh
RUN git clone --depth=1 https://github.com/OpenImageAnalysisGroup/MCCCS.git
RUN mkdir /MCCCS/MCCCS/bin
RUN ant -f MCCCS/MCCCS/create_mcccs_jar.xml 'Create IAP JAR'
RUN mv /MCCCS/MCCCS/release/mcccs.jar .
