export LANG:=en_US.UTF-8
export MAVEN_OPTS:=-Dmaven.test.skip=true -Dmaven.javadoc.skip=true

chinese-whispers.jar: chinese-whispers-master.zip
	rm -rf chinese-whispers-master
	unzip chinese-whispers-master.zip
	mvn -f chinese-whispers-master/pom.xml -T $$(nproc) package
	mv -fv chinese-whispers-master/target/chinese-whispers.jar .

chinese-whispers-master.zip:
	curl -sLo 'chinese-whispers-master.zip' 'https://github.com/uhh-lt/chinese-whispers/archive/master.zip'

maxmax.jar: maxmax-master.zip
	rm -rf watset-java-1.0
	unzip maxmax-master.zip
	mv watset-java-1.0 maxmax-master
	mvn -f maxmax-master/pom.xml -T $$(nproc) package
	mv -fv maxmax-master/target/maxmax.jar .

maxmax-master.zip:
	curl -sLo 'maxmax-master.zip' 'https://github.com/nlpub/watset-java/archive/1.0.zip'

mcl: mcl-14-137.tar.gz
	rm -rf mcl-14-137
	tar zxf mcl-14-137.tar.gz
	cd mcl-14-137 && ./configure --prefix="$(CURDIR)/mcl-14-137"
	$(MAKE) -j$$(nproc) -C mcl-14-137 all
	$(MAKE) -C mcl-14-137 install
	mv -fv mcl-14-137/bin/mcl .

mcl-14-137.tar.gz:
	curl -sLO 'https://micans.org/mcl/src/mcl-14-137.tar.gz'

clean:
	rm -rf chinese-whispers* maxmax* mcl*
