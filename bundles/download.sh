if [ ! -f jakartaeetck.zip ]; then
  wget --read-timeout=20 https://download.eclipse.org/ee4j/jakartaee-tck/jakartaee9/promoted/jakartaeetck-9.1.0.zip -O jakartaeetck.zip
fi
if [ ! -f cdi-tck-3.0.3-dist.zip ]; then
  wget https://download.eclipse.org/ee4j/cdi/3.0/cdi-tck-3.0.3-dist.zip -O cdi-tck-3.0.3-dist.zip
fi
if [ ! -f jakarta-inject-tck-2.0.1-bin.zip ]; then
  wget https://download.eclipse.org/ee4j/cdi/inject/2.0/jakarta.inject-tck-2.0.1-bin.zip -O jakarta.inject-tck-2.0.1-bin.zip
fi
if [ ! -f bv-tck-3.0.0-dist.zip ]; then
	wget https://download.eclipse.org/ee4j/bean-validation/3.0/beanvalidation-tck-dist-3.0.0.zip -O bv-tck-3.0.0-dist.zip
fi
if [ ! -f latest-glassfish.zip ]; then
	wget https://download.eclipse.org/ee4j/glassfish/glassfish-6.2.4.zip -O latest-glassfish.zip
fi
if [ ! -f javadb.zip ]; then
	wget https://dlcdn.apache.org//db/derby/db-derby-10.15.2.0/db-derby-10.15.2.0-bin.zip -O javadb.zip
fi
