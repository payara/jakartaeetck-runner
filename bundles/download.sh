if [ ! -f jakartaeetck.zip ]; then
  wget --read-timeout=20 https://download.eclipse.org/jakartaee/platform/10/jakarta-jakartaeetck-10.0.0.zip -O jakartaeetck.zip
fi
if [ ! -f cdi-tck-4.0.5-dist.zip ]; then
  wget https://download.eclipse.org/ee4j/cdi/4.0/cdi-tck-4.0.5-dist.zip -O cdi-tck-4.0.5-dist.zip
fi
if [ ! -f jakarta.inject-tck-2.0.1-bin.zip ]; then
  wget https://download.eclipse.org/ee4j/cdi/inject/2.0/jakarta.inject-tck-2.0.1-bin.zip -O jakarta.inject-tck-2.0.1-bin.zip
fi
if [ ! -f bv-tck-3.0.1-dist.zip ]; then
	wget https://download.eclipse.org/ee4j/bean-validation/3.0/beanvalidation-tck-dist-3.0.1.zip -O bv-tck-3.0.1-dist.zip
fi
if [ ! -f latest-glassfish.zip ]; then
	wget https://download.eclipse.org/ee4j/glassfish/glassfish-7.0.4.zip -O latest-glassfish.zip
fi
if [ ! -f javadb.zip ]; then
	wget https://dlcdn.apache.org//db/derby/db-derby-10.15.2.0/db-derby-10.15.2.0-bin.zip -O javadb.zip
fi
if [ ! -f jakarta-activation-tck-2.1.0.zip ]; then
	wget https://download.eclipse.org/jakartaee/activation/2.1/jakarta-activation-tck-2.1.0.zip -O jakarta-activation-tck-2.1.0.zip
fi
if [ ! -f jakarta-xml-binding-tck-4.0.1.zip ]; then
	wget https://download.eclipse.org/jakartaee/xml-binding/4.0/jakarta-xml-binding-tck-4.0.1.zip -O jakarta-xml-binding-tck-4.0.1.zip
fi
if [ ! -f jakarta-debugging-tck-2.0.0.zip ]; then
	wget https://download.eclipse.org/jakartaee/debugging/2.0/jakarta-debugging-tck-2.0.0.zip -O jakarta-debugging-tck-2.0.0.zip
fi
if [ ! -f mail-tck-2.1_latest.zip ]; then
	wget https://download.eclipse.org/jakartaee/mail/2.1/jakarta-mail-tck-2.1.2.zip -O mail-tck-2.1_latest.zip
fi
