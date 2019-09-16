if [ ! -f jakartaeetck.zip ]; then
  wget --read-timeout=20 http://download.eclipse.org/ee4j/jakartaee-tck/jakartaee8-eftl/staged-801/eclipse-jakartaeetck-8.0.1.zip -O jakartaeetck.zip
fi
if [ ! -f cdi-tck-2.0.6-dist.zip ]; then
  wget http://download.eclipse.org/ee4j/cdi/cdi-tck-2.0.6-dist.zip
fi
