FROM klukas/iap
MAINTAINER Dr. Christian Klukas <christian.klukas@gmail.com>
LABEL Description="Multi Channel Classification and Clustering" Version="1.0.0"
RUN apt-get update
RUN apt-get install -y bc parallel
#RUN rm -R IAP/
#RUN rm IAPconsole.sh
#RUN rm IAPgui.sh
RUN mkdir -p start
RUN mkdir -p start/lib
RUN cp iap_2_0.jar /start/lib/iap.jar
RUN cd start/lib
RUN wget -nv -N "http://downloads.openmicroscopy.org/bio-formats/5.1.0/artifacts/bioformats_package.jar"
RUN wget -nv -N "http://central.maven.org/maven2/de/lmu/ifi/dbs/jfeaturelib/JFeatureLib/1.6.1/JFeatureLib-1.6.1.jar"
RUN wget -nv -N "http://downloads.sourceforge.net/project/weka/weka-3-6/3.6.12/weka-3-6-12.zip"
RUN unzip -j weka-3-6-12.zip weka-3-6-12/weka.jar -d /start/lib
RUN cd /
RUN git clone --depth=1 https://github.com/OpenImageAnalysisGroup/MCCCS.git
RUN mkdir -p /MCCCS/MCCCS/bin
RUN echo "Libs:"
RUN echo $(find start/lib -name "*.jar" | paste -sd ":" -)
RUN javac -cp $(find start/lib -name "*.jar" | paste -sd ":" -) $(find /MCCCS/MCCCS/src/ -name "*.java" | paste -sd " ") -d /MCCCS/MCCCS/bin/
RUN ant -f MCCCS/MCCCS/create_mcccs_jar.xml
RUN cp /MCCCS/MCCCS/release/mcccs.jar start
RUN cp -r /MCCCS/MCCCS/main/* start
RUN chmod +x start/*.sh
