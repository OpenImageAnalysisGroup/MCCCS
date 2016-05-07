FROM klukas/iap
MAINTAINER Dr. Christian Klukas <christian.klukas@gmail.com>
LABEL Description="Multi Channel Classification and Clustering" Version="1.0.0"
RUN rm -rf IAP/
RUN rm -rf IAPconsole.sh
RUN rm -rf IAPgui.sh
RUN git clone --depth=1 https://github.com/OpenImageAnalysisGroup/MCCCS.git
