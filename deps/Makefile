export LANG:=en_US.UTF-8
export MAVEN_OPTS:=-Dmaven.test.skip=true -Dmaven.javadoc.skip=true

chinese-whispers.jar: chinese-whispers-master.zip
	rm -rf chinese-whispers-master
	unzip chinese-whispers-master.zip 
	cd chinese-whispers-master && mvn -T $$(nproc) package
	mv -fv chinese-whispers-master/target/chinese-whispers.jar .

chinese-whispers-master.zip:
	curl -sLo 'chinese-whispers-master.zip' 'https://github.com/uhh-lt/chinese-whispers/archive/master.zip'

maxmax.jar: maxmax-master.zip
	rm -rf maxmax-master
	unzip maxmax-master.zip
	cd maxmax-master && mvn -T $$(nproc) package
	mv -fv maxmax-master/target/maxmax.jar .

maxmax-master.zip:
	curl -sLo 'maxmax-master.zip' 'https://github.com/dustalov/maxmax/archive/master.zip'
	
mcl: mcl-14-137.tar.gz
	rm -rf mcl-14-137
	tar zxf mcl-14-137.tar.gz
	cd mcl-14-137 && ./configure --prefix="$(CURDIR)/mcl-14-137" && make -j$$(nproc) && make install
	mv -fv mcl-14-137/bin/mcl .

mcl-14-137.tar.gz:
	curl -sLO 'https://micans.org/mcl/src/mcl-14-137.tar.gz'

clean:
	rm -rf chinese-whispers* maxmax* mcl*
