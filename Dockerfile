FROM klukas/iap
MAINTAINER Dr. Christian Klukas <christian.klukas@gmail.com>
LABEL Description="Multi Channel Classification and Clustering" Version="1.0.0"
#RUN apt-get update -y
RUN apt-get install -y bc
#RUN rm -R IAP/
#RUN rm IAPconsole.sh
#RUN rm IAPgui.sh
RUN git clone --depth=1 https://github.com/OpenImageAnalysisGroup/MCCCS.git
RUN mkdir /MCCCS/MCCCS/bin
RUN ant -f MCCCS/MCCCS/create_mcccs_jar.xml
RUN cp /MCCCS/MCCCS/release/mcccs.jar .
RUN mkdir start
RUN cp -r /MCCCS/MCCCS/main/* start
RUN chmod +x start/*.sh
RUN mkdir start/lib
RUN cp iap_2_0.jar /start/lib/iap.jar
