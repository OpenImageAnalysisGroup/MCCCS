FROM klukas/iap
MAINTAINER Dr. Christian Klukas <christian.klukas@gmail.com>
LABEL Description="Multi Channel Classification and Clustering" Version="1.0.0"
RUN apt-get update
RUN apt-get install -y bc parallel
#RUN rm -R IAP/
#RUN rm IAPconsole.sh
#RUN rm IAPgui.sh
RUN mkdir start
RUN mkdir start/lib
RUN cp iap_2_0.jar /start/lib/iap.jar
RUN cd start/lib
RUN wget -N "http://downloads.openmicroscopy.org/bio-formats/5.1.0/artifacts/bioformats_package.jar"
RUN wget -N "http://central.maven.org/maven2/de/lmu/ifi/dbs/jfeaturelib/JFeatureLib/1.6.1/JFeatureLib-1.6.1.jar"
RUN git clone --depth=1 https://github.com/OpenImageAnalysisGroup/MCCCS.git
RUN mkdir /MCCCS/MCCCS/bin
RUN javac -cp $(ls -1 /start/**/*.jar | paste -sd ":" -)  /MCCCS/MCCCS/src/**/*.java -d /MCCCS/MCCCS/bin/
RUN ant -f MCCCS/MCCCS/create_mcccs_jar.xml
RUN cp /MCCCS/MCCCS/release/mcccs.jar start
RUN cp -r /MCCCS/MCCCS/main/* start
RUN chmod +x start/*.sh
